kc70p_rpy_mipi_tx
=================

KiCad bridge PCB between the FMC_MIPI <https://github.com/VideoGPU/FMC_MIPI> board and
the MIPI CSI-2 camera inputs of single-board computers. With it, the KC705 FPGA (running
the MIPI_CSI2_TX <https://github.com/VideoGPU/MIPI_CSI2_TX> firmware) appears as a
camera module to:

1. Raspberry Pi boards (wherever RPi cameras work; 22-to-15-pin cable for the 15-pin
   connector of Pi 1-4, including the Raspberry Pi 3 Model B+)

2. NVIDIA Jetson Nano-class boards (Jetson Nano, Jetson Orin Nano and others)

3. Synaptics Astra Machina SL2610 developer kit

The Synaptics Coralboard(TM) SL (SL2610-based), a stage-1 target, is on hold until its
camera connector is identified (doc/design.txt, decision OD-5).

System overview
---------------


 KC705 (Kintex-7)         FMC_MIPI board               this bridge                     host boards
 +---------------+  FMC  +--------------------+  J2   +------------------------+  FFC  +-----------------------+
 | CSI-2 TX      |=======| D-PHY resistor nets |=======| Samtec QSH-060 socket  |=======| Raspberry Pi 3 B+     |
 | I2C target    |       | HS/LP switches      | QTH/  | CSI lane routing       |       | Astra Machina SL2610  |
 | (MIPI_CSI2_TX)|       | 1.8 V level shift   | QSH   | I2C/GPIO level shift   |       | Coralboard SL         |
 +---------------+       | EEPROM 0x54/0x5C    | 120p  | host-rail sensing      |       | (+ compatible boards) |
                         +--------------------+       +------------------------+       +-----------------------+

- Bridge input: FMC_MIPI J2 = Samtec QTH-060-01-L-D-A carrying the Jetson TX1/TX2
  camera-connector pinout. The bridge uses the mating QSH-060-01-L-D-A socket (5 mm
  stack). Details: doc/fmc_mipi_interface.txt.

- Available from FMC_MIPI: two 2-lane D-PHY ports (C and D, 800 Mb/s per lane in the
  current firmware) that switch HS/LP together, three 1.8 V I2C buses, host-to-FPGA
  MCLK/PWR/RST inputs, two FPGA-to-host GPIOs, and "host rail present" sensing. FMC_MIPI
  takes its power from the FMC, not from J2.

- Bridge outputs: camera connectors for the target hosts. See doc/target_boards.txt
  <doc/target_boards.txt> for the target pinouts, and doc/board_compatibility.txt
  <doc/board_compatibility.txt> for other popular boards and the connector
  interchangeability table.

Key findings (stage 1)
----------------------

- FMC_MIPI J2 (doc/fmc_mipi_interface.txt):

  - Ports C and D share their HS/LP select lines. Use them as one 4-lane port or as two
    cameras in lock-step (same timing), not as two independent cameras.

  - All J2 I/O is 1.8 V. TCA9406 I2C translators go high-Z when FMC_MIPI is unpowered.

  - An AT24MAC402 EEPROM answers at 0x54/0x5C on the camera I2C bus.

  - The FPGA-side enable/select pins are documented. The "DATA"/"CLOCK" switch-enable
    nets actually enable port C / port D.

  - FMC_MIPI's own review notes that the TS3DDR3812 lane switch is weak for D-PHY HS
    signals.

- Raspberry Pi 3 B+: R15 connector (TE 1-1734248-5), 2 lanes at up to 1 Gb/s, 3.3 V I2C
  shared with the display connector. Emulating an OV5647/IMX219, or a TC358743 HDMI
  bridge, are the host-driver options.

- Astra Machina SL2610: J206 is a 22-pin connector with the RPi signal order (numbered
  from the 3V3 end), 2 lanes at up to 1.5 Gb/s, 3.3 V I2C shared with board power
  management. Confirmed from the Synaptics schematic.

- Coralboard SL: same SoC, but the CSI connector is not published. Measure it on a real
  board.

- Other boards: an RPi 15-pin plus an RPi 22-pin output reach about 25 popular boards
  directly. With a 1.8 V I/O option and CAM_IO1 routing (Jetson MCLK) the bridge reaches
  a few more. Coral Dev Board, Rockchip/Khadas 30-pin and NXP Mini-SAS boards need
  adapters. Jetson TX2 takes FMC_MIPI directly.

Repository layout
-----------------


.
|-- README.txt
+-- doc/
    |-- README.txt                 index of all documents
    |-- fmc_mipi_interface.txt     FMC_MIPI J2 pin map and electrical notes (bridge input)
    |-- target_boards.txt          camera connectors of the three target hosts
    |-- board_compatibility.txt    popular boards: requirements and interchangeability table
    |-- design.txt                 bridge design: O22 validation, modes, pin maps, decisions
    |-- sources.txt               third-party documents: sub-directory, file, URL, description
    |-- fetch_docs.sh             downloads everything in sources.txt into doc/vendor/
    |-- vendor.sha256             checksums of the downloaded files
    +-- vendor/                   downloaded third-party documents (git-ignored)

The KiCad project will be added in the next stage.

Reference documents
-------------------


doc/fetch_docs.sh        # download missing documents into doc/vendor/
doc/fetch_docs.sh -f     # download everything again
doc/fetch_docs.sh -c     # check doc/vendor/ against doc/vendor.sha256

Vendor documents are downloaded locally but not committed: they are copyrighted by their
owners and large. A few documents need a login or block scripted downloads;
doc/README.txt lists them with their links.

Related repositories
--------------------

- VideoGPU/FMC_MIPI <https://github.com/VideoGPU/FMC_MIPI> - FMC card, KC705 to Jetson
  TX2 camera connector (KiCad 6).

- VideoGPU/MIPI_CSI2_TX <https://github.com/VideoGPU/MIPI_CSI2_TX> - VHDL CSI-2
  transmitter on LVDS I/O, tested on KC705.

- VideoGPU/common_IPs <https://github.com/VideoGPU/common_IPs> - AXI MIPI TX IP and I2C
  target IP.

- VideoGPU/cameleon_HW <https://github.com/VideoGPU/cameleon_HW> - Cameleon
  requirements. This bridge follows the same adapter-board rules: host rails are sensed
  but not used to power the FPGA side (CAM-SYS-014), and host-side signals follow the
  host I/O level (CAM-SYS-015).

Status
------

Stage 1: repository set-up, reference documents, FMC_MIPI interface analysis, target and
compatibility research.

Stage 2 (current): output connector decided - O22, the Raspberry Pi 22-pin 0.5 mm camera
connector, for Raspberry Pi boards (22-to-15-pin cable where needed), Jetson Nano-class
boards and the Astra Machina SL2610. Validation and the proposed design are in
doc/design.txt <doc/design.txt>. Main results:

- One 22-pin connector has only one clock lane. Ports C and D, each with its clock, need
  two connectors: CAM0 (port C, plus port D as lanes 2/3 for 4-lane mode) and CAM1 (port D).

- Two-camera mode runs the ports in lock-step (shared HS/LP select on FMC_MIPI).

- 4-lane mode needs about 46 mm of length compensation: port D is 48.7 mm shorter than
  port C on FMC_MIPI.

- I2C still needs translation: all targets use 3.3 V, the J2 side is 1.8 V. Host GPIOs into
  J2 need none.

Open decisions: see doc/design.txt section 6.

License
-------

TBD.
