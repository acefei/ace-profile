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

DOCKER_BUILD=DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) -t $@ --target $@ .

devops-box: ## build container that installed k9s,kubectl,azurecli,helm3
	$(DOCKER_BUILD)
