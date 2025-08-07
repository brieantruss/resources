
Install/Uninstall>Install

On the master node (modulo-0):

Bash

sudo /usr/local/bin/k3s-uninstall.sh
On the agent nodes (modulo-1, modulo-2, modulo-3):

Bash

sudo /usr/local/bin/k3s-agent-uninstall.sh
Reinstall K3s on the master node (modulo-0).

Bash

curl -sfL https://get.k3s.io | sh -
Get the new node token.

Bash

sudo cat /var/lib/rancher/k3s/server/node-token
Reinstall K3s on the agent nodes (modulo-1, modulo-2, modulo-3).

Bash

curl -sfL https://get.k3s.io | K3S_URL=https://modulo-0:6443 K3S_TOKEN=<NEW_NODE_TOKEN> sh -

# Commands (on master)

sudo kubectl apply -f /home/modulo/k3s-manifests/
sudo kubectl get deployments
sudo kubectl get services
sudo kubectl get pods


Flush ip tables (all nodes)

sudo iptables -F
sudo iptables -X
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -P INPUT ACCEPT
sudo iptables -P FORWARD ACCEPT
sudo iptables -P OUTPUT ACCEPT


# Helm Install

sudo curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

## Add the Prometheus community charts repository and update it.

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update


# Prometheus and Grafana Install (on master node)

## Install
 
 2126  sudo KUBECONFIG=/etc/rancher/k3s/k3s.yaml helm install prometheus-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace --set grafana.service.type=NodePort

## Get NodePort port #

 2127  sudo kubectl get service prometheus-stack-grafana -n monitoring
 
## Get password
 2128  sudo kubectl get secret prometheus-stack-grafana -n monitoring -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
