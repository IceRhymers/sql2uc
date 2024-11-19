# Simple Makefile for a Go project

UC_TAG := v0.2.0

# Build the application
all: submodules generate build test

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

uc-docker:
	# TODO: Find a better way to tag this container
	# TODO: Remove platform target when possible, UC image does not build on ARM.
	@docker build -t unitycatalog/0.2.0 --platform linux/x86_64/v8 submodules/unity_catalog

# Live Reload
watch:
	@if command -v air > /dev/null; then \
			air; \
			echo "Watching...";\
		else \
			read -p "Go's 'air' is not installed on your machine. Do you want to install it? [Y/n] " choice; \
			if [ "$$choice" != "n" ] && [ "$$choice" != "N" ]; then \
				go install github.com/air-verse/air@latest; \
				air; \
				echo "Watching...";\
			else \
				echo "You chose not to install air. Exiting..."; \
				exit 1; \
			fi; \
		fi

.PHONY: all submodules build run test clean generate watch
