# Set the shell to bash always
SHELL := /bin/bash

# Options
ORG_NAME=crossplane
PROVIDER_NAME=crossplane-provider-tinkerbell

build: generate test
	@CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o ./bin/$(PROVIDER_NAME)-controller cmd/provider/main.go

image: generate test
	docker build . -t $(ORG_NAME)/$(PROVIDER_NAME):latest -f cluster/Dockerfile

image-push:
	docker push $(ORG_NAME)/$(PROVIDER_NAME):latest

run: generate
	kubectl apply -f package/crds/ -R
	go run cmd/provider/main.go -d

all: image image-push install

generate:
	go generate ./...

lint:
	$(LINT) run

tidy:
	go mod tidy

test:
	go test -v ./...

# Tools

KIND=$(shell which kind)
LINT=$(shell which golangci-lint)

.PHONY: generate tidy lint clean build image all run