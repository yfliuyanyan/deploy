# install k3s cluster
export INSTALL_K3S_EXEC="server --disable traefik --flannel-backend=none \
      --node-label gitpod.io/workload_meta=true \
      --node-label gitpod.io/workload_ide=true \
      --node-label gitpod.io/workload_workspace_regular=true \
      --node-label gitpod.io/workload_workspace_headless=true \
      --node-label gitpod.io/workload_workspace_services=true"
curl -sfL https://get.k3s.io | sh -
k3s -version

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
alias k="k3s kubectl"

# install calico
k create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/tigera-operator.yaml
k create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/custom-resources.yaml

# check node status
k get node -owide

# install cert-mamager
k apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
k get pod -A

#TODO Configure root domain (@) and two wildcard subdomains (* and *.ws) from the DNS provider, pointing to the public IP of the VM. Make some digs to check if the settings work.
# dig <mygitpod.domain>
# dig test.<mygitpod.domain>
which dig

# TODO Create API Token from the DNS provider console (I was using DNSPod).

# snap install helm

# Install cert-manager-webhook-dnspod using Helm with custom options.
# git clone --depth 1 https://github.com/qqshfox/cert-manager-webhook-dnspod.git# helm install --name cert-manager-webhook-dnspod ./deploy/cert-manager-webhook-dnspod \
#      --namespace cert-manager \
#      --set groupName=<GROUP_NAME> \
#      --set secrets.apiID=<DNSPOD_API_ID>,secrets.apiToken=<DNSPOD_API_TOKEN> \
#      --set clusterIssuer.enabled=true,clusterIssuer.email=<EMAIL_ADDRESS>

# create cloudflare-token-secret
k apply -f https://raw.githubusercontent.com/yfliuyanyan/deploy/main/cloudflare-token-secret.yaml
# create cert-manager-issuer
k apply -f https://raw.githubusercontent.com/yfliuyanyan/deploy/main/cert-manager-issuer.yaml

#Check the generated ClusterIssuer. If the “READY” state keeps False, describe the ClusterIssuer to see if there is an exception.
k get ClusterIssuer -A

#k describe ClusterIssuer cert-manager-webhook-dnspod-cluster-issuer -n cert-manager

#Create a Certificate.
k apply -f https://raw.githubusercontent.com/yfliuyanyan/deploy/main/cert.yaml
#Wait for the certificate’s “READY” state to become True (could be minutes).
k get cert -A

# Check and validate the certificate (optional). tls.key / tls.crt can be found in secret my-crt-secret
k describe cert my-crt -n cert-manager

#dump certificates if you need
#k get secret mytest1111-cloud-crt-secret -n cert-manager -o jsonpath='{.data.tls\.crt}' | base64 -d

# Install Gitpod
#Install kots plugin & install Gitpod using kots.

curl https://kots.io/install | bash
k kots install gitpod

#Admin-console listened on localhost:8800 only, so setup an Nginx server to proxy the requests.


