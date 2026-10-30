# Documentation

## Project documents

| Document | Content |
|---|---|
| [fmc_mipi_interface.md](fmc_mipi_interface.md) | FMC_MIPI J2 (Samtec QTH-060, Jetson TX2 camera pinout): pin map from the netlist, signal levels, power, consequences for the bridge |
| [target_boards.md](target_boards.md) | Camera connectors of the three targets: Raspberry Pi 3 B+, Astra Machina SL2610, Coralboard SL |
| [board_compatibility.md](board_compatibility.md) | Other popular boards: connector requirements, mechanical and out-of-the-box electrical interchangeability |

## Third-party reference documents

`fetch_docs.sh` downloads every entry of [sources.txt](sources.txt) into `vendor/<sub-directory>/`.
The files are git-ignored. [vendor.sha256](vendor.sha256) records the checksums of the last download.

| Sub-directory | What is in it | Used for |
|---|---|---|
| `raspberry_pi/` | Pi 3B+ schematics, mechanical drawing (PDF + DXF), product brief, power supply; official 15/22-pin CSI pinout and CSI-2 usage text; camera cable drawings; HQ camera schematics; Pi 4, Zero 2 W, Pi 5, CM4 IO (+ KiCad), CM5 IO references | Target #1, RPi-compatible connectors, cable types |
| `synaptics_sl2610/` | SL2610 datasheet and product brief; Machina SL2600 dev-kit brief, user guide, I/O-board and core-module schematics; CSI camera, TWSI (I2C) and GPIO app notes; SDK hardware and ISP sensor guides | Target #2 (J206), SL2610 CSI-2 RX limits |
| `coralboard/` | Google Coral product brief; Grinn OV5647 device-tree overlay | Target #3 |
| `connectors/` | Samtec QSH/QTH product spec, QSH/QTH drawings, QSH footprint | Bridge connector mating FMC_MIPI J2 |
| `fpga_amd/` | XAPP894 (D-PHY with resistor networks), UG810 (KC705) | FPGA-side D-PHY and FMC details |
| `fmc_mipi_parts/` | TCA9406, SN74AVCH16T245, TS3DDR3812, AT24MAC402 | Electrical behaviour of the FMC_MIPI side of J2 |
| `bridge_parts/` | PCA9306, LSF0102 | Candidate I2C/GPIO translators for the bridge |

## Documents that must be fetched by hand

| Document | Link | Why not scripted |
|---|---|---|
| NVIDIA Jetson TX1/TX2 Developer Kit Carrier Board Specification (camera connector) | https://developer.nvidia.com/embedded/dlc/jetson-tx1-tx2-developer-kit-carrier-board-spec | NVIDIA developer login |
| Amphenol SFW15R-2STE1LF (RPi 15-pin 1.0 mm) drawing | https://www.amphenol-cs.com/product/sfw15r2ste1lf.html | site blocks scripts |
| Amphenol F32Q-1A7H1-11022 (RPi 22-pin 0.5 mm) drawing | https://www.amphenol-cs.com/product/f32q1a7h111022.html | site blocks scripts |
| Molex 505110-2296 (probable Machina J206 part) | https://www.molex.com/en-us/products/part-detail/5051102296 | site not reachable from scripts; part number not confirmed |
| Coralboard SL schematics / camera connector pinout | Synaptics support portal: https://synacsm.atlassian.net/servicedesk/customer/portal/2987 | not published |
| Samtec high-speed board-to-board design guide (19 MB, optional) | https://suddendocs.samtec.com/literature/samtec-high-speed-b2b-design-guide.pdf | large, optional |
| MIPI CSI-2 and D-PHY specifications | https://www.mipi.org/specifications | MIPI Alliance members only |
| ANSI/VITA 57.1 FMC standard | https://www.vita.com/ | paid standard |
