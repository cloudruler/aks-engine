#!/bin/bash
NODE_INDEX=$(hostname | tail -c 2)
NODE_NAME=$(hostname)
KUBECTL="/usr/local/bin/kubectl --kubeconfig=/home/$ADMINUSER/.kube/config"
ADDONS_DIR=/etc/kubernetes/addons
POD_SECURITY_POLICY_SPEC=$ADDONS_DIR/pod-security-policy.yaml
ADDON_MANAGER_SPEC=/etc/kubernetes/manifests/kube-addon-manager.yaml
GET_KUBELET_LOGS="journalctl -u kubelet --no-pager"

systemctlEnableAndStart() {
  local ret
  systemctl_restart 100 5 30 $1
  ret=$?
  systemctl status $1 --no-pager -l >/var/log/azure/$1-status.log
  if [ $ret -ne 0 ]; then
    return 1
  fi
  if ! retrycmd 120 5 25 systemctl enable $1; then
    return 1
  fi
}
systemctlEtcd() {
  for i in $(seq 1 60); do
    timeout 30 systemctl daemon-reload
    timeout 30 systemctl restart etcd && break ||
      if [ $i -eq 60 ]; then
        return 1
      else
        sleep 5
      fi
  done
  if ! retrycmd 120 5 25 systemctl enable etcd; then
    return 1
  fi
}
configureAdminUser(){
  chage -E -1 -I -1 -m 0 -M 99999 "${ADMINUSER}"
  chage -l "${ADMINUSER}"
}
configureEtcdUser(){
  useradd -U etcd
  chage -E -1 -I -1 -m 0 -M 99999 etcd
  chage -l etcd
  id etcd
}
configureSecrets(){
  local apiserver_key="/etc/kubernetes/certs/apiserver.key" ca_key="/etc/kubernetes/certs/ca.key" etcdserver_key="/etc/kubernetes/certs/etcdserver.key"
  touch "${apiserver_key}"
  touch "${ca_key}"
  touch "${etcdserver_key}"
  if [[ -z ${COSMOS_URI} ]]; then
    chown etcd:etcd "${etcdserver_key}"
  fi
  local etcdclient_key="/etc/kubernetes/certs/etcdclient.key" etcdpeer_key="/etc/kubernetes/certs/etcdpeer${NODE_INDEX}.key"
  touch "${etcdclient_key}"
  touch "${etcdpeer_key}"
  if [[ -z ${COSMOS_URI} ]]; then
    chown etcd:etcd "${etcdpeer_key}"
  fi
  chmod 0600 "${apiserver_key}" "${ca_key}" "${etcdserver_key}" "${etcdclient_key}" "${etcdpeer_key}"
  chown root:root "${apiserver_key}" "${ca_key}" "${etcdclient_key}"
  local etcdserver_crt="/etc/kubernetes/certs/etcdserver.crt" etcdclient_crt="/etc/kubernetes/certs/etcdclient.crt" etcdpeer_crt="/etc/kubernetes/certs/etcdpeer${NODE_INDEX}.crt"
  touch "${etcdserver_crt}"
  touch "${etcdclient_crt}"
  touch "${etcdpeer_crt}"
  chmod 0644 "${etcdserver_crt}" "${etcdclient_crt}" "${etcdpeer_crt}"
  chown root:root "${etcdserver_crt}" "${etcdclient_crt}" "${etcdpeer_crt}"

  set +x
  echo "${APISERVER_PRIVATE_KEY}" | base64 --decode >"${apiserver_key}"
  echo "${CA_PRIVATE_KEY}" | base64 --decode >"${ca_key}"
  echo "${ETCD_SERVER_PRIVATE_KEY}" | base64 --decode >"${etcdserver_key}"
  echo "${ETCD_CLIENT_PRIVATE_KEY}" | base64 --decode >"${etcdclient_key}"
  echo "${ETCD_PEER_KEY}" | base64 --decode >"${etcdpeer_key}"
  echo "${ETCD_SERVER_CERTIFICATE}" | base64 --decode >"${etcdserver_crt}"
  echo "${ETCD_CLIENT_CERTIFICATE}" | base64 --decode >"${etcdclient_crt}"
  echo "${ETCD_PEER_CERT}" | base64 --decode >"${etcdpeer_crt}"
}
configureEtcd() {
  set -x

  local ret f=/opt/azure/containers/setup-etcd.sh etcd_peer_url="https://${PRIVATE_IP}:2380"
  wait_for_file 1200 1 $f || exit 15
  $f >/opt/azure/containers/setup-etcd.log 2>&1
  ret=$?
  if [ $ret -ne 0 ]; then
    exit $ret
  fi

  if [[ -z ${ETCDCTL_ENDPOINTS} ]]; then
    
    
    for entry in $(cat /etc/environment); do
      export ${entry}
    done
  fi

  chown -R etcd:etcd /var/lib/etcddisk
  systemctlEtcd || exit 14
  for i in $(seq 1 600); do
    MEMBER="$(sudo -E etcdctl member list | grep -E ${NODE_NAME} | cut -d':' -f 1)"
    if [ "$MEMBER" != "" ]; then
      break
    else
      sleep 1
    fi
  done
  retrycmd 120 5 25 sudo -E etcdctl member update $MEMBER ${etcd_peer_url} || exit 15
}
configureChrony() {
  sed -i "s/makestep.*/makestep 1.0 -1/g" /etc/chrony/chrony.conf
  echo "refclock PHC /dev/ptp0 poll 3 dpoll -2 offset 0" >> /etc/chrony/chrony.conf
}
ensureChrony() {
  systemctlEnableAndStart chrony || exit 4
}

ensureRPC() {
  systemctlEnableAndStart rpcbind || exit 4
  systemctlEnableAndStart rpc-statd || exit 4
}
ensureAuditD() {
  if [[ ${AUDITD_ENABLED} == true ]]; then
    systemctlEnableAndStart auditd || exit 4
  else
    apt_get_purge auditd mlocate &
  fi
}
ensureCron() {
  local s=/lib/systemd/system/cron.service
  if [[ -f ${s} ]]; then
    if ! grep -q 'Restart=' ${s}; then
      sed -i 's/\[Service\]/[Service]\nRestart=always/' ${s}
      systemctlEnableAndStart cron
    fi
  fi
}
generateAggregatedAPICerts() {
  local f=/etc/kubernetes/generate-proxy-certs.sh
  wait_for_file 1200 1 $f || exit 6
  $f
}
configureKubeletServerCert() {
  local kubeletserver_key="/etc/kubernetes/certs/kubeletserver.key" kubeletserver_crt="/etc/kubernetes/certs/kubeletserver.crt"

  openssl genrsa -out $kubeletserver_key 2048
  openssl req -new -x509 -days 7300 -key $kubeletserver_key -out $kubeletserver_crt -subj "/CN=${NODE_NAME}"
}
configureK8s() {
  local client_key="/etc/kubernetes/certs/client.key" apiserver_crt="/etc/kubernetes/certs/apiserver.crt" azure_json="/etc/kubernetes/azure.json"
  touch "${client_key}"
  chmod 0600 "${client_key}"
  chown root:root "${client_key}"
  if [[ -n ${MASTER_NODE} ]]; then
    touch "${apiserver_crt}"
    chmod 0644 "${apiserver_crt}"
    chown root:root "${apiserver_crt}"
  fi
  set +x
  echo "${KUBELET_PRIVATE_KEY}" | base64 --decode >"${client_key}"
  configureKubeletServerCert
  if [[ -n ${MASTER_NODE} ]]; then
    echo "${APISERVER_PUBLIC_KEY}" | base64 --decode >"${apiserver_crt}"
    if [[ ${ENABLE_AGGREGATED_APIS} == True ]]; then
      generateAggregatedAPICerts
    fi
  else
    wait_for_file 1 1 /opt/azure/needs_azure.json || return
  fi

  touch $azure_json
  chmod 0600 $azure_json
  chown root:root $azure_json
  
  local sp_secret=${SERVICE_PRINCIPAL_CLIENT_SECRET//\\/\\\\}
  sp_secret=${SERVICE_PRINCIPAL_CLIENT_SECRET//\"/\\\"}
  cat <<EOF >"${azure_json}"
{
    "cloud":"AzurePublicCloud",
    "tenantId": "${TENANT_ID}",
    "subscriptionId": "${SUBSCRIPTION_ID}",
    "aadClientId": "${SERVICE_PRINCIPAL_CLIENT_ID}",
    "aadClientSecret": "${sp_secret}",
    "resourceGroup": "${RESOURCE_GROUP}",
    "location": "${LOCATION}",
    "vmType": "${VM_TYPE}",
    "subnetName": "${SUBNET}",
    "securityGroupName": "${NETWORK_SECURITY_GROUP}",
    "vnetName": "${VIRTUAL_NETWORK}",
    "vnetResourceGroup": "${VIRTUAL_NETWORK_RESOURCE_GROUP}",
    "routeTableName": "${ROUTE_TABLE}",
    "primaryAvailabilitySetName": "${PRIMARY_AVAILABILITY_SET}",
    "primaryScaleSetName": "${PRIMARY_SCALE_SET}",
    "cloudProviderBackoffMode": "${CLOUDPROVIDER_BACKOFF_MODE}",
    "cloudProviderBackoff": ${CLOUDPROVIDER_BACKOFF},
    "cloudProviderBackoffRetries": ${CLOUDPROVIDER_BACKOFF_RETRIES},
    "cloudProviderBackoffExponent": ${CLOUDPROVIDER_BACKOFF_EXPONENT},
    "cloudProviderBackoffDuration": ${CLOUDPROVIDER_BACKOFF_DURATION},
    "cloudProviderBackoffJitter": ${CLOUDPROVIDER_BACKOFF_JITTER},
    "cloudProviderRatelimit": ${CLOUDPROVIDER_RATELIMIT},
    "cloudProviderRateLimitQPS": ${CLOUDPROVIDER_RATELIMIT_QPS},
    "cloudProviderRateLimitBucket": ${CLOUDPROVIDER_RATELIMIT_BUCKET},
    "cloudProviderRatelimitQPSWrite": ${CLOUDPROVIDER_RATELIMIT_QPS_WRITE},
    "cloudProviderRatelimitBucketWrite": ${CLOUDPROVIDER_RATELIMIT_BUCKET_WRITE},
    "useManagedIdentityExtension": ${USE_MANAGED_IDENTITY_EXTENSION},
    "userAssignedIdentityID": "${USER_ASSIGNED_IDENTITY_ID}",
    "useInstanceMetadata": ${USE_INSTANCE_METADATA},
    "loadBalancerSku": "${LOAD_BALANCER_SKU}",
    "disableOutboundSNAT": ${LOAD_BALANCER_DISABLE_OUTBOUND_SNAT},
    "excludeMasterFromStandardLB": ${EXCLUDE_MASTER_FROM_STANDARD_LB},
    "providerVaultName": "${KMS_PROVIDER_VAULT_NAME}",
    "maximumLoadBalancerRuleCount": ${MAXIMUM_LOADBALANCER_RULE_COUNT},
    "providerKeyName": "k8s",
    "providerKeyVersion": "",
    "enableMultipleStandardLoadBalancers": ${ENABLE_MULTIPLE_STANDARD_LOAD_BALANCERS},
    "tags": "${TAGS}"
}
EOF
  set -x
  if [[ ${CLOUDPROVIDER_BACKOFF_MODE} == "v2" ]]; then
    sed -i "/cloudProviderBackoffExponent/d" $azure_json
    sed -i "/cloudProviderBackoffJitter/d" $azure_json
  fi
}

installNetworkPlugin() {
  installAzureCNI

  installCNI
  rm -rf $CNI_DOWNLOADS_DIR &
}
installCNI() {
  CNI_TGZ_TMP=${CNI_PLUGINS_URL##*/}
  if [[ ! -f "$CNI_DOWNLOADS_DIR/${CNI_TGZ_TMP}" ]]; then
    downloadCNI
  fi
  mkdir -p $CNI_BIN_DIR
  tar -xzf "$CNI_DOWNLOADS_DIR/${CNI_TGZ_TMP}" -C $CNI_BIN_DIR
  chown -R root:root $CNI_BIN_DIR
  chmod -R 755 $CNI_BIN_DIR
}
installAzureCNI() {
  CNI_TGZ_TMP=${VNET_CNI_PLUGINS_URL##*/}
  if [[ ! -f "$CNI_DOWNLOADS_DIR/${CNI_TGZ_TMP}" ]]; then
    downloadAzureCNI
  fi
  mkdir -p $CNI_CONFIG_DIR
  chown -R root:root $CNI_CONFIG_DIR
  chmod 755 $CNI_CONFIG_DIR
  mkdir -p $CNI_BIN_DIR
  tar -xzf "$CNI_DOWNLOADS_DIR/${CNI_TGZ_TMP}" -C $CNI_BIN_DIR
}

configureCNI() {
  
  retrycmd 120 5 25 modprobe br_netfilter || exit 49
  echo -n "br_netfilter" >/etc/modules-load.d/br_netfilter.conf
  configureAzureCNI
  
}
configureAzureCNI() {
  local tmpDir=$(mktemp -d "$(pwd)/XXX")
  if [[ "${NETWORK_PLUGIN}" == "azure" ]]; then
    mv $CNI_BIN_DIR/10-azure.conflist $CNI_CONFIG_DIR/
    chmod 600 $CNI_CONFIG_DIR/10-azure.conflist
    if [[ iptables == "ipvs" ]]; then
      serviceCidrs=10.0.0.0/16
      jq --arg serviceCidrs $serviceCidrs '.plugins[0]+={serviceCidrs: $serviceCidrs}' "$CNI_CONFIG_DIR/10-azure.conflist" > $tmpDir/tmp
      mv $tmpDir/tmp $CNI_CONFIG_DIR/10-azure.conflist
    fi
    if [[ "${NETWORK_MODE}" == "bridge" ]]; then
      jq '.plugins[0].mode="bridge"' "$CNI_CONFIG_DIR/10-azure.conflist" > $tmpDir/tmp
      jq '.plugins[0].bridge="azure0"' "$tmpDir/tmp" > $tmpDir/tmp2
      mv $tmpDir/tmp2 $CNI_CONFIG_DIR/10-azure.conflist
    else
      jq '.plugins[0].mode="transparent"' "$CNI_CONFIG_DIR/10-azure.conflist" > $tmpDir/tmp
      mv $tmpDir/tmp $CNI_CONFIG_DIR/10-azure.conflist
    fi
    /sbin/ebtables -t nat --list
  fi
  rm -Rf $tmpDir
}
enableCRISystemdMonitor() {
  wait_for_file 1200 1 /etc/systemd/system/docker-monitor.service || exit 6
  systemctlEnableAndStart docker-monitor || exit 4
}
ensureDocker() {
  wait_for_file 1200 1 /etc/systemd/system/docker.service.d/exec_start.conf || exit 6
  usermod -aG docker ${ADMINUSER}
  if [[ $OS != $FLATCAR_OS_NAME ]]; then
    wait_for_file 1200 1 /etc/systemd/system/docker.service.d/clear_mount_propagation_flags.conf || exit 6
  fi
  local daemon_json=/etc/docker/daemon.json
  for i in $(seq 1 1200); do
    if [ -s $daemon_json ]; then
      jq '.' <$daemon_json && break
    fi
    if [ $i -eq 1200 ]; then
      exit 6
    else
      sleep 1
    fi
  done
  systemctlEnableAndStart docker || exit 24
  enableCRISystemdMonitor
}

ensureKubelet() {
  wait_for_file 1200 1 /etc/sysctl.d/11-aks-engine.conf || exit 6
  sysctl_reload 10 5 120 || exit 103
  wait_for_file 1200 1 /etc/default/kubelet || exit 6
  wait_for_file 1200 1 /var/lib/kubelet/kubeconfig || exit 6
  if [[ -n ${MASTER_NODE} ]]; then
    local f=/etc/kubernetes/manifests/kube-apiserver.yaml
    wait_for_file 1200 1 $f || exit 6
    sed -i "s|<advertiseAddr>|$PRIVATE_IP|g" $f
  fi
  wait_for_file 1200 1 /opt/azure/containers/kubelet.sh || exit 6
  systemctlEnableAndStart kubelet || exit 34
  wait_for_file 1200 1 /etc/systemd/system/kubelet-monitor.service || exit 6
  systemctlEnableAndStart kubelet-monitor || exit 34
}

ensureAddons() {
  retrycmd 120 5 30 $KUBECTL get podsecuritypolicy privileged restricted || exit_cse 36 $GET_KUBELET_LOGS
  rm -Rf ${ADDONS_DIR}/init
  replaceAddonsInit
  
  retrycmd 10 5 30 ${KUBECTL} delete pods -l app=kube-addon-manager -n kube-system || \
  retrycmd 120 5 30 ${KUBECTL} delete pods -l app=kube-addon-manager -n kube-system --force --grace-period 0 || \
  exit_cse 36 $GET_KUBELET_LOGS
  
  
  
}
replaceAddonsInit() {
  wait_for_file 1200 1 $ADDON_MANAGER_SPEC || exit 6
  sed -i "s|${ADDONS_DIR}/init|${ADDONS_DIR}|g" $ADDON_MANAGER_SPEC || exit 36
}
ensureLabelNodes() {
  wait_for_file 1200 1 /opt/azure/containers/label-nodes.sh || exit 6
  wait_for_file 1200 1 /etc/systemd/system/label-nodes.service || exit 6
  systemctlEnableAndStart label-nodes || exit 4
}
ensureJournal() {
  {
    echo "Storage=persistent"
    echo "SystemMaxUse=1G"
    echo "RuntimeMaxUse=1G"
    echo "ForwardToSyslog=yes"
  } >>/etc/systemd/journald.conf
  systemctlEnableAndStart systemd-journald || exit 4
}
installKubeletAndKubectl() {
  local binPath=/usr/local/bin
  if [[ $OS == $FLATCAR_OS_NAME ]]; then
    binPath=/opt/bin
  fi
  if [[ ! -f "${binPath}/kubectl-${KUBERNETES_VERSION}" ]] || [[ -n "${CUSTOM_HYPERKUBE_IMAGE}" ]] || [[ -n "${KUBE_BINARY_URL}" ]]; then
    if version_gte ${KUBERNETES_VERSION} 1.17; then
      extractKubeBinaries
    else
      if [[ $CONTAINER_RUNTIME == "docker" ]]; then
        extractHyperkube "docker"
      else
        extractHyperkube "img"
      fi
    fi
  fi
  mv "${binPath}/kubelet-${KUBERNETES_VERSION}" "${binPath}/kubelet"
  mv "${binPath}/kubectl-${KUBERNETES_VERSION}" "${binPath}/kubectl"
  chmod a+x ${binPath}/kubelet ${binPath}/kubectl
  rm -rf ${binPath}/kubelet-* ${binPath}/kubectl-* /home/hyperkube-downloads &
}
ensureK8sControlPlane() {
  if [ -f /var/run/reboot-required ] || [ "$NO_OUTBOUND" = "true" ]; then
    return
  fi
  retrycmd 120 5 25 $KUBECTL 2>/dev/null cluster-info || exit_cse 30 $GET_KUBELET_LOGS
}
ensureEtcd() {
  local etcd_client_url="https://${PRIVATE_IP}:2379"
  retrycmd 120 5 25 curl --cacert /etc/kubernetes/certs/ca.crt --cert /etc/kubernetes/certs/etcdclient.crt --key /etc/kubernetes/certs/etcdclient.key ${etcd_client_url}/v2/machines || exit 11
  wait_for_file 1200 1 /etc/systemd/system/etcd-monitor.service || exit 6
  systemctlEnableAndStart etcd-monitor || exit 4
}
createKubeManifestDir() {
  mkdir -p /etc/kubernetes/manifests
}
writeKubeConfig() {
  local d=/home/$ADMINUSER/.kube
  local f=$d/config
  local server=$KUBECONFIG_SERVER
  mkdir -p $d
  touch $f
  chown $ADMINUSER:$ADMINUSER $d $f
  chmod 700 $d
  chmod 600 $f
  set +x
  echo "
---
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: \"$CA_CERTIFICATE\"
    server: $server
  name: \"$MASTER_FQDN\"
contexts:
- context:
    cluster: \"$MASTER_FQDN\"
    user: \"$MASTER_FQDN-admin\"
  name: \"$MASTER_FQDN\"
current-context: \"$MASTER_FQDN\"
kind: Config
users:
- name: \"$MASTER_FQDN-admin\"
  user:
    client-certificate-data: \"$KUBECONFIG_CERTIFICATE\"
    client-key-data: \"$KUBECONFIG_KEY\"
" >$f
  set -x
}

configAddons() {
  
  
  wait_for_file 1200 1 $POD_SECURITY_POLICY_SPEC || exit 6
  mkdir -p $ADDONS_DIR/init && cp $POD_SECURITY_POLICY_SPEC $ADDONS_DIR/init/ || exit 36
}
cleanUpContainerImages() {
  docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -vE "${ETCD_VERSION}$|${ETCD_VERSION}-|${ETCD_VERSION}_" | grep 'etcd') &
  docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -vE "${KUBERNETES_VERSION}$|${KUBERNETES_VERSION}-|${KUBERNETES_VERSION}_" | grep 'kube-proxy') &
  docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -vE "${KUBERNETES_VERSION}$|${KUBERNETES_VERSION}-|${KUBERNETES_VERSION}_" | grep 'kube-controller-manager') &
  docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -vE "${KUBERNETES_VERSION}$|${KUBERNETES_VERSION}-|${KUBERNETES_VERSION}_" | grep 'kube-apiserver') &
  docker rmi $(docker images --format '{{.Repository}}:{{.Tag}}' | grep -vE "${KUBERNETES_VERSION}$|${KUBERNETES_VERSION}-|${KUBERNETES_VERSION}_" | grep 'kube-scheduler') &
  docker rmi registry:2.7.1 &
  ctr -n=k8s.io image rm $(ctr -n=k8s.io images ls -q) &
}
cleanUpGPUDrivers() {
  rm -Rf $GPU_DEST
  rm -f /etc/apt/sources.list.d/nvidia-docker.list
  apt-key del $(apt-key list | grep NVIDIA -B 1 | head -n 1 | cut -d "/" -f 2 | cut -d " " -f 1)
}
cleanUpContainerd() {
  rm -Rf $CONTAINERD_DOWNLOADS_DIR
}

removeEtcd() {
  rm -rf /usr/bin/etcd
}
exit_cse() {
  local exit_code=$1
  shift
  $@ >> /var/log/azure/cluster-provision.log &
  exit $exit_code
}
