# Catapult 2026.3_1 — Environment Requirements

Requirements extracted from the Siemens documentation for Catapult Synthesis
2026.3_1 (September 2026), for the container image built by
`containers/apptainer_catapult_rocky.def`.

Source documents (not tracked in git — download from
[Siemens SupportCenter](https://support.sw.siemens.com/) and drop them in this
directory):

| File | Document |
|---|---|
| `catapult_install.pdf` | Catapult Synthesis Installation Manual, 2026.3_1 |
| `catapult_relnotes.pdf` | Catapult Synthesis Release Notes, 2026.3_1 |
| `release_highlights.pdf` | Catapult Release Highlights |

The manuals do **not** publish an RPM package list. They state the supported OS,
the 32-bit compatibility requirement, and a third-party software matrix; the
package mapping below is our translation of those statements onto Rocky 8.10.

## Summary of changes since 2026.3

2026.3_1 is a bug-fix update: three customer issues fixed (CAT-47792,
CAT-47598, CAT-46916) and no directive, pragma, option, or command changes.

- **No change to the OS or package requirements**, nor to the third-party
  software matrix: every version in the "Software Compatibility" table is the
  same as in 2026.3. The container definition is used unchanged.
- **Licensing text updated**: the recommended Siemens License Server package
  moves from v5.2 to **v5.3.0** (still saltd 11.19.8.4 or later), and the
  installation manual now agrees with the release notes on the saltd version.
- `templates/siemens.sh` now defaults to `CATAPULT_VER=2026.3_1`.
- **`create_catapult_py_venv.sh` is broken in this release**: it calls a
  Python interpreter the release does not ship. See "HLS4ML Python virtual
  environment" below for the workaround.
- **The HLS4ML venv location now comes from `$HLS4ML_VENV`**, falling back
  to `$HOME/ccs_venv` (release notes, Option Changes).
  `templates/siemens.sh` suggests a per-release venv.

For the changes from 2026.2_1 to 2026.3 (Questa 2025.3, Design Compiler
X-2025.06, Vivado 2025.2, ...), see `doc/siemens/2026.3/README.md`.

## Operating system

- **Rocky Linux 8.10 only.** From 2023.2 onward Catapult supports only the
  latest minor version of a major release; Red Hat 7 support ended after
  2024.1. Rocky 8.10 goes EOL in May 2029.
- 64-bit Catapult requires 64-bit Linux on a 64-bit CPU.
- Supported windowing systems: **KDE** and **Gnome**. The GUI and the graphical
  installer need a valid `DISPLAY`; with `DISPLAY` unset or invalid, both the
  installer and the Setup Wizard fall back to batch mode.

## 32-bit (i686) runtime — required

Catapult compiles the C/C++ design in **32-bit compatibility mode by default**
(`Input/TargetPlatform`), and the release notes are explicit: *"If 32-bit mode
is used, the 32-bit libraries must be available for the assembler and linker."*
Downstream simulators (QuestaSim etc.) must be built in the same mode.

This is the reason for the i686 packages in the definition file:

```
glibc.i686  glibc-devel.i686  libgcc.i686  libstdc++.i686  libstdc++-devel.i686
libX11.i686  libXext.i686  libXft.i686  libXi.i686  libXrender.i686
libXtst.i686  libxcb.i686
```

## Licensing (saltd / FlexNet)

- Catapult uses the **saltd** license daemon: **11.19.0.1 minimum, 11.19.8.4 or
  later recommended** (Siemens License Server v5.3.0).
- The release notes and the license file example in the installation manual
  place the bundled daemon at
  `$MGC_HOME/pkgs/FlexNet-11-19-5/Lnx64_x86-64/saltd`; the requirements
  chapter of the installation manual instead says the tree ships FlexNet
  11.19.8. Check `$MGC_HOME/pkgs/` in the installed tree for the actual
  directory. Either way, no license software has to be installed into the
  image — but the FlexLM tools (`lmgrd`, `lmstat`, `lmhostid`, `lmdown`) need
  `redhat-lsb-core`, `net-tools`, and a resolvable hostname to run inside the
  container.
- License lookup order: `-salt_license_server` → `-mgls_license_file` →
  `SALT_LICENSE_SERVER` → `MGLS_LICENSE_FILE` → `LM_LICENSE_FILE`. The
  installer ignores `SALT_LICENSE_SERVER` and prefers `MGLS_LICENSE_FILE`.
  Set these in `~/bin/siemens.sh` (see `templates/siemens.sh`), and make sure
  the license server port/host is reachable from inside the container.

## Toolchain shipped with Catapult (do not duplicate in the image)

These come from the Catapult install tree under `Mgc_home` and do not need OS
packages:

| Component | Version |
|---|---|
| gcc | 13.4.0 (4.9.2 also shipped, for the legacy MATLAB flow) |
| gdb | 15.2 |
| SystemC (OSCI) | 2.3.3 |
| SystemC TLM headers | 2.0 |
| AC Datatypes / AC Math / DSP / IPL / Comm / Video / Sim Util | 2026.3 |
| MatchLib Connections | 2026.3 |
| Oasys-RTL | 2021.1-s001 |
| Precision RTL | 2026.2.0.6 |
| Catapult Coverage (CCOV) | 2026.2 |
| CCoverCheck, C Design Checker, Catapult Formal | 2026.2_2 |
| SLECPro | 2026.2_1 |
| PowerPro | 2025.4_1 in the table; the change list says 2026.2_1 |

## OS packages the flows actually need

| Need | Packages | Why (per the docs) |
|---|---|---|
| X11 GUI | `libXext`, `libXft`, `libXtst`, `libXi`, `xorg-x11-server-Xvfb` | GUI + graphical installer under KDE/Gnome; Xvfb for headless batch runs that still want a display |
| SCVerify flow | `make`, `gcc`, `gcc-c++` | *"The SystemC library and Make utility are only needed for the Catapult SCVerify flow"* |
| Help system | `xdg-utils`, `firefox` | Catapult uses `xdg-open`, then falls back to `firefox`, to open the HTML help |
| PDF docs in-tree | `evince` | `$MGC_HOME/shared/pdfdocs/*.pdf`, e.g. the license server install guide |
| HLS4ML flow (beta) | `python3`, `python3-pip`, `python3-devel` | Uses a Python virtualenv at `$HLS4ML_VENV`, defaulting to `$HOME/ccs_venv` |
| C Design Checker | `perl` | Design Checker performs a Perl version check |
| Fonts / rendering for Design Analyzer | `freetype`, `harfbuzz` | Stock on Rocky 8.10; the manual only documents a manual install for unsupported pre-8 distributions |

All of these are already in the definition file. The remaining packages
(`zeromq-devel`, `python3-zmq`, czmq from source, `hdf5-devel`, `swig`,
`graphviz`, `opencl-headers`, `Lmod`, `fish`, `tmux`, `vim-enhanced`) are
**not** required by the Catapult documentation — they support our own project
flows.

## HLS4ML Python virtual environment

The HLS4ML flow runs in a Python virtual environment. The release notes
(Option Changes) say the default of "Location of Python Virtual Environment
(HLS4ML flow)" changed from `$HOME/ccs_venv` to `$HLS4ML_VENV`. If the option
is unchanged and `$HLS4ML_VENV` is unset, Catapult still uses
`$HOME/ccs_venv`, so an older venv there is picked up silently.

The venv is built from the Python 3.10 shipped with Catapult, not from the
image's `python3`, by `$MGC_HOME/bin/create_catapult_py_venv.sh <venv-dir>`.
In 2026.3_1 that script fails at its first step with
`pkgs/cds_python3/bin/python3: No such file or directory`, and every later
step then fails too. Compared with 2026.3, the interpreter path changed to
one the release does not ship (`pkgs/cds_python3/` holds only `include/` and
`share/`):

```diff
--- 2026.3/Mgc_home/bin/create_catapult_py_venv.sh
+++ 2026.3_1/Mgc_home/bin/create_catapult_py_venv.sh
-$CATAPULT_HOME/bin/python3 -m venv --without-pip $VENV
+$CATAPULT_HOME/pkgs/cds_python3/bin/python3 -m venv $VENV
```

The interpreter is still at `$MGC_HOME/bin/python3` (3.10.19), as in 2026.3.
Until Siemens fixes the script, run its steps with that path, after sourcing
`~/bin/siemens.sh` (add the script's `--trusted-host` options to `pip` if
your site intercepts TLS):

```bash
VENV=$HOME/catapult_venvs/2026.3_1
export PYTHONPATH=
$MGC_HOME/bin/python3 -m venv $VENV
source $VENV/bin/activate
pip install --upgrade pip
pip install --no-cache-dir -r $MGC_HOME/shared/pkgs/ccs_hls4ml/requirements.txt
PYTHONPATH=$MGC_HOME/shared/pkgs/ccs_hls4ml/hls4ml python3 -c "import hls4ml; import pdfplumber"
```

Notes:

- The requirements pull TensorFlow 2.15, PyTorch 2.5.1 with the CUDA 12
  wheels, QKeras, ONNX and Jupyter; the venv takes about 8 GB.
- The bundled hls4ml reports its version as `1.0.0.Catapult+CCS_2025.1`.
- `hls4ml` itself is not installed into the venv; it is imported from
  `$MGC_HOME/shared/pkgs/ccs_hls4ml/hls4ml` through `PYTHONPATH`, which
  `activate` does not set.
- The venv records the absolute path of the interpreter it was built from,
  so Catapult must be mounted at the same path inside the container as when
  the venv was built. The Makefile binds `TOOLS_DIR` and `$HOME` at their
  host paths, which satisfies this.

## Third-party software compatibility (2026.3_1)

External tools live on the host under `TOOLS_DIR` (bind-mounted); the versions
below are what Siemens qualifies for this release (unchanged from 2026.3).

| Tool | Vendor | Version |
|---|---|---|
| QuestaSim | Siemens | 2025.3 |
| Questa MVC | Siemens | 2025.3 |
| Visualizer | Siemens | 2025.3 (needed to read QWAVE in Catapult Ultra) |
| QWave format | Siemens | 2024.3 |
| Design Compiler | Synopsys | X-2025.06 |
| VCS-MX | Synopsys | U-2023.03-SP2 |
| Synplify Pro | Synopsys | N-2017.09 SP1 |
| SpyGlass Lint | Synopsys | 2023.03-SP1 |
| Novas/Verdi | Synopsys | U-2023.03-SP1 (only for FSDB output) |
| Vivado | Xilinx | 2025.2 (not usable for CCORE/cluster estimation) |
| Quartus Standard / Pro | Altera | 24.1.0.1077 / 24.1.0.115 |
| Radiant | Lattice | 2023.2 |
| Xcelium | Cadence | 22.09 (beta) |
| MATLAB/Simulink | MathWorks | R2022a (32-bit) — requires `options set Input/Compiler gcc_4.9.2` |

Language standards: C++11 default (most C++14/C++17 synthesizable constructs
supported), VHDL 1076-1993, Verilog 1364-2001, SystemVerilog 1800-2017,
UVMf 2023.4_2.

## Image changes for this release

None. The definition file inherited from 2026.2_1 and 2026.3 already covers
every OS-level requirement the 2026.3_1 documentation states.

No rebuild is needed if `catapult_rocky.sif` was built from the 2026.2_1
definition (commit "Add documented Catapult dependencies to image") or later.

## Host updates for this release

Everything below lives outside the image, under `TOOLS_DIR` or in
`~/bin/siemens.sh`. Coming from 2026.2_1, first apply the host updates in
`doc/siemens/2026.3/README.md` (QuestaSim and Visualizer 2025.3, Design
Compiler X-2025.06, Vivado 2025.2); the third-party versions did not change
again in 2026.3_1.

Required:

1. Install Catapult 2026.3_1 from SupportCenter into
   `$TOOLS_DIR/.../catapult/2026.3_1`.
2. In `~/bin/siemens.sh`, set `CATAPULT_VER=2026.3_1`.
3. Make sure `TOOLS_DIR` in the `Makefile` points at the host directory that
   holds the Siemens tools (the default is `/extras2`).

Flow-dependent:

4. HLS4ML flow: build a venv for this release as described in "HLS4ML
   Python virtual environment" (the shipped script does not work), and set
   `HLS4ML_VENV` to it in `~/bin/siemens.sh`. Without it, Catapult falls
   back to `$HOME/ccs_venv`, which may hold a venv from an older release.

Recommended:

5. Run saltd 11.19.8.4 or later on the license server, from Siemens License
   Server v5.3.0 (11.19.0.1 is the minimum). Check with
   `$MGC_HOME/bin/lmstat -c <port>@<host>`.

After installing:

6. Look in `$MGC_HOME/pkgs/` for the bundled FlexNet directory
   (`FlexNet-11-19-5` or `FlexNet-11-19-8`; the manuals disagree). It matters
   only if the `DAEMON` line of your license file points at the saltd inside
   the Catapult tree.
