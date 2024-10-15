all: test lint trivy build-helm

build-helm: update-dependencies
	helm package charts/vaultwarden -d build

test: update-dependencies
	helm unittest charts/vaultwarden

lint: update-dependencies
	helm lint charts/vaultwarden

trivy: update-dependencies
	trivy config --helm-values trivy.values.yaml charts/vaultwarden

clean:
	rm -rf build
	rm -rf charts/vaultwarden/charts

update-dependencies:
	helm dependency update charts/vaultwarden
