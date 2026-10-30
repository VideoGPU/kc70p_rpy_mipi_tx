# Board compatibility and connector interchangeability

This file covers popular boards with MIPI CSI-2 camera inputs. For each it lists what its camera
connector requires, which other boards share the same connector (**mechanically interchangeable**:
the same cable fits), and whether things work **out of the box electrically**: with a stock Raspberry
Pi camera module, and with the planned bridge outputs.

## Assumptions about the bridge

* **O15**: RPi 15-pin 1.0 mm output, 2 lanes (FMC_MIPI port C).
* **O22**: RPi 22-pin 0.5 mm output, 2 lanes, or 4 lanes using FMC_MIPI ports C+D.
* Host I/O level selectable between 1.8 V and 3.3 V (I2C and GPIO).
* CAM_IO0 goes to the FPGA power-enable input (J2 93); the FPGA can treat it as active-high or
  active-low.
* CAM_IO1 can be routed to J2 95 (RST) or J2 91 (MCLK input), or left open.
* FMC_MIPI runs 800 Mb/s per lane, within every listed host whose limit is published (Pi 3B+/4B: 2 lanes
  at 1 Gb/s; Pi 5: 4 lanes at 1.5 Gb/s; SL2610: 2 lanes at 1.5 Gb/s).

## Legend

| Mark | Meaning |
|---|---|
| ✅ | works with a stock cable |
| ⚠️ | works under the condition given in the cell |
| ❌ | does not work without an adapter or other connector |
| ? | unknown (not published) |
| R15 | RPi 15-pin 1.0 mm FFC family: GND, D0-, D0+, GND, D1-, D1+, GND, CK-, CK+, GND, IO0, IO1, SCL, SDA, 3V3 |
| R22 | RPi 22-pin 0.5 mm FFC family: GND, D0-, D0+, GND, D1-, D1+, GND, CK-, CK+, GND, D2-, D2+, GND, D3-, D3+, GND, IO0, IO1, GND, SCL, SDA, 3V3 |
| Src **V** | checked in this session against the vendor document |
| Src **S** | from the research survey of vendor documents, not re-checked |
| Src **I** | inferred |
| H / M / L | confidence |

Some vendors (Synaptics, NVIDIA Orin Nano) number the R22 connector from the 3V3 end. The signal
order along the connector is what matters, not the pin numbers.

## Requirements and interchangeability table

| Board | Connector | Lanes | Pinout | Levels (supply / I2C / GPIO) | GPIO use | Mech. family | RPi camera OOB | Bridge OOB | Notes | Src |
|---|---|---|---|---|---|---|---|---|---|---|
| **Raspberry Pi 3 B+** (target) | 15p 1.0 mm, TE 1-1734248-5 | 1x2 | R15 | 3.3 / 3.3 (1.8k on Pi) / 3.3 | 11 power-en, 12 GPIO | R15 | ✅ | ✅ O15, 15-15 cable | I2C shared with the display connector | V-H |
| **Astra Machina SL2610** (target) | J206, 22p 0.5 mm, bottom contact | 1x2 (1.5 Gb/s) | R22 order, numbered from 3V3 end | 3.3 / 3.3 (SM_TW0) / 3.3 via I2C expander | PWR_ON_CSI0 (=IO0), GPIO_CSI0 (=IO1) | R22 | ⚠️ OV5647 is the vendor reference sensor; check cable side | ⚠️ O22 (22-22) or O15 (15-22); check cable side | I2C shared with power monitors/expanders 0x40-0x45 | V-H |
| **Coralboard SL** (target) | FPC between mikroBUS halves, type not published | 1x2 | ? | ? / ? / ? | pwdn active-low (Grinn BSP) | ? | ? (kit OV5647 module only) | ? until measured | measure pin 1, 3V3, I2C level | V-M |
| Raspberry Pi 1 B/B+, 2 B, 3 B, 3 A+ | 15p 1.0 mm | 1x2 | R15 | 3.3 / 3.3 / 3.3 | 11, 12 | R15 | ✅ | ✅ O15 | | S-H |
| Raspberry Pi 4 B | 15p 1.0 mm | 1x2 (1 Gb/s) | R15 | 3.3 / 3.3 / 3.3 | 11 power-en, 12 n.c. | R15 | ✅ | ✅ O15 | | V-H |
| Raspberry Pi Zero, Zero W, Zero 2 W | 22p 0.5 mm | 1x2 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ 15-22 cable | ✅ O22, or O15 + 15-22 cable | | S-H |
| Raspberry Pi 5 | 2x 22p 0.5 mm (camera or display) | 2x4 (1.5 Gb/s) | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ 15-22 cable for 15p cameras | ✅ O22 (4 lanes possible), O15 + 15-22 | | V-H |
| CM4 IO board | 2x 22p 0.5 mm | CAM0 2, CAM1 4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | CAM0 I2C needs both J6 jumpers | V-H |
| CM5 IO board | 2x 22p 0.5 mm (camera or display) | 2x4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | CAM/DISP1 I2C needs J6 jumpers | V-H |
| Raspberry Pi 400 / 500 | none | - | - | - | - | - | ❌ | ❌ | no camera connector | S-H |
| Jetson Nano dev kit (A02, B01, 2 GB) | 15p 1.0 mm (B01: x2) | 1x2 each | R15-like | 3.3 / 3.3 (I) / ? | 11 PWDN, 12 MCLK out | R15 | ✅ (NVIDIA lists RPi v2 and HQ) | ⚠️ O15: route IO1 to J2 91 (MCLK) or leave open | | V-H list / S-M pins |
| Jetson Xavier NX dev kit | 15p 1.0 mm x2 | 2 each | R15-like | 3.3 / 3.3 (I) / ? | as Nano (I) | R15 | ✅ (same camera list as Nano) | ⚠️ as Nano | | V-M |
| Jetson Orin Nano / Orin Nano Super | 2x 22p 0.5 mm, bottom contact | CAM0 2, CAM1 2 or 4 | R22 order, numbered from 3V3 end | 3.3 / 3.3 / **1.8** | MCLK (=IO1), PWDN (=IO0) at 1.8 V | R22 | ✅ RPi v2 with 15-22 cable (NVIDIA) | ⚠️ O22 or O15 + 15-22; GPIO inputs must accept 1.8 V | | V-H conn / S-H levels |
| Seeed reComputer J401 | 2x 15p 1.0 mm | 2 each | R15-like | ? | 12 likely MCLK | R15 | ⚠️ ? | ⚠️ as Nano | | S-L |
| Jetson TX2, AGX Xavier, AGX Orin | Samtec QSH-060, 120p 0.5 mm board-to-board | up to 6x2 / 4x4 | Jetson 120-pin | multi-rail / 1.8 / 1.8 | many | QSH-060 | ❌ | n/a: FMC_MIPI J2 plugs in directly (TX2 by design; AGX pinout to verify) | | V-H TX2 / S-L AGX |
| Coral Dev Board, Dev Board Mini | 24p 0.5 mm | 4-capable | Coral-24: CK at 5/6, PWDNB 17, RESETB 23, SCL/SDA 20/21, 3V3 24 | 3.3 / 3.3 (4.7k) / 3.3 | PWDNB, RESETB | Coral-24 | ❌ | ❌ needs a 24-pin passive adapter | | V-H Dev Board / S-H Mini |
| Coral Dev Board Micro | Hirose DF40 100p board-to-board | 2 | - | ? / 1.8 / ? | - | - | ❌ | ❌ | | S-H |
| BeagleBone AI-64 | 2x 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | | S-H |
| BeagleY-AI | 2x 22p 0.5 mm | 4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | J16 shared with DSI | S-H |
| BeaglePlay | 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 1.8 or 3.3 (unclear) / ? | 17, 18 | R22 | ⚠️ | ⚠️ select level after checking | | S-M |
| BeagleV-Ahead, BeagleV-Fire | 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 3.3 / 3.3 | 17 (Fire: PWDN only) | R22 | ✅ | ✅ O22 | | S-H |
| TI SK-AM62B | 15p 1.0 mm, TE 1-1734248-5 | 1x2 | R15 (TI: "compatible") | 3.3 / 3.3 / 3.3 | 11, 12 | R15 | ✅ | ✅ O15 | | S-H |
| TI SK-AM62A-LP | 22p 0.5 mm (J20) | 4 | R22 | 3.3 / 3.3 (TCA9543A) / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | | S-H |
| TI SK-TDA4VM | 2x 15p 1.0 mm | 2 each | R15 | 3.3 / **1.8 default** (3.3 option) / ? | 11, 12 | R15 | ⚠️ set board to 3.3 V | ✅ O15 with 1.8 V setting | | S-H |
| TI SK-AM68 | 2x 22p 0.5 mm | 4 each | R22 | 3.3 / **1.8 default** (3.3 option) / ? | 17, 18 | R22 | ⚠️ set board to 3.3 V | ✅ O22 with 1.8 V setting | | S-H |
| AMD Kria KV260 (J9) | 15p 1.0 mm "RPi camera" | 2 | R15 | 3.3 / 3.3 / ? | ? | R15 | ✅ | ✅ O15 | | S-H |
| AMD Kria KR260, ZCU104, Ultra96-V2 | no camera FFC (SLVS-EC, FMC, 96Boards mezzanine) | - | - | - | - | - | ❌ | ❌ (ZCU104: an FMC_MIPI-style card instead) | | S-H |
| NXP i.MX 8M Plus EVK, 8M Mini EVK | Mini-SAS | 4 / 2 | NXP | ? | PDN, RST | Mini-SAS | ❌ | ❌ | NXP MINISASTOCSI adapter | S-M |
| NXP i.MX 93 EVK, FRDM-IMX93 | 22p FPC, pitch unconfirmed | 2 | R22 (tentative) | multi-rail via I2C expander / ? / ? | reset via expander | R22? | ? | ? | | S-L |
| ST STM32MP135F-DK | 15p 1.0 mm, TE 1-1734248-5 | 2 | R15 | 3.3 / 3.3 / 3.3 | 11 EN, 12 RST | R15 | ✅ | ✅ O15 | | S-H |
| ST STM32MP257F-DK / -EV1 | 22p 0.5 mm | 2 | R22, but pins 11-16 (D2/D3) reused for ToF/IMU | 3.3 / 3.3 (I) / 3.3 | 17 RST, 18 EN | R22 | ⚠️ 2-lane cameras only | ⚠️ O22 in 2-lane mode, or O15 + 15-22 | | S-H |
| Radxa ROCK 5B/5B+/5C | 31p 0.3 mm | 4 | Radxa-31 | 3.3+5 / 5C: 1.8 / ? | PDN, RST | Radxa-31 | ⚠️ Radxa AC008 (15p) / AC020 (22p) cable | ⚠️ same cables (5C: 1.8 V setting) | | S-M |
| Radxa ROCK 4SE, ROCK 3C | 15p 1.0 mm (R15 envelope) | 2 | reversed RPi order, power on pin 1 | ? | MCLK, PDN | R15 look-alike | ⚠️ only with Radxa AC014 opposite-side cable | ⚠️ O15 + AC014 only; never a stock cable | | S-H |
| Radxa ZERO 3W/3E | 22p 0.5 mm | 4 | R22 (IO1 = CLKOUT) | 3.3 / ? / ? | 17 PDN, 18 clock out | R22 | ✅ (Radxa AC015 15-22) | ✅ O22; IO1 must stay an input | | S-H |
| Orange Pi 5 / 5 Plus | 30p FPC | 4 | Orange Pi | 3.3 / ? / ? | RST, PDN, CLKOUT | OPi-30 | ❌ | ❌ custom cable | | S-M |
| Khadas VIM3 / VIM4 | 30p 0.5 mm (FH34SRJ) | 4 | Khadas | 3.3 / 1.8 / 1.8 | via expander | Khadas-30 | ❌ | ❌ custom interposer | | S-H |
| Pine64 Quartz64/Star64, StarFive VisionFive 2, Milk-V Mars | 30p 0.5 mm | 2-4 | vendor-specific | varies / 1.8-3.3 / varies | RST, PDN | vendor-30 | ❌ (IMX219 driver exists on VF2/Mars) | ❌ custom cable | | S-M |
| Milk-V Duo / Duo S | 16p 0.5 mm (Duo S also 15p 1.0 mm J2) | 2 | Duo-16; Duo S J2 = reversed R15 | 3.3 / 1.8 (J1), 3.3 (J2) | 11 RST, 12 clock | - | ❌ | ❌ custom cable | | S-H |
| Luckfox Pico family | vendor FPC | 2 | vendor | ? / 1.8 / ? | | - | ❌ | ❌ | | S-L |
| Banana Pi BPI-M7, Firefly RK3588 boards | 30/31p FPC | 4 | vendor | ? / 1.8 / ? | | - | ❌ | ❌ | | S-M |
| Libre Computer Le Potato etc., Banana Pi BPI-M5, Orange Pi Zero 3 | none | - | - | - | - | - | ❌ | ❌ | no camera connector | S-H |
| Qualcomm RB3 Gen 2, RB5 | 30p flex / 96Boards mezzanine | 4 | Qualcomm | multi-rail / 1.8 / 1.8 | | - | ❌ | ❌ | | S-H |
| Arduino Portenta X8 / H7 | X8: DF40 board-to-board; H7: parallel DCMI | - | - | - | - | - | ❌ | ❌ | | S-H |
| UP Squared, Lattice CrossLink-NX eval | 31p 0.3 mm / module socket | 4 | vendor | multi-rail | MCLK, RST | - | ❌ | ❌ | | S-M |

## Mechanical families (which boards share a connector)

| Family | Connector | Boards | Cable | Note |
|---|---|---|---|---|
| R15 | 15-pin 1.0 mm FFC, 16 mm wide | Pi 1-4, Jetson Nano, Xavier NX, reComputer J401, TI SK-AM62B, SK-TDA4VM, Kria KV260, STM32MP135F-DK | standard 15-15 | Look-alikes with a different pinout: Radxa ROCK 4SE/3C, Milk-V Duo S J2 |
| R22 | 22-pin 0.5 mm FFC, 11.5 mm wide | Pi Zero/Zero 2 W, Pi 5, CM4/CM5 IO, **Machina SL2610**, Jetson Orin Nano, BeagleBone AI-64, BeagleY-AI, BeaglePlay, BeagleV, TI SK-AM62A/SK-AM68, STM32MP257F, Radxa ZERO 3, (i.MX 93), (Coralboard?) | 22-22 (4 lanes) or 15-22 (2 lanes) | Contact side (top/bottom) differs per board: pick the cable type per host |
| Coral-24 | 24-pin 0.5 mm | Coral Dev Board, Dev Board Mini | Coral camera cable | Lane order differs from R22 |
| Vendor 30/31-pin | 30p 0.5 mm, 31p 0.3 mm | Radxa ROCK 5, Orange Pi 5, Khadas, Pine64, StarFive, BPI-M7, Firefly, Qualcomm | vendor cables | Pinout differs per vendor, even with the same connector |
| Samtec QSH-060 | 120-pin 0.5 mm board-to-board | Jetson TX2, AGX Xavier, AGX Orin | - | FMC_MIPI J2 is the mating QTH plug |
| Other | Mini-SAS, Hirose DF40, 96Boards HS, FMC | NXP i.MX 8M EVKs, Coral Micro, Portenta X8, Ultra96, RB5, ZCU104 | - | dedicated adapters only |

## What to do with each group

1. **Reachable with O15 + O22** (class A/B, about 25 boards): every Raspberry Pi with a camera
   connector, Machina SL2610, Jetson Nano/Xavier NX/Orin Nano, BeagleBoard, TI SK, Kria KV260,
   STM32MP1/MP2, Radxa ZERO 3.
2. **Reachable with bridge options**:
   * 1.8 V host I/O: TI SK-TDA4VM/SK-AM68 (default setting), Jetson Orin Nano GPIOs, Radxa ROCK 5C.
   * CAM_IO1 routing: Jetson Nano/Xavier NX drive MCLK on pin 12; Radxa ZERO 3 outputs a clock on
     pin 18.
   * 2-lane mode on O22: STM32MP257F.
3. **Needs a passive adapter** (no electronics, only re-pinning): Coral Dev Board/Mini (24p to O22),
   Radxa ROCK 5 (vendor cables exist), Radxa ROCK 4SE/3C (vendor opposite-side cable). Possible later
   as small FFC adapter boards.
4. **Needs a dedicated adapter**: Rockchip/Khadas/Pine64/StarFive 30-pin boards (custom interposer, often
   1.8 V), NXP Mini-SAS, Qualcomm.
5. **Already covered by FMC_MIPI**: Jetson TX2 (and probably AGX Xavier/AGX Orin, to verify) take
   FMC_MIPI J2 directly.
6. **Out of scope**: boards without a MIPI camera connector (Pi 400/500, Le Potato, BPI-M5, Orange Pi
   Zero 3, KR260, Portenta H7).
7. **Coralboard SL**: measure the connector first. If it is R22 with 3.3 V I/O, it is in group 1.

## Pitfalls

* **Same connector does not mean the same pinout**: ROCK 4SE/3C and Milk-V Duo S J2 use the R15
  envelope with reversed signals. Compare the signal order, not the pin count.
* **Pin numbering direction differs**: Synaptics J206 and NVIDIA Orin Nano number R22 from the 3V3 end.
* **Contact side**: bottom-contact (Machina J206, Orin Nano, most BeagleBoards) versus top-contact
  connectors decide whether a same-side or an opposite-side cable is needed. A 15-22 cable carries only
  2 lanes.
* **I/O levels**: some hosts use 1.8 V I2C (TI SK default, Khadas, Rockchip boards). Orin Nano mixes
  3.3 V I2C with 1.8 V GPIO, so the bridge's host-side GPIO inputs must switch at 1.8 V levels.
* **GPIO meaning differs**: power-enable (RPi), power-down (Jetson, Coral; polarity differs), MCLK
  output (Jetson Nano pin 12), clock out (Radxa ZERO 3). Never drive CAM_IO0/IO1 from the bridge by
  default.
* **I2C jumpers**: CM4 IO (CAM0) and CM5 IO (CAM/DISP1) need J6 jumpers.
* **Shared I2C buses**: Machina's camera bus also carries power management, and the Pi 3B+ camera bus is
  shared with the display. The bridge must never hold the bus low, and the emulated sensor address must
  be free (FMC_MIPI's EEPROM also answers at 0x54/0x5C).
* **Host software**: the host needs a driver and device-tree entry for the emulated sensor. OV5647
  (0x36) is supported by the Pi, Machina and Coralboard. IMX219 (0x10) is supported by the Pi, Jetson
  Nano/Xavier NX/Orin Nano and VisionFive 2. FMC_MIPI's current firmware profile is the NVIDIA E3326
  (OV5693).
