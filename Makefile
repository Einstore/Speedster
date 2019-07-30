REPO = einstore
IMAGE = speedster
TAG = 0.0.1

DEBUG_TAG = local-dev

help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-13s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

run: debug  ## Build & run local dev
	docker run -p 8080:8080 $(REPO)/$(IMAGE):$(DEBUG_TAG)

debug:  ## Build docker image in debug mode
	docker build --build-arg CONFIGURATION="debug" -t $(REPO)/$(IMAGE):$(DEBUG_TAG) .

build:  ## Release build
	docker build -t $(REPO)/$(IMAGE):$(TAG) .

publish: build  ## Publish on docker hub
	docker tag $(REPO)/$(IMAGE):$(TAG) $(REPO)/$(IMAGE):latest
	docker push $(REPO)/$(IMAGE):$(TAG)
	docker push $(REPO)/$(IMAGE):latest
