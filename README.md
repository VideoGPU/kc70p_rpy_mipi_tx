# kc70p_rpy_mipi_tx

KiCad bridge PCB between the [FMC_MIPI](https://github.com/VideoGPU/FMC_MIPI) board and the MIPI CSI-2
camera inputs of single-board computers. With it, the KC705 FPGA (running the
[MIPI_CSI2_TX](https://github.com/VideoGPU/MIPI_CSI2_TX) firmware) appears as a camera module to:

1. **Raspberry Pi 3 Model B+**
2. **Synaptics Astra Machina SL2610 developer kit**
3. **Synaptics Coralboard™ for Edge AI (Coralboard SL, SL2610-based)**

## System overview

```
 KC705 (Kintex-7)         FMC_MIPI board               this bridge                     host boards
 +---------------+  FMC  +--------------------+  J2   +------------------------+  FFC  +-----------------------+
 | CSI-2 TX      |=======| D-PHY resistor nets |=======| Samtec QSH-060 socket  |=======| Raspberry Pi 3 B+     |
 | I2C target    |       | HS/LP switches      | QTH/  | CSI lane routing       |       | Astra Machina SL2610  |
 | (MIPI_CSI2_TX)|       | 1.8 V level shift   | QSH   | I2C/GPIO level shift   |       | Coralboard SL         |
 +---------------+       | EEPROM 0x54/0x5C    | 120p  | host-rail sensing      |       | (+ compatible boards) |
                         +--------------------+       +------------------------+       +-----------------------+
```

* Bridge input: FMC_MIPI **J2** = Samtec QTH-060-01-L-D-A carrying the Jetson TX1/TX2 camera-connector
  pinout. The bridge uses the mating **QSH-060-01-L-D-A** socket (5 mm stack).
  Details: [doc/fmc_mipi_interface.md](doc/fmc_mipi_interface.md).
* Available from FMC_MIPI: two 2-lane D-PHY ports (C and D, 800 Mb/s per lane in the current
  firmware) that switch HS/LP together, three 1.8 V I2C buses, host-to-FPGA MCLK/PWR/RST inputs,
  two FPGA-to-host GPIOs, and "host rail present" sensing. FMC_MIPI takes its power from the FMC, not
  from J2.
* Bridge outputs: camera connectors for the target hosts. See [doc/target_boards.md](doc/target_boards.md)
  for the target pinouts, and [doc/board_compatibility.md](doc/board_compatibility.md) for other popular
  boards and the connector interchangeability table.

## Repository layout

```
.
├── README.md
└── doc/
    ├── README.md                 index of all documents
    ├── fmc_mipi_interface.md     FMC_MIPI J2 pin map and electrical notes (bridge input)
    ├── target_boards.md          camera connectors of the three target hosts
    ├── board_compatibility.md    popular boards: requirements and interchangeability table
    ├── sources.txt               third-party documents: sub-directory, file, URL, description
    ├── fetch_docs.sh             downloads everything in sources.txt into doc/vendor/
    ├── vendor.sha256             checksums of the downloaded files
    └── vendor/                   downloaded third-party documents (git-ignored)
```

The KiCad project will be added in the next stage.

## Reference documents

```sh
doc/fetch_docs.sh        # download missing documents into doc/vendor/
doc/fetch_docs.sh -f     # download everything again
doc/fetch_docs.sh -c     # check doc/vendor/ against doc/vendor.sha256
```

Vendor documents are downloaded locally but not committed: they are copyrighted by their owners and
large. A few documents need a login or block scripted downloads; [doc/README.md](doc/README.md) lists
them with their links.

## Related repositories

* [VideoGPU/FMC_MIPI](https://github.com/VideoGPU/FMC_MIPI) - FMC card, KC705 to Jetson TX2 camera connector (KiCad 6).
* [VideoGPU/MIPI_CSI2_TX](https://github.com/VideoGPU/MIPI_CSI2_TX) - VHDL CSI-2 transmitter on LVDS I/O, tested on KC705.
* [VideoGPU/common_IPs](https://github.com/VideoGPU/common_IPs) - AXI MIPI TX IP and I2C target IP.
* [VideoGPU/cameleon_HW](https://github.com/VideoGPU/cameleon_HW) - Cameleon requirements. This bridge follows the
  same adapter-board rules: host rails are sensed but not used to power the FPGA side
  (CAM-SYS-014), and host-side signals follow the host I/O level (CAM-SYS-015).

## Status

Stage 1 (this commit): repository set-up, reference documents, FMC_MIPI interface analysis, target and
compatibility research.

Decisions needed before the schematic (details in [doc/board_compatibility.md](doc/board_compatibility.md)):

1. Output connectors. The research suggests an RPi 15-pin 1.0 mm output (2 lanes, port C) plus an RPi
   22-pin 0.5 mm output (2 or 4 lanes). Together they reach about 25 popular boards directly.
2. Whether the 22-pin output supports 4 lanes (ports C+D with the clock from C). The firmware must
   drive both ports with the same timing.
3. Host I/O level selection (1.8 V / 3.3 V), needed for TI SK boards, Jetson Orin Nano GPIOs and,
   possibly, the Coralboard.
4. CAM_IO1 routing (FPGA RST input, FPGA MCLK input, or open) and CAM_IO0 polarity handling.
5. Which J2 I2C bus goes to which output, and whether the FMC_MIPI EEPROM (0x54/0x5C) should be
   visible to the hosts.
6. Coralboard SL: identify the CSI connector on a real board (pin 1, 3V3, I2C level). It is not
   published.
7. Mechanics: bridge position under FMC_MIPI J2 (5 mm stack), FFC exit direction, support/standoffs.
8. KiCad version for the new project (FMC_MIPI uses KiCad 6.0.9).

## License

TBD.
