# Simple Makefile for a Go project

# Unity Catalog Submodule version
UC_VERSION := 0.2.0
UC_TAG := v$(UC_VERSION)

# Determine if we need platform flag (for ARM-based systems)
# Unity Catalog's docker container does not currently build for ARM systems.
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
    PLATFORM_FLAG := --platform linux/x86_64/v8
else
    PLATFORM_FLAG :=
endif

# Build the application
all: submodules generate build uc-docker test

submodules:
	@git submodule update --init --recursive
	@git -C submodules/unity_catalog checkout $(UC_TAG)

clean-submodules:
	@rm -rf submodules/unity_catalog

build:
	@echo "Building..."
	@go build -o main cmd/api/main.go

# Run the application
run:
	@go run cmd/api/main.go

# Test the application
test:
	@echo "Testing..."
	@go test ./... -v

# Clean the binary
clean:
	@echo "Cleaning..."
	@rm -f main

# Generate golang code for unity catalog client
generate:
	@echo "Generating unity catalog client code..."
	@go generate ./...

# Create a unity catalog docker container. Required for
uc-docker:
	# TODO: Remove platform target when possible, UC image does not build on ARM.
	@docker build -t unitycatalog/$(UC_VERSION) $(PLATFORM_FLAG) submodules/unity_catalog

# Run Unity Catalog in a docker container that's ephemeral, only for testing.
run-uc:
	@docker run -p 8080:8080 unitycatalog/$(UC_VERSION)

.PHONY: all submodules build run test clean generate uc-docker run-uc
