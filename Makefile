SHELL := /bin/bash

# Configuration variables
DATA_DIR := /nas
TOOLS_DIR := /extras2
HOME_MOUNT := $(HOME)
#### COPY THE SIEMENS SCRIPT FROM THE CURRENT DIRECTORY TO ~/bin/siemens.sh (PLEASE ADAPT IT TO YOUR NEEDS)
SIEMENS_ENV_SCRIPT := $(HOME_MOUNT)/bin/siemens.sh
WORK_DIR ?=  # Optional: set to change to this directory on startup

# Catapult options (all optional)
CATAPULT_SCRIPT ?=    # -file <file>    : source a Tcl script after invoking
CATAPULT_CMD ?=       # -eval <command> : evaluate a Tcl command after invoking
CATAPULT_PROJECT ?=   # <project>       : project file to open

CATAPULT_OPTS := $(if $(CATAPULT_CMD),-eval '$(CATAPULT_CMD)') \
                 $(if $(CATAPULT_SCRIPT),-file $(CATAPULT_SCRIPT)) \
                 $(CATAPULT_PROJECT)

# Container variables
APPTAINER_FLAGS := --contain --no-mount hostfs  # Isolate container, disable auto-mounts
BIND_MOUNTS := --bind $(TOOLS_DIR):$(TOOLS_DIR) --bind $(DATA_DIR):$(DATA_DIR) --bind $(HOME_MOUNT) --bind /tmp # Explicit mounts only
SHELL_BIN := /bin/bash

# Build variables
BUILD_FLAGS := --force --fakeroot  # Overwrite existing, unprivileged build

# Functions
define check_path
	@if [ ! -$(1) "$(2)" ]; then \
		echo "Error: $(2) does not exist"; \
		exit 1; \
	fi
endef

all: build
.PHONY: all

build: catapult_rocky.sif
.PHONY: build

catapult_rocky.sif: containers/apptainer_catapult_rocky.def
	@echo "Building catapult_rocky.sif..."
	@apptainer build $(BUILD_FLAGS) catapult_rocky.sif containers/apptainer_catapult_rocky.def 2>&1 | tee catapult_rocky_build.log; \
		if [ $${PIPESTATUS[0]} -ne 0 ]; then \
			echo "Error: Failed to build catapult_rocky.sif. See catapult_rocky_build.log for details."; \
			exit 1; \
		fi

catapult-gui: catapult_rocky.sif
	$(call check_path,d,$(TOOLS_DIR))
	$(call check_path,d,$(HOME_MOUNT))
	$(call check_path,f,$(SIEMENS_ENV_SCRIPT))
	$(if $(WORK_DIR),$(call check_path,d,$(WORK_DIR)))
	apptainer exec $(APPTAINER_FLAGS) $(if $(WORK_DIR),--pwd $(WORK_DIR)) $(BIND_MOUNTS) catapult_rocky.sif $(SHELL_BIN) -c "source $(HOME_MOUNT)/bin/siemens.sh && /usr/local/bin/show-splash.sh && catapult $(CATAPULT_OPTS)"
.PHONY: catapult-gui

catapult-shell: catapult_rocky.sif
	$(call check_path,d,$(TOOLS_DIR))
	$(call check_path,d,$(HOME_MOUNT))
	$(call check_path,f,$(SIEMENS_ENV_SCRIPT))
	$(if $(WORK_DIR),$(call check_path,d,$(WORK_DIR)))
	apptainer exec $(APPTAINER_FLAGS) $(if $(WORK_DIR),--pwd $(WORK_DIR)) $(BIND_MOUNTS) catapult_rocky.sif $(SHELL_BIN) -c "source $(HOME_MOUNT)/bin/siemens.sh && /usr/local/bin/show-splash.sh && catapult -shell $(CATAPULT_OPTS)"
.PHONY: catapult-shell

container-shell: catapult_rocky.sif
	$(call check_path,d,$(TOOLS_DIR))
	$(call check_path,d,$(HOME_MOUNT))
	$(if $(WORK_DIR),$(call check_path,d,$(WORK_DIR)))
	apptainer exec $(APPTAINER_FLAGS) --pwd $(or $(WORK_DIR),$(CURDIR)) $(BIND_MOUNTS) catapult_rocky.sif $(SHELL_BIN) -c "/usr/local/bin/show-splash.sh && exec $(SHELL_BIN)"
.PHONY: container-shell

stop:
	@echo "Stopping all running container instances..."
	@apptainer instance list | grep -q catapult_rocky.sif && \
		apptainer instance list | awk '/catapult_rocky.sif/ {print $$1}' | xargs -r apptainer instance stop || \
		echo "No running instances found."
.PHONY: stop

clean: stop
	@echo "Cleaning up container images..."
	rm -rf catapult_rocky.sif catapult_rocky_build.log
	@echo "Clean complete."
.PHONY: clean
