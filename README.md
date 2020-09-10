# adamrushuk Helm Charts Repository

Welcome to the adamrushuk Helm charts repository. All charts are in the charts directory.

## Getting Started

Use the commands below to add this repo and test the charts:

### Sonatype Nexus

```bash
# Add repo
helm repo add adamrushuk https://adamrushuk.github.io/charts
helm repo update
helm repo list

# search
helm search repo adamrushuk
helm search repo adamrushuk/sonatype-nexus --versions

# dry-run (published chart)
helm upgrade test-nexus adamrushuk/sonatype-nexus --install --atomic --namespace test-nexus --debug --dry-run

# dry-run (local chart)
helm upgrade test-nexus ./ --install --atomic --namespace test-nexus --debug --dry-run

# upgrade / install
kubectl create namespace test-nexus
helm upgrade test-nexus adamrushuk/sonatype-nexus --install --atomic --namespace test-nexus --debug

# cleanup
kubectl delete namespace test-nexus
```
