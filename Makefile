SHELL := /bin/bash
NAME := distroless-libpq5-debian11
CONTAINER_NAME := i0nw/distroless:libpq5-debian11

REV := $(shell git rev-parse --short HEAD 2> /dev/null || echo 'unknown')
BRANCH     := $(shell git rev-parse --abbrev-ref HEAD 2> /dev/null  || echo 'unknown')
BUILD_DATE := $(shell date +%Y%m%d-%H:%M:%S)
BUILD_USER := $(shell whoami)

all: build

check: fmt build test

version:
ifeq (,$(wildcard pkg/version/VERSION))
TAG := $(shell git fetch --all -q 2>/dev/null && git describe --abbrev=0 --tags 2>/dev/null)
ON_EXACT_TAG := $(shell git name-rev --name-only --tags --no-undefined HEAD 2>/dev/null | sed -n 's/^\([^^~]\{1,\}\)\(\^0\)\{0,1\}$$/\1/p')
VERSION := $(shell [ -z "$(ON_EXACT_TAG)" ] && echo "$(TAG)-dev-$(REV)" | sed 's/^v//' || echo "$(TAG)" | sed 's/^v//' )
else
VERSION := $(shell cat pkg/version/VERSION)
endif

DOCKER_NETWORK := $(shell docker network ls --filter name=${NAME} -q)

print-version: version
	@echo $(VERSION)

print-rev:
	@echo $(REV)

print-branch:
	@echo $(BRANCH)

print-build-date:
	@echo $(BUILD_DATE)

print-build-user:
	@echo $(BUILD_USER)

docker-build: print-version print-rev print-branch
	docker build . -t ${CONTAINER_NAME}

docker-push:
	docker push ${CONTAINER_NAME}

clean:
	rm -rf target

# This will stop make linking directories with these names to make commands
.PHONY: all test clean
