# Simple Makefile for a Go project

# Unity Catalog Submodule version
UC_VERSION := 0.2.0
UC_TAG := v$(UC_VERSION)

# Version of ANTLR used to generate Go code
ANTLR_URL := https://www.antlr.org/download/antlr-4.13.2-complete.jar
ANTLR_JAR := bin/antlr.jar

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

# Download ANTLR jar
antlr-download:
	@echo "Downloading ANTLR jar..."
	@if command -v curl > /dev/null; then \
		curl -L -o $(ANTLR_JAR) $(ANTLR_URL); \
	elif command -v wget > /dev/null; then \
		wget -O $(ANTLR_JAR) $(ANTLR_URL); \
	else \
		echo "Error: Neither curl nor wget is installed."; \
		exit 1; \
	fi
	@echo "ANTLR jar downloaded to $(ANTLR_JAR)"

# Generate ANTLR lexer and parser
antlr:
	@java -jar $(ANTLR_JAR) -Dlanguage=Go internal/parser/antlr/SqlBaseLexer.g4
	@java -jar $(ANTLR_JAR) -Dlanguage=Go internal/parser/antlr/SqlBaseParser.g4

# Clean ANTLR files
antlr-clean:
	@rm -f internal/parser/antlr/sqlbase_lexer.go
	@rm -f internal/parser/antlr/sqlbase_parser.go
	@rm -f internal/parser/antlr/sqlbaseparser_*.go
	@rm -f internal/parser/antlr/SqlBaseLexer.interp
	@rm -f internal/parser/antlr/SqlBaseLexer.tokens
	@rm -f internal/parser/antlr/SqlBaseParser.interp
	@rm -f internal/parser/antlr/SqlBaseParser.tokens

build:
	@echo "Building..."
	@go build -o main cmd/main.go

# Run the application
run:
	@go run cmd/main.go

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

.PHONY: all submodules antlr-download antlr antlr-clean build run test clean generate uc-docker run-uc
