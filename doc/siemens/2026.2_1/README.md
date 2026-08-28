# Catapult 2026.2_1 — Environment Requirements

Requirements extracted from the Siemens documentation for Catapult Synthesis
2026.2_1 (June 2026), for the container image built by
`containers/apptainer_catapult_rocky.def`.

Source documents (not tracked in git — download from
[Siemens SupportCenter](https://support.sw.siemens.com/) and drop them in this
directory):

| File | Document |
|---|---|
| `catapult_install.pdf` | Catapult Synthesis Installation Manual, 2026.2_1 |
| `catapult_relnotes.pdf` | Catapult Synthesis Release Notes, 2026.2_1 |
| `release_highlights.pdf` | Catapult Release Highlights |

The manuals do **not** publish an RPM package list. They state the supported OS,
the 32-bit compatibility requirement, and a third-party software matrix; the
package mapping below is our translation of those statements onto Rocky 8.10.

## Operating system

- **Rocky Linux 8.10 only.** From 2023.2 onward Catapult supports only the
  latest minor version of a major release; 2024.2 was the first release limited
  to Rocky 8.10, and Red Hat 7 support ended after 2024.1. Rocky 8.10 goes EOL
  in May 2029.
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
  later recommended** (Siemens License Server v5.2).
- The install tree ships FlexNet 11.19.5 at
  `$MGC_HOME/pkgs/FlexNet-11-19-5/Lnx64_x86-64/saltd`, so no license software
  has to be installed into the image — but the FlexLM tools (`lmgrd`,
  `lmstat`, `lmhostid`, `lmdown`) need `redhat-lsb-core`, `net-tools`, and a
  resolvable hostname to run inside the container.
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
| AC Datatypes / AC Math / DSP / IPL / Comm / Video / Sim Util | 2026.2 |
| MatchLib Connections | 2026.2 |
| Oasys-RTL, Precision RTL, PowerPro, SLECPro, Catapult Formal, CCOV, C Design Checker | integrated in the tree |

Note: gcc moved from 10.3 to 13.4 in 2026.1. GCC 13.4 tightened `libstdc++`
header dependencies, so designs may need explicit `<cstdint>` / `<iterator>`
includes that older headers pulled in transitively.

## OS packages the flows actually need

| Need | Packages | Why (per the docs) |
|---|---|---|
| X11 GUI | `libXext`, `libXft`, `libXtst`, `libXi`, `xorg-x11-server-Xvfb` | GUI + graphical installer under KDE/Gnome; Xvfb for headless batch runs that still want a display |
| SCVerify flow | `make`, `gcc`, `gcc-c++` | *"The SystemC library and Make utility are only needed for the Catapult SCVerify flow"* |
| Help system | `xdg-utils` (plus a browser) | Catapult uses `xdg-open`, then falls back to `firefox`, to open the HTML help |
| PDF docs in-tree | `evince` | `$MGC_HOME/shared/pdfdocs/*.pdf`, e.g. the license server install guide |
| HLS4ML flow (beta) | `python3`, `python3-pip`, `python3-devel` | Uses a Python virtualenv at `$HLS4ML_VENV`, defaulting to `$HOME/ccs_venv` |
| C Design Checker | `perl` | Design Checker performs a Perl version check |
| Fonts / rendering for Design Analyzer | `freetype`, `harfbuzz` | Stock on Rocky 8.10; the manual only documents a manual install for unsupported pre-8 distributions |

The remaining packages in the definition file (`zeromq-devel`, `python3-zmq`,
czmq from source, `hdf5-devel`, `swig`, `graphviz`, `opencl-headers`, `Lmod`,
`fish`, `tmux`, `vim-enhanced`) are **not** required by the Catapult
documentation — they support our own project flows.

## Third-party software compatibility (2026.2_1)

External tools live on the host under `/mnt` (bind-mounted); the versions below
are what Siemens qualifies for this release.

| Tool | Vendor | Version |
|---|---|---|
| QuestaSim | Siemens | 2024.3 |
| Questa MVC | Siemens | 2024.3 |
| Visualizer | Siemens | 2024.3 (needed to read QWAVE in Catapult Ultra) |
| QWave format | Siemens | 2024.3 |
| Design Compiler | Synopsys | 2022.03-SP3 |
| VCS-MX | Synopsys | U-2023.03-SP2 |
| Synplify Pro | Synopsys | N-2017.09 SP1 |
| SpyGlass Lint | Synopsys | 2023.03-SP1 |
| Novas/Verdi | Synopsys | U-2023.03-SP1 (only for FSDB output) |
| Vivado | Xilinx | 2023.2 (not usable for CCORE/cluster estimation) |
| Quartus Standard / Pro | Altera | 24.1.0.1077 / 24.1.0.115 |
| Radiant | Lattice | 2023.2 |
| Xcelium | Cadence | 22.09 (beta) |
| MATLAB/Simulink | MathWorks | R2022a (32-bit) — requires `options set Input/Compiler gcc_4.9.2` |

Language standards: C++11 default (most C++14/C++17 synthesizable constructs
supported), VHDL 1076-1993, Verilog 1364-2001, SystemVerilog 1800-2017,
UVMf 2023.4_2.

## Known gaps in the current image

- `libstdc++.i686` and `libstdc++-devel.i686` are missing from
  `containers/apptainer_catapult_rocky.def`. C++ designs compiled in the
  default 32-bit mode need them at link time.
- No web browser is installed, so the HTML help system will fail after
  `xdg-open` finds no handler. Either install `firefox` or point the
  Web Browser option at a host browser.
- `perl` is only present transitively (as a dependency of `git`/`autoconf`);
  add it explicitly if the C Design Checker flow is used.
