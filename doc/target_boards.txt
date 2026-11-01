# Target host boards

The bridge must look like a camera module to these three hosts. Unless another source is given, every
fact below comes from a document in `doc/vendor/` (see [sources.txt](sources.txt)). Confidence:
**H** = read directly from a schematic or official document, **M** = inferred from official material
(app notes, BSP sources), **?** = not published, must be measured on the real board.

## Summary

| | Raspberry Pi 3 Model B+ | Astra Machina SL2610 dev kit | Coralboard SL (SL2619) |
|---|---|---|---|
| Host camera connector | 15-pin 1.0 mm FFC, TE 1-1734248-5 (H) | J206 "MIPI-CSI0", 22-pin 0.5 mm FPC, bottom contact (H/M) | FPC between the mikroBUS halves; type and pitch **not published (?)** |
| Pinout family | RPi 15-pin (H) | RPi 22-pin signal order; schematic numbers pins from the other end (H) | **?** (not published) |
| Lanes used by host | 2 (H) | 2: the SL2610 has one 2-lane CSI-2 RX; lane 2/3 pins on J206 are unused (H) | 2 (H, same SoC) |
| Host RX limit | Unicam, D-PHY 1.1, 2 lanes at 1 Gb/s (H, Pi 5 product brief) | up to 1.5 Gb/s per lane, 2 virtual channels, ISP (H) | same as Machina (H) |
| I2C level | 3.3 V, 1.8 kOhm pull-ups on the Pi (H) | 3.3 V (SM_TW0 level-shifted on the I/O board), 33 Ohm series (H) | **? (1.8 V or 3.3 V)** |
| Power-enable GPIO | CAM_IO0, pin 11, 3.3 V (H) | PWR_ON_CSI0, pin 6, 3.3 V from FXL6408 0x44 GPIO1_4 (H) | `pwdn-gpios` porta 5, active low, in the Grinn BSP (M) |
| 2nd GPIO | CAM_IO1, pin 12 (LED / GPIO) (H) | GPIO_CSI0, pin 5, from 0x44 GPIO1_0, "reserved" (H) | ? (survey: Grinn BSP has a camera LED enable; not checked) |
| Supply on connector | 3V3, pin 15 (H) | 3V3 (PWR_3V3_CTL board rail), pin 1 (H) | ? (3V3 expected) |
| Stock camera / cable | RPi camera + standard 15-15 cable | OV5647 module with 15-pin 1.0 mm cable (Synaptics app note) | OV5647 module + "CSI flex ribbon cable", camera held by M1.6 screws on the sensor add-on board (H); connector types not published |
| Board power | 5 V / 2.5 A micro-USB (official supply 5.1 V) | USB-C 15 V / 1.8 A (5 V option via JP2) | USB-C (host port or USB-C supply) |

What the bridge needs for all three:

* A 2-lane CSI-2 output with the RPi camera-module pinout. One FMC_MIPI port (C or D) is enough.
* I2C and GPIO translation from the FMC_MIPI 1.8 V side to 3.3 V hosts, and to 1.8 V until the
  Coralboard level is known: a selectable host I/O reference.
* Host 3.3 V from the camera connector routed to J2 108/110 ("host present"), and the power-enable GPIO
  routed to J2 93 (see [fmc_mipi_interface.md](fmc_mipi_interface.md)).
* Only a few mA drawn from the host 3.3 V. No vendor publishes the camera-supply current budget; the
  Cameleon rule (CAM-SYS-014) is at most 10 mA per host rail, and no back-feeding.
* CAM_IO0/CAM_IO1 treated as inputs by default. Their meaning differs between hosts.

Pi 3B+ and Machina J206 both use the Raspberry Pi signal order, so one RPi-pinout output reaches both:
* Pi 3B+: a 15-pin output with a standard 15-15 cable.
* Machina: a 22-pin output with a 22-22 cable, or a 15-pin output with a 15-to-22 cable. Synaptics' own
  reference camera is a 15-pin OV5647 module. Check the cable contact side against J206 (bottom contact)
  before the first power-up.

The Coralboard connector must be identified on a real board before deciding the output for it.
A 22-pin output on the bridge is also needed for 4-lane hosts (Pi 5, CM4/CM5 IO boards). See
[board_compatibility.md](board_compatibility.md).

Cable facts (RPi drawings in `doc/vendor/raspberry_pi/`):
* Standard camera cable (RP-008146): 15 pins at 1.0 mm, 16.0 mm wide, 200 mm.
* 15/22 cable (RP-008145, "mini" cable used by Pi 5 / Zero): 15 pins at 1.0 mm (16.0 mm wide) to
  22 pins at 0.5 mm (11.5 mm wide). It carries only 2 lanes.

---

## 1. Raspberry Pi 3 Model B+

Sources: `raspberry-pi-3-b-plus-reduced-schematics.pdf`, `rpi-doc-camera-pinouts.adoc`,
`rpi-doc-csi-2-usage.adoc`, `raspberry-pi-3-b-plus-product-brief.pdf`.

* Receiver: BCM2837 "Unicam", CSI-2 D-PHY 1.1. Models before Pi 5 route only 2 data lanes of the second
  Unicam instance to the connector, at up to 1 Gb/s per lane (Pi 5 product brief).
* Connector: 15-pin 1.0 mm FFC, TE 1-1734248-5 on the 3B+ schematic (RPi documentation: compatible with
  Amphenol SFW15R-2STE1LF). The Pi 4B uses the same pinout but leaves CAM_IO1 (pin 12) unconnected.
* Pin 1 (RPi documentation): with the board upright and the logo readable, pin 1 is the contact furthest
  from you, nearest the GPIO header. On a camera board held lens-down with the connector on the right, pin
  1 is the contact nearest to you.
* The camera I2C (SCL0/SDA0, 1.8 kOhm pull-ups to 3.3 V) also goes to the DSI display connector.
* Software: `bcm2835-unicam` + a V4L2 sensor driver + a device-tree overlay. The overlay sets the
  number of lanes, continuous or non-continuous clock, and the link frequency, so the FPGA emulation must
  match one supported sensor profile (for example OV5647 at 0x36, or IMX219 at 0x10) or come with its own
  driver and overlay.
* Alternative: the Pi kernel also supports two CSI-2 bridge chips, ADV728x-M (analog video) and Toshiba
  TC358743 (HDMI). If the FPGA emulated a TC358743 instead of a sensor, the Pi would receive RGB888 or
  YUV422 frames with no ISP tuning. Over 2 lanes the documented limits are 1080p30 RGB888 or 1080p50
  YUV422. The FPGA I2C target would then have to emulate the TC358743 registers (timing detection,
  EDID) instead of a sensor's.

| Pin | Name | Function | Bridge source (FMC_MIPI J2) |
|---|---|---|---|
| 1 | GND | | GND |
| 2 / 3 | CAM_DN0 / CAM_DP0 | lane 0 | port C or D, D0 |
| 4 | GND | | GND |
| 5 / 6 | CAM_DN1 / CAM_DP1 | lane 1 | port C or D, D1 |
| 7 | GND | | GND |
| 8 / 9 | CAM_CN / CAM_CP | clock | port C or D, CLK |
| 10 | GND | | GND |
| 11 | CAM_IO0 | GPIO, usually active-high power enable, 3.3 V | J2 93 GPIO0_CAM0_PWR |
| 12 | CAM_IO1 | GPIO (LED / clock), 3.3 V | J2 95 GPIO2_CAM0_RST (option) |
| 13 | SCL | I2C, 3.3 V, pulled up on the Pi | J2 75 I2C_CAM via 1.8 V-3.3 V translator |
| 14 | SDA | I2C, 3.3 V, pulled up on the Pi | J2 77 I2C_CAM via translator |
| 15 | 3V3 | 3.3 V supply from the Pi | J2 108/110 sense, bridge translators |

## 2. Synaptics Astra Machina SL2610 developer kit

Sources: `machina-io-board-schematic.zip` (sheet 06 "CONN - MIPI CSI" and sheet 13 "SODIMM"),
`sl2610-datasheet.pdf` section 2.8, `astra-doc-hw-sl2600.rst.txt`,
`machina-mipi-csi-camera-connection-appnote.pdf`, `astra-doc-isp-sensor-integration.rst.txt`.

* Receiver: SL2610 family (SL2619 on the kit). One 2-lane CSI-2 RX, up to 1.5 Gb/s per lane, up to
  2160p30, 2 virtual channels, HDR, multidrop, ISP. The PHY runs from MIPI_CSI_AVDD1P8 (1.8 V) with a
  200 Ohm REXT. A hardware camera-mute pin exists (CAMERA_MUTE, SODIMM 144). CSI pins exist on SL2613,
  SL2617 and SL2619; SL2611 and SL2615 have no CSI.
* The I/O board is shared with the SL16x0 core modules. The SL2610 core module drives only
  CSI0 RD0/RD1/RCK (SODIMM 67-81), which go to **J206**. The 15-pin J207 (CSI1, part
  `CON15_1X15_DRB_SFW`, RPi 15-pin pinout, I2C on V3P3.TW0) is fed from SODIMM 28-42, which are all
  "N/A" on the SL2610 core module, so J207 is used only with SL1680 core modules. Note: the camera app
  note's 15-pin "MIPI-CSI1" pin table names SL2619 too, but the schematic and the SL2600 user guide
  show that SL2610 reaches only J206.
* Connector J206: 22-pin 0.5 mm FPC (schematic value `CON_5051102296`, probably Molex 505110-2296, not
  verified). The Synaptics app note inserts the cable with the stiffener facing up, so J206 is bottom
  contact. Depending on the board build it has an edge-rotate or a pull-push actuator.
* I2C: SM_TW0 (SODIMM 138/140, 1.8 V), level-shifted to 3.3 V on the I/O board, 33 Ohm series
  resistors. All SL2610 TWSI ports are 1.8 V natively; Synaptics recommends 2.2 kOhm pull-ups and a
  level shifter for 3.3 V targets (TWSI app note). **The bus is shared** with current monitors (0x40,
  0x41, 0x42, 0x45) and FXL6408 IO expanders (0x43, 0x44) that switch board power. The emulated sensor
  must not use these addresses, and the bridge must never hold the bus low. FMC_MIPI's EEPROM at
  0x54/0x5C does not collide.
* Software: Astra SDK (Yocto). Any sensor with a V4L2 subdevice driver can be added through the device
  tree (`sl2619-rdk.dts`, camera on `i2c0`) and the ISP media-server configuration. OV5647 is the
  reference sensor.

| J206 pin (Synaptics) | Net | RPi 22-pin equivalent | Bridge source (FMC_MIPI J2) |
|---|---|---|---|
| 1 | 3V3 (PWR_3V3_CTL, 4.7 uF) | 22 3V3 | J2 108/110 sense |
| 2 | SDA (V3P3.SoC.SDA, 33 Ohm) | 21 SDA | I2C via translator |
| 3 | SCL (V3P3.SoC.SCL, 33 Ohm) | 20 SCL | I2C via translator |
| 4 | GND | 19 GND | GND |
| 5 | GPIO_CSI0 (FXL6408 0x44 GPIO1_0, 33 Ohm) | 18 CAM_IO1 | J2 95 (option) |
| 6 | PWR_ON_CSI0 (FXL6408 0x44 GPIO1_4, 33 Ohm) | 17 CAM_IO0 | J2 93 |
| 7 | GND | 16 GND | GND |
| 8 / 9 | RD3p / RD3n (not driven by SL2610) | 15 / 14 D3 | n.c. |
| 10 | GND | 13 GND | GND |
| 11 / 12 | RD2p / RD2n (not driven by SL2610) | 12 / 11 D2 | n.c. |
| 13 | GND | 10 GND | GND |
| 14 / 15 | RCKp / RCKn | 9 / 8 CLK | port CLK |
| 16 | GND | 7 GND | GND |
| 17 / 18 | RD1p / RD1n | 6 / 5 D1 | port D1 |
| 19 | GND | 4 GND | GND |
| 20 / 21 | RD0p / RD0n | 3 / 2 D0 | port D0 |
| 22 | GND | 1 GND | GND |

Synaptics also offers a 22-pin FFC to "QTH" converter board (730-C01089-01) for its own 4-lane
IMX258/IMX415 adapters (SL1680 flow, auxiliary 5 V needed). Its QTH pinout is not published, so it is
not a known way to plug FMC_MIPI into the kit.

## 3. Synaptics Coralboard SL (SL2619, Grinn AstraSOM-261x)

Sources: Google Coral pages (`developers.google.com/coral/products/...`), Synaptics Coralboard pages,
`coral-product-brief.pdf`, `grinn-ov5647-camera-overlay.dtso` (Grinn `meta-grinn-astra` BSP).

* Variant: "Coralboard SL" is the SL2619-based board, designed by Grinn on the AstraSOM-261x module.
  The Limited Edition / Google I/O Edition 2 GB is this variant. "Coralboard SR" uses the Astra SR200
  series and is not a target.
* Connector: CSI FPC between the two halves of the mikroBUS socket. Google, Synaptics and Grinn publish
  no schematic, pinout or connector part number. The kit has an OV5647 "CSI camera module" and a "CSI
  flex ribbon cable"; the camera mounts on the sensor add-on board with M1.6 screws (Raspberry Pi camera
  boards use M2), so the stock camera is probably not an RPi-format board. The Machina J206 and Grinn's
  22-pin DSI connector suggest a 22-pin 0.5 mm part. This is an inference only (low confidence).
* Linux (Grinn BSP overlay for AstraSOM-261x, verified file): OV5647 on `i2c2` at 0x36,
  `pwdn-gpios = <&porta 5 GPIO_ACTIVE_LOW>` (power-enable role), 2 data lanes, non-continuous clock,
  ISP enabled. Google's user guide names the Coralboard overlays `grinn-astra-261x-coral-hat-overlay.dtbo`
  and `grinn-astra-261x-coral-ws-panel-overlay.dtbo`; their sources are not public.
* Software: the preloaded image is a Grinn-customised Astra SDK v2.2 OOBE image (Yocto 5.0
  "Scarthgap"). Synaptics plans Coralboard support in the regular Astra SDK later in 2026; its SDK
  download page says "coming soon".
* Mechanics: the sensor add-on board (HAT) plugs on top of the Coralboard and the camera flex folds under
  it, so the CSI connector sits under the HAT. With the bridge, leave the HAT off or route the flex out
  from under it.
* Board facts: USB-C for power and host data (ADB, NCM networking); USB-A host port limited to about
  0.6 A at 5 V; 20-pin header with a 3.3 V UART (pin 4 GND, 6 SM_URT0_TXD, 8 SM_URT0_RXD); mikroBUS and
  Qwiic connectors; 3.7 V LiPo input (JST-PH 2.0); M.2 2230 Wi-Fi/BT (AMPAK AP12611); boot switch (eMMC
  default).
* Availability: Limited / Google I/O Edition first, then pre-orders through DigiKey (Coral site, July
  2026). Synaptics support (https://synacsm.atlassian.net/servicedesk/customer/portal/2987) is the place
  to ask for the CSI connector pinout.
* Open points to measure on a real board before connecting the bridge: which end is pin 1, the 3V3
  pin, the I2C pull-up voltage (1.8 V or 3.3 V), and the GND pins.
* Power: USB-C, from a host port or a USB-C supply.
