# Variables
APP := bot
REGISTRY := ghcr.io
REPOSITORY := sadko-vadym/blank-problem
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "v1.0.0")
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
TARGETOS ?= linux
TARGETARCH ?= amd64

# Full image tag
IMAGE_TAG := $(VERSION)-$(COMMIT)-$(TARGETOS)-$(TARGETARCH)
IMAGE := $(REGISTRY)/$(REPOSITORY):$(IMAGE_TAG)

.PHONY: all build image push clean helm-package

all: build

# Build Go binary
build:
	@echo "Building $(APP)..."
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build \
		-ldflags "-X main.AppVersion=$(VERSION)-$(COMMIT)" \
		-o $(APP) ./cmd/bot

# Build Docker image
image:
	@echo "Building Docker image $(IMAGE)..."
	docker build \
		--build-arg TARGETOS=$(TARGETOS) \
		--build-arg TARGETARCH=$(TARGETARCH) \
		--build-arg VERSION=$(VERSION)-$(COMMIT) \
		-t $(IMAGE) .

# Push Docker image
push: image
	@echo "Pushing $(IMAGE)..."
	docker push $(IMAGE)

# Update Helm chart values
helm-update:
	@echo "Updating Helm chart with tag $(VERSION)-$(COMMIT)..."
	@sed -i 's|tag:.*|tag: "$(VERSION)-$(COMMIT)"|' bot/values.yaml
	@sed -i 's|os:.*|os: $(TARGETOS)|' bot/values.yaml
	@sed -i 's|arch:.*|arch: $(TARGETARCH)|' bot/values.yaml

# Package Helm chart
helm-package:
	@echo "Packaging Helm chart..."
	helm package bot

# Clean build artifacts
clean:
	@echo "Cleaning..."
	rm -f $(APP)
	rm -f *.tgz

# Get dependencies
deps:
	go mod download
	go mod tidy

# Print image name
print-image:
	@echo $(IMAGE)

# Print version
print-version:
	@echo $(VERSION)-$(COMMIT)

