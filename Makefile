all: test lint trivy build-helm

build-helm: update-dependencies
	helm package chart -d build

test: update-dependencies
	helm unittest chart

lint: update-dependencies
	helm lint chart

trivy: update-dependencies
	trivy config --helm-values trivy.values.yaml chart

clean:
	rm -rf build
	rm -rf chart/charts

update-dependencies:
	helm dependency update chart
