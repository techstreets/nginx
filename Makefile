IMAGE_NAME := nginx
IMAGE_TAG := 1.15.0
CONTAINER_NAME := nginx
ENV_FILE_NAME := nginx_env
HOST_PORT := 80

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

MAKE_DIR := $(strip $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST)))))

ifndef ${ENV_FILE_NAME}
	ifeq ($(shell test -s ./env && echo -n yes),yes)
		ENV_FILE := $(abspath ./env)
	else
		ENV_FILE := /dev/null
	endif
else
	ENV_FILE := ${${ENV_FILE_NAME}}
endif

.PHONY: all clean create kill start stop restart shell docker_ip

all: create restart

clean:
	docker images $(IMAGE_NAME) | grep -q $(IMAGE_TAG) && docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true

create:
	docker run --name $(CONTAINER_NAME) --restart=always --env-file $(ENV_FILE) -d -p $(HOST_PORT):80 -v $(MAKE_DIR)/config/nginx.conf:/etc/nginx/conf.d/default.conf:ro $(IMAGE_NAME):$(IMAGE_TAG)

kill:
	docker stop $(CONTAINER_NAME) && docker rm $(CONTAINER_NAME)

start:
	docker start $(CONTAINER_NAME)

stop:
	docker stop $(CONTAINER_NAME)

restart:
	docker restart $(CONTAINER_NAME)

shell:
	docker exec -it $(CONTAINER_NAME) bash

docker_ip:
	@ip addr show docker0 | grep "inet\b" | awk '{print $2}' | cut -d/ -f1
