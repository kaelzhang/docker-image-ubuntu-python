export UBUNTU_VERSION=16.04
export PYTHON_SHORT_VERSION=3.8

build:
	docker build \
	-t ostai/ubuntu-python:$(UBUNTU_VERSION)-$(PYTHON_SHORT_VERSION) \
	.
