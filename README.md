# Introduction 
Deploy aks-engine to Azure

scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision.sh ./provision.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/usr/local/bin/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/etcd-monitor.service ./etcd-monitor.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/kubelet.service ./kubelet.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/docker-monitor.service ./docker-monitor.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/kubernetes/manifests/kube-addon-manager.yaml ./kube-addon-manager.yaml
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/kubernetes/manifests/kube-apiserver.yaml ./kube-apiserver.yaml
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/kubernetes/manifests/kube-controller-manager.yaml ./kube-controller-manager.yaml
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/kubernetes/manifests/kube-scheduler.yaml ./kube-scheduler.yaml

#Upload
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" C:\Users\brian\.ssh\id_rsa cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:~/.ssh/
#SSH in
ssh -i ~/.ssh/id_rsa cloudruleradmin@10.240.0.4
chmod 700 ~/.ssh/id_rsa

Download from worker to master
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/opt/azure/containers/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/opt/azure/containers/provision.sh ./provision.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/opt/azure/containers/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/opt/azure/containers/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/etc/systemd/system/kubelet-monitor.service ./kubelet-monitor.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/usr/local/bin/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/etc/systemd/system/kubelet.service ./kubelet.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@10.240.0.4:/etc/systemd/system/docker-monitor.service ./docker-monitor.service

Dwonload from master to local laptop
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_source.sh ./provision_source.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision.sh ./provision.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_installs.sh ./provision_installs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/opt/azure/containers/provision_configs.sh ./provision_configs.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/kubelet-monitor.service ./kubelet-monitor.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/usr/local/bin/health-monitor.sh ./health-monitor.sh
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/kubelet.service ./kubelet.service
scp -i ~/.ssh/id_rsa -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no" cloudruleradmin@cloudruleraksengine.southcentralus.cloudapp.azure.com:/etc/systemd/system/docker-monitor.service ./docker-monitor.service



az deployment group create --name "aksengine" --resource-group "aksengine" --template-file "./_output/cloudruleraksengine/azuredeploy.json" --parameters "./_output/cloudruleraksengine/azuredeploy.parameters.json"