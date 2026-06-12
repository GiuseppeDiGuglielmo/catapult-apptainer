# Catapult Apptainer

Apptainer container environment for running Siemens Catapult HLS on Rocky Linux 8.10.

## Contents

- `containers/apptainer_catapult_rocky.def` — container definition (Rocky 8.10 base, X11, Java, Python, ZeroMQ)
- `Makefile` — build and launch targets
- `templates/` — files to copy into your project directory (see [Templates](#templates))

## Usage

Build the container image:

```sh
make build
```

Open a plain shell inside the container:

```sh
make container-shell
```

Launch Catapult GUI (requires `~/bin/siemens.sh`):

```sh
make catapult-gui
```

Launch Catapult in shell mode:

```sh
make catapult-shell
```

### Optional variables

| Variable | Description |
|---|---|
| `WORK_DIR` | Start the shell in this directory (must be accessible on the host) |
| `CATAPULT_SCRIPT` | Tcl script to source on startup (`-file`) |
| `CATAPULT_CMD` | Tcl command to evaluate on startup (`-eval`) |
| `CATAPULT_PROJECT` | Project file to open |

## Templates

Copy the files under `templates/` to get started quickly:

| File | Destination | Purpose |
|---|---|---|
| `templates/siemens.sh` | `~/bin/siemens.sh` | Siemens tool environment; adapt paths and version |
| `templates/run_container.sh` | anywhere in your project | Wrapper script to launch the container from a project directory; set `CONTAINER_DIR` at the top |

## Requirements

- [Apptainer](https://apptainer.org/) installed on the host
- Siemens Catapult installed under `/mnt/local/gdg/tools/cad/siemens/catapult/`
- `~/bin/siemens.sh` configured for your environment (for `catapult-gui` / `catapult-shell`)
