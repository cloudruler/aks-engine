# Introduction 
Deploy aks-engine to Azure

#From laptop, SSH to master
MASTER_NODE_NAME=cloudruleraksengine.southcentralus.cloudapp.azure.com
SSH_KEY_NAME=cloudruleradmin
ssh -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME

From laptop, download from master
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/opt/azure/containers/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/opt/azure/containers/provision.sh ./provision.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/opt/azure/containers/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/opt/azure/containers/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/usr/local/bin/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/systemd/system/etcd-monitor.service ./etcd-monitor.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/systemd/system/kubelet.service ./kubelet.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/systemd/system/docker-monitor.service ./docker-monitor.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-addon-manager.yaml ./kube-addon-manager.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-apiserver.yaml ./kube-apiserver.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-controller-manager.yaml ./kube-controller-manager.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-scheduler.yaml ./kube-scheduler.yaml

scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-addon-manager.yaml ./kube-addon-manager.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-apiserver.yaml ./kube-apiserver.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-controller-manager.yaml ./kube-controller-manager.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/manifests/kube-scheduler.yaml ./kube-scheduler.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/audit-policy.yaml ./audit-policy.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/azure-cloud-provider.yaml ./azure-cloud-provider.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/azure-cni-networkmonitor.yaml ./azure-cni-networkmonitor.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/blobfuse-flexvolume.yaml ./blobfuse-flexvolume.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/coredns.yaml ./coredns.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/secrets-store-csi-driver.yaml ./secrets-store-csi-driver.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/ip-masq-agent.yaml ./ip-masq-agent.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/kube-proxy.yaml ./kube-proxy.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/metrics-server.yaml ./metrics-server.yaml
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:/etc/kubernetes/addons/pod-security-policy.yaml ./pod-security-policy.yaml



#Upload SSH key to master
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" ~/.ssh/$SSH_KEY_NAME cloudruleradmin@$MASTER_NODE_NAME:~/.ssh/

ssh -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME

#While logged into master, SSH in to worker
WORKER_NODE_IP=10.240.0.34
SSH_KEY_NAME=cloudruleradmin
chmod 700 ~/.ssh/$SSH_KEY_NAME
ssh -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP

While logged into master, download from worker to master

mkdir worker-configs
cd worker-configs

scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/opt/azure/containers/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/opt/azure/containers/provision.sh ./provision.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/opt/azure/containers/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/opt/azure/containers/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/etc/systemd/system/kubelet-monitor.service ./kubelet-monitor.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/usr/local/bin/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/etc/systemd/system/kubelet.service ./kubelet.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$WORKER_NODE_IP:/etc/systemd/system/docker-monitor.service ./docker-monitor.service

Dwonload from master to local laptop
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/provision.sh ./provision.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/kubelet-monitor.service ./kubelet-monitor.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/kubelet.service ./kubelet.service
scp -i ~/.ssh/$SSH_KEY_NAME -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@$MASTER_NODE_NAME:~/worker-configs/docker-monitor.service ./docker-monitor.service





az group create --name aksengine --location southcentralus

az deployment group create --name "aksengine" --resource-group "aksengine" --template-file "./_output/cloudruleraksengine/azuredeploy.json" --parameters "./_output/cloudruleraksengine/azuredeploy.parameters.json"

