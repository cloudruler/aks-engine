#!/bin/bash
ERR_FILE_WATCH_TIMEOUT=6 

set -x
if [ -f /opt/azure/containers/provision.complete ]; then
  exit 0
fi

echo $(date),$(hostname), startcustomscript >>/opt/m

for i in $(seq 1 3600); do
  if [ -s /opt/azure/containers/provision_source.sh ]; then
    grep -Fq '#HELPERSEOF' /opt/azure/containers/provision_source.sh && break
  fi
  if [ $i -eq 3600 ]; then
    exit 6
  else
    sleep 1
  fi
done
sed -i "/#HELPERSEOF/d" /opt/azure/containers/provision_source.sh
source /opt/azure/containers/provision_source.sh
configure_prerequisites

wait_for_file 3600 1 /opt/azure/containers/provision_installs.sh || exit 6
source /opt/azure/containers/provision_installs.sh

ensureAPMZ "v0.5.1"
eval "$(apmz bash -d)"


wait_for_file 3600 1 /opt/azure/containers/provision_configs.sh || exit 6
source /opt/azure/containers/provision_configs.sh

set +x
ETCD_PEER_CERT=$(echo ${ETCD_PEER_CERTIFICATES} | cut -d'[' -f 2 | cut -d']' -f 1 | cut -d',' -f $((NODE_INDEX + 1)))
ETCD_PEER_KEY=$(echo ${ETCD_PEER_PRIVATE_KEYS} | cut -d'[' -f 2 | cut -d']' -f 1 | cut -d',' -f $((NODE_INDEX + 1)))
set -x

time_metric "ConfigureAdminUser" configureAdminUser
time_metric "CleanupContainerd" cleanUpContainerd
  
time_metric "CleanupGPUDrivers" cleanUpGPUDrivers
  


VHD_LOGS_FILEPATH=/opt/azure/vhd-install.complete
if [ -f $VHD_LOGS_FILEPATH ]; then
  time_metric "CleanUpContainerImages" cleanUpContainerImages
  FULL_INSTALL_REQUIRED=false
else
  if [[ ${IS_VHD} == true ]]; then
    exit 186
  fi
  FULL_INSTALL_REQUIRED=true
fi

if [[ ${UBUNTU_RELEASE} == "18.04" ]]; then
  if apt list --installed | grep 'chrony'; then
    time_metric "ConfigureChrony" configureChrony
    time_metric "EnsureChrony" ensureChrony
  fi
fi

if [[ $OS == $UBUNTU_OS_NAME ]]; then
  time_metric "EnsureAuditD" ensureAuditD
fi

if [[ $OS != $FLATCAR_OS_NAME ]]; then
time_metric "installMoby" installMoby

fi

if [[ -n ${MASTER_NODE} ]] && [[ -z ${COSMOS_URI} ]]; then
  cli_tool="docker"
  
  time_metric "InstallEtcd" installEtcd $cli_tool
fi


time_metric "InstallNetworkPlugin" installNetworkPlugin

time_metric "InstallKubeletAndKubectl" installKubeletAndKubectl

if [[ $OS != $FLATCAR_OS_NAME ]]; then
    time_metric "EnsureRPC" ensureRPC
    time_metric "EnsureCron" ensureCron
fi

time_metric "CreateKubeManifestDir" createKubeManifestDir


if [[ -n ${MASTER_NODE} ]] && [[ -z ${COSMOS_URI} ]]; then
  time_metric "ConfigureEtcdUser" configureEtcdUser
fi

if [[ -n ${MASTER_NODE} ]]; then
  
  
  time_metric "ConfigureSecrets" configureSecrets
fi


if [[ -n ${MASTER_NODE} ]] && [[ -z ${COSMOS_URI} ]]; then
  time_metric "ConfigureEtcd" configureEtcd
else
  time_metric "RemoveEtcd" removeEtcd
fi
time_metric "EnsureDocker" ensureDocker


time_metric "ConfigureK8s" configureK8s

time_metric "ConfigureCNI" configureCNI

if [[ -n ${MASTER_NODE} ]]; then
  time_metric "ConfigAddons" configAddons
  time_metric "WriteKubeConfig" writeKubeConfig
fi





time_metric "EnsureKubelet" ensureKubelet

time_metric "EnsureJournal" ensureJournal

if [[ -n ${MASTER_NODE} ]]; then
  if version_gte ${KUBERNETES_VERSION} 1.16; then
    time_metric "EnsureLabelNodes" ensureLabelNodes
  fi
  if [[ -z ${COSMOS_URI} ]]; then
    time_metric "EnsureEtcd" ensureEtcd
  fi
  time_metric "EnsureK8sControlPlane" ensureK8sControlPlane
  if [ -f /var/run/reboot-required ]; then
    time_metric "ReplaceAddonsInit" replaceAddonsInit
  else
    time_metric "EnsureAddons" ensureAddons
  fi
fi
rm -f /etc/apt/apt.conf.d/99periodic
if [[ $OS == $UBUNTU_OS_NAME ]]; then
  time_metric "PurgeApt" apt_get_purge apache2-utils &
fi

apt_get_update && unattended_upgrade

if [ -f /var/run/reboot-required ]; then
  trace_info "RebootRequired" "reboot=true"
  /bin/bash -c "shutdown -r 1 &"
  if [[ $OS == $UBUNTU_OS_NAME ]]; then
    aptmarkWALinuxAgent unhold &
  fi
else
  if [[ $OS == $UBUNTU_OS_NAME ]]; then
    /usr/lib/apt/apt.systemd.daily &
    aptmarkWALinuxAgent unhold &
  fi
fi

echo "CSE finished successfully"
echo $(date),$(hostname), endcustomscript >>/opt/m
mkdir -p /opt/azure/containers && touch /opt/azure/containers/provision.complete
ps auxfww >/opt/azure/provision-ps.log &

exit 0

#EOF
