.PHONY: help
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([^:]+):[^#]+##([^#]+)', line)
	if match:
		target, help = match.groups()
		print("%-10s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

DOCKER_BUILD = DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) -t $@ --target $@ .

# interactive shell 
ifdef $($PS1)
SSH_AGENT_ARGS := -v $(SSH_AUTH_SOCK):/tmp/ssh_auth.sock -e SSH_AUTH_SOCK=/tmp/ssh_auth.sock                      
endif

DIND_ARGS := -v /var/run/docker.sock:/var/run/docker.sock -v $(shell which docker):/bin/docker                    
COMMON_ARGS = $(SSH_AGENT_ARGS) $(DIND_ARGS) -v "$(PWD)":/workdir -w /workdir                                     
DOCKER_RUN = docker run -it $(RUN_ARGS) $(COMMON_ARGS) $<

build-devops-box: 
	$(DOCKER_BUILD)

devops-box: build-devops-box ## run terraform locally
	$(DOCKER_RUN)
