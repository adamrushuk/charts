#! /usr/bin/env bash
#
# Create Helm chart for Nexus

# Vars
CHART_NAME="sonatype-nexus"
HELM_VERSION="3.3.1"



#region Install Helm
# https://helm.sh/docs/intro/install/
# curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version --short

# Download using WGET or CURL
# wget -q -O /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"
curl -L --output /tmp/helm.tar.gz "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz"


# Unpack and move binary (could consider using "install" command)
sudo tar -zxvf /tmp/helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm

# Check version
command -v helm
helm version --short
#endregion Install Helm



#region Create new chart
# Move into chart folder
cd ./charts

# Create new chart
helm create -h
helm create "$CHART_NAME"

# Show template output
cd "$CHART_NAME"
helm template "$CHART_NAME" ./ -f ./values.yaml --atomic --namespace "$CHART_NAME" --debug
#endregion Create new chart



#region Login
az login
az account set --subscription AR-Dev
az account show

# Download aks credentials
az aks get-credentials --resource-group rush-rg-aks-dev-001 --name rush-aks-001 --overwrite-existing --admin

# Check k8s context
kubectl config current-context
#endregion Login



#region Init
# Create namespace
kubectl create namespace "$CHART_NAME"

# Create TLS secret for ingress
# eg: use wildcard cert: *.domain.com
kubectl apply --namespace "$CHART_NAME" -f ../../temp/nexus-secret.yaml
#endregion Init



#region Install
# Show all current resources
kubectl get all,ingress,pvc,pv --namespace "$CHART_NAME"
kubectl describe sts "$CHART_NAME" --namespace "$CHART_NAME"
kubectl describe svc "$CHART_NAME" --namespace "$CHART_NAME"
kubectl describe ingress "$CHART_NAME" --namespace "$CHART_NAME"

# List current Helm releases
helm list
helm list --namespace "$CHART_NAME"
helm history "$CHART_NAME" --namespace "$CHART_NAME"

# Helm diff
# helm diff plugin - preview what a helm upgrade would change
# https://github.com/databus23/helm-diff
# [OPTIONAL] install diff plugin
helm plugin list
helm plugin install https://github.com/databus23/helm-diff --version v3.1.3
helm diff upgrade "$CHART_NAME" --namespace "$CHART_NAME" . --values values.yaml

# Dry-run Upgrade / Install
helm upgrade "$CHART_NAME" ./ -f values.yaml --install --atomic --namespace "$CHART_NAME" --debug --dry-run

# Upgrade / Install
helm upgrade "$CHART_NAME" ./ -f values.yaml --install --atomic --namespace "$CHART_NAME" --debug
#endregion Install



#region Troubleshooting
# Troubleshooting "503 Service Temporarily Unavailable"
# Show all resources
kubectl get all,pvc,pv --namespace "$CHART_NAME"
kubectl describe sts "$CHART_NAME" --namespace "$CHART_NAME"
kubectl describe svc "$CHART_NAME" --namespace "$CHART_NAME"
kubectl describe ingress "$CHART_NAME" --namespace "$CHART_NAME"
#endregion Troubleshooting



# Uninstall
kubectl config current-context
helm uninstall "$CHART_NAME" --namespace "$CHART_NAME" --dry-run
helm uninstall "$CHART_NAME" --namespace "$CHART_NAME"
