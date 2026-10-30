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
| CM1/CM3/CM3+/CM4S IO board (CMIO) | 2x 22p 0.5 mm, Molex 54548-2271 | 2 each | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ 15-22 cable or RPi CMCDA adapter | ✅ O22 | | S-M |
| Raspberry Pi 400 / 500 | none | - | - | - | - | - | ❌ | ❌ | no camera connector | S-H |
| Jetson Nano dev kit (A02, B01, 2 GB) | 15p 1.0 mm (B01: x2) | 1x2 each | R15-like | 3.3 / 3.3 (I) / ? | 11 PWDN, 12 MCLK out | R15 | ✅ (NVIDIA lists RPi v2 and HQ) | ⚠️ O15: route IO1 to J2 91 (MCLK) or leave open | | V-H list / S-M pins |
| Seeed reComputer J1010 / J101 (Nano carrier) | 2x 15p 1.0 mm, I2C mux | 2 each | R15 (pins 1-11, 13-15 match) | 3.3 / 3.3 / ? | 11 PWDN, 12 MCLK | R15 | ✅ | ⚠️ as Nano | | S-H |
| Jetson Xavier NX dev kit | 15p 1.0 mm x2 | 2 each | R15-like | 3.3 / 3.3 (I) / ? | as Nano (I) | R15 | ✅ (same camera list as Nano) | ⚠️ as Nano | | V-M |
| Jetson Orin Nano / Orin Nano Super | 2x 22p 0.5 mm, bottom contact | CAM0 2, CAM1 2 or 4 | R22 order, numbered from 3V3 end | 3.3 / 3.3 / **1.8** | MCLK (=IO1), PWDN (=IO0) at 1.8 V | R22 | ✅ RPi v2 with 15-22 cable (NVIDIA) | ⚠️ O22 or O15 + 15-22; GPIO inputs must accept 1.8 V | | V-H conn / S-H levels |
| Seeed reComputer J401 | 2x 15p 1.0 mm | 2 each | R15-like | ? | 12 likely MCLK | R15 | ⚠️ ? | ⚠️ as Nano | | S-L |
| Jetson TX2, AGX Xavier, AGX Orin | Samtec QSH-060, 120p 0.5 mm board-to-board | up to 6x2 / 4x4 | Jetson 120-pin | multi-rail / 1.8 / 1.8 | many | QSH-060 | ❌ | n/a: FMC_MIPI J2 plugs in directly (TX2 by design; AGX pinout to verify) | AGX Orin J509: 1.8 V I2C, 1 kOhm pull-ups | V-H TX2 / S-L AGX |
| Coral Dev Board, Dev Board Mini | 24p 0.5 mm | 4-capable | Coral-24: CK at 5/6, PWDNB 17, RESETB 23, SCL/SDA 20/21, 3V3 24 | 3.3 / 3.3 (4.7k) / 3.3 | PWDNB, RESETB | Coral-24 | ❌ | ❌ needs a 24-pin passive adapter | | V-H Dev Board / S-H Mini |
| Coral Dev Board Micro | 2x Hirose DF40C-100DP-0.4V board-to-board | 2 | - | ? / no I2C found / 1.8 | - | - | ❌ | ❌ | | S-H |
| BeagleBone AI-64 | 2x 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | | S-H |
| BeagleY-AI | 2x 22p 0.5 mm | 4 | R22 | 3.3 / 3.3 / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | J16 shared with DSI | S-H |
| BeaglePlay | 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 1.8 or 3.3 (unclear) / ? | 17, 18 | R22 | ⚠️ | ⚠️ select level after checking | | S-M |
| BeagleV-Ahead, BeagleV-Fire | 22p 0.5 mm, bottom contact | 4 | R22 | 3.3 / 3.3 / 3.3 | 17 (Fire: PWDN only) | R22 | ✅ | ✅ O22 | | S-H |
| TI SK-AM62B | 15p 1.0 mm, TE 1-1734248-5 | 1x2 | R15 (TI: "compatible") | 3.3 / 3.3 / 3.3 | 11, 12 | R15 | ✅ | ✅ O15 | | S-H |
| TI SK-AM62A-LP | 22p 0.5 mm (J20) | 4 | R22 | 3.3 / 3.3 (TCA9543A) / 3.3 | 17, 18 | R22 | ✅ | ✅ O22 | J1: Samtec QSH-020 40p mezzanine for TI camera boards (❌), 2:1 muxed with J20 | S-H |
| TI SK-TDA4VM | 2x 15p 1.0 mm, TE 1-1734248-5 | 2 each | R15 | 3.3 / **1.8 default** (3.3 option) / ? | 11, 12 | R15 | ⚠️ set board to 3.3 V | ✅ O15 with 1.8 V setting | J24: Samtec QSH-020 mezzanine (❌) | S-H |
| TI SK-AM68 | 2x 22p 0.5 mm, Molex 52435-2271 | 4 each | R22 | 3.3 / **1.8 default** (3.3 option) / ? | 17, 18 | R22 | ⚠️ set board to 3.3 V | ✅ O22 with 1.8 V setting | J20: Samtec QSH-020 mezzanine (❌) | S-H |
| AMD Kria KV260 (J9) | 15p 1.0 mm "RPi camera" | 2 | R15 | 3.3 / 3.3 / ? | ? | R15 | ✅ | ✅ O15 | J7/J8 IAS connectors (4 lanes, 2.75/1.8/1.2 V rails) are ❌ | S-H |
| AMD Kria KR260, ZCU104, Ultra96-V2 | no camera FFC (SLVS-EC, FMC, 96Boards mezzanine) | - | - | - | - | - | ❌ | ❌ (ZCU104: an FMC_MIPI-style card instead) | | S-H |
| NXP i.MX 8M Plus EVK, 8M Mini EVK | Mini-SAS | 4 / 2 | NXP | ? | PDN, RST | Mini-SAS | ❌ | ❌ | NXP MINISASTOCSI adapter | S-M |
| Toradex Verdin development board | Hirose FH12-24S-0.5SVA, 24p 0.5 mm (X47) | 4 | Toradex | ? | MCLK from host | - | ❌ | ❌ | | S-H |
| Variscite Symphony-Board | Samtec HSEC8 card edge, 60p 0.8 mm | 4 | Variscite | 3.3+1.8 / **1.8** / ? | dedicated pins | - | ❌ | ❌ | | S-H |
| NXP i.MX 93 EVK, FRDM-IMX93 | 22p FPC, pitch unconfirmed | 2 | R22 (tentative) | multi-rail via I2C expander / ? / ? | reset via expander | R22? | ? | ? | | S-L |
| ST STM32MP135F-DK | 15p 1.0 mm, TE 1-1734248-5 | 2 | R15 | 3.3 / 3.3 / 3.3 | 11 EN, 12 RST | R15 | ✅ | ✅ O15 | | S-H |
| ST STM32MP257F-DK / -EV1 | 22p 0.5 mm | 2 | R22, but pins 11-16 (D2/D3) reused for ToF/IMU | 3.3 / 3.3 (I) / 3.3 | 17 RST, 18 EN | R22 | ⚠️ 2-lane cameras only | ⚠️ O22 in 2-lane mode, or O15 + 15-22 | | S-H |
| Radxa ROCK 5B/5B+/5C | 31p 0.3 mm (5C: FH35C-31S-0.3SHW) | 4 (5B: 2 connectors) | Radxa-31, lane order reversed vs RPi | 3.3+5 / 5C: 1.8 / ? | PDN, RST | Radxa-31 | ⚠️ Radxa AC008 (15p) / AC020 (22p) cable | ⚠️ same cables (5C: 1.8 V setting) | | S-M |
| Radxa ROCK 4SE, ROCK 3C | 15p 1.0 mm (R15 envelope) | 2 | reversed RPi order, power on pin 1 | ? | MCLK, PDN | R15 look-alike | ⚠️ only with Radxa AC014 opposite-side cable | ⚠️ O15 + AC014 only; never a stock cable | | S-H |
| Radxa ZERO 3W/3E | 22p 0.5 mm | 4 | R22 (IO1 = CLKOUT) | 3.3 / ? / ? | 17 PDN, 18 clock out | R22 | ✅ (Radxa AC015 15-22) | ✅ O22; IO1 must stay an input | | S-H |
| Orange Pi 5 / 5 Plus | 30p FPC (OPi 5: 3 connectors, 5 Plus: 1) | 4 | Orange Pi | 3.3 / ? / ? | RST, PDN, CLKOUT | OPi-30 | ❌ | ❌ custom cable | OPi 5 and 5 Plus name the pin polarities differently | S-M |
| Khadas VIM3 / VIM3L / VIM4 | 30p 0.5 mm (FH34SRJ-30S) | 4 (VIM3L: 2) | Khadas | 3.3 / 1.8 / 1.8 | via expander (VIM4: direct GPIO) | Khadas-30 | ❌ | ❌ custom interposer | VIM4 CSI2 is a 20p connector without I2C or power | S-H |
| Pine64 Quartz64/Star64, StarFive VisionFive 2, Milk-V Mars | 30p 0.5 mm | 2-4 | vendor-specific | varies / 1.8-3.3 / varies | RST, PDN | vendor-30 | ❌ (IMX219 driver exists on VF2/Mars) | ❌ custom cable | Quartz64 A: 1.8 V I2C, Quartz64 B: 3.3 V; Star64 carries 2.8/1.8/1.2 V rails on the connector | S-M |
| Milk-V Duo / Duo S | 16p 0.5 mm (Duo S also 15p 1.0 mm J2) | 2 | Duo-16; Duo S J2 = reversed R15 | 3.3 / 1.8 (J1), 3.3 (J2) | 11 RST, 12 clock | - | ❌ | ❌ custom cable | Duo S J2: CLK and RST in place of IO1/IO0 | S-H |
| Sipeed MaixCAM / MaixCAM Pro / LicheeRV Nano | 22p, pitch probably 0.5 mm | 4 (dual 2-lane split) | probably R22 (a sibling board states RPi 22-pin compatibility) | ? | ? | R22? | ⚠️ unverified; vendor validates only its own sensors | ⚠️ unverified | Sipeed sells a 15p-to-22p RPi camera adapter | S-M |
| Luckfox Pico family | vendor FPC | 2 | vendor | ? / 1.8 / ? | | - | ❌ | ❌ | | S-L |
| Banana Pi BPI-M7 | 2x 31p 0.5 mm | 2 or 4 (docs disagree) | vendor | 3.3+5 / 1.8 / ? | 2x PDN, RST; pins 17/18 = clock pair | - | ❌ | ❌ | | S-M |
| Firefly RK3588/RK3588S boards | 30p 0.5 mm, 1-3 per board | 4, or 2x2 split | vendor | multi-rail / ? / ? | power-down polarity inconsistent, even on one board | - | ❌ | ❌ | | S-M |
| Libre Computer Solitude / Alta | 22p 0.5 mm (+2 mounting) | 4 | R22 positions, but 17/18 = second clock pair | 3.3 / 3.3 / - | no GPIO | R22 | ⚠️ cable fits, no host driver | ⚠️ O22 lanes fit; no power-enable from host | | S-H |
| Libre Computer Renegade Elite | 2x 24p 0.5 mm (+2) | ? | mirror-reversed lanes, P before N | **5 V** (VCC_SYS) / 1.8 / ? | | - | ❌ | ❌ (5 V on the camera power pin!) | | S-H |
| Libre Computer Tritium | 24p 0.5 mm (+2) | parallel DVP, not MIPI | - | - | - | - | ❌ | ❌ | | S-H |
| Libre Le Potato / Sweet Potato / La Frite / Renegade, Banana Pi BPI-M5, Orange Pi Zero 3, Sipeed LicheeRV Dock, UP Xtreme | none | - | - | - | - | - | ❌ | ❌ | no camera connector | S-H |
| Qualcomm RB3 Gen 2, RB5 | 30p flex / 96Boards mezzanine | 4 | Qualcomm | multi-rail (2.8/1.8/1.1-1.2) / 1.8 / 1.8 | strobe, RST, PWDN | - | ❌ | ❌ | Vision mezzanine mixes P/N order on one connector | S-H |
| Arduino Portenta X8 / H7 | X8: 2x Hirose DF40 80p board-to-board; H7: parallel DCMI | - | - | - | - | - | ❌ | ❌ | Breakout board J4 has an OpenMV-style camera socket (probably 1.8 V) | S-H |
| UP Squared, Lattice CrossLink-NX eval | UP: 31p 0.3 mm (CN4, 4 lanes) + 21p (CN5, 2 lanes); Lattice: 30p module socket | 4 | vendor | multi-rail (2.8/1.8/1.2) | MCLK, RST | - | ❌ | ❌ | CrossLink-NX lane order: CK, D3, D1, D0, D2 | S-M |

## Mechanical families (which boards share a connector)

| Family | Connector | Boards | Cable | Note |
|---|---|---|---|---|
| R15 | 15-pin 1.0 mm FFC, 16 mm wide. RPi reference part: Amphenol SFW15R-2STE1LF; TE 1-1734248-5 on Pi 3B+, SK-AM62B, SK-TDA4VM, STM32MP135F-DK, Jetson Nano A02 | Pi 1-4, Jetson Nano, Xavier NX, reComputer J401/J1010, TI SK-AM62B, SK-TDA4VM, Kria KV260, STM32MP135F-DK | standard 15-15 | Look-alikes with a different pinout: Radxa ROCK 4SE/3C, Milk-V Duo S J2 |
| R22 | 22-pin 0.5 mm FFC, 11.5 mm wide. RPi reference part: Amphenol F32Q-1A7H1-11022. Others: Molex 54548-2271 (Pi Zero, CMIO, CM4 IO), Molex 54548-2272 (Orin Nano), Molex 52435-2271 (TI), Shenzhen Best 0.5K-DX-22PWB (BeagleBoard), MTCONN MTFP65-822SWN-19A72 (BeagleY-AI), Molex 505110-2296? (Machina) | Pi Zero/Zero 2 W, Pi 5, CMIO, CM4/CM5 IO, **Machina SL2610**, Jetson Orin Nano, BeagleBone AI-64, BeagleY-AI, BeaglePlay, BeagleV, TI SK-AM62A/SK-AM68, STM32MP257F, Radxa ZERO 3, Sipeed MaixCAM (?), (i.MX 93), (Coralboard?) | 22-22 (4 lanes) or 15-22 (2 lanes) | Contact side (top/bottom) differs per board: pick the cable type per host. Look-alike: Libre Solitude/Alta (clock pair on 17/18) |
| Coral-24 | 24-pin 0.5 mm | Coral Dev Board, Dev Board Mini | Coral camera cable | Lane order differs from R22 |
| 24-pin others | 24-pin 0.5 mm | Toradex Verdin (Hirose FH12-24S), Libre Renegade Elite, Libre Tritium (parallel) | vendor | Not related to Coral-24 or to each other |
| Vendor 30/31-pin | 30p 0.5 mm, 31p 0.3 mm | Radxa ROCK 5, Orange Pi 5, Khadas, Pine64, StarFive, Milk-V Mars, BPI-M7, Firefly, Qualcomm, UP Squared | vendor cables | Pinout differs per vendor, even with the same connector |
| Samtec QSH-060 | 120-pin 0.5 mm board-to-board | Jetson TX2, AGX Xavier, AGX Orin | - | FMC_MIPI J2 is the mating QTH plug |
| Samtec QSH-020 | 40-pin 0.5 mm board-to-board | TI SK-AM62A (J1), SK-AM68 (J20), SK-TDA4VM (J24) | - | TI camera mezzanine, different from QSH-060 |
| Other | Mini-SAS, Hirose DF40, Samtec HSEC8 card edge, 96Boards HS, FMC | NXP i.MX 8M EVKs, Coral Micro, Portenta X8, Variscite Symphony, Ultra96, RB5, ZCU104 | - | dedicated adapters only |

## Most popular boards

Ranking is a qualitative mix of community size, documented shipping volume and maker-ecosystem
presence (no public sales data). The three targets are not ranked.

| Rank | Board | Bridge coverage |
|---|---|---|
| 1 | Raspberry Pi 4 B | ✅ O15 |
| 2 | Raspberry Pi 3 B+ | ✅ O15 (target) |
| 3 | Raspberry Pi Zero 2 W | ✅ O22, or O15 + 15-22 cable |
| 4 | Raspberry Pi 5 | ✅ O22 (4 lanes possible) |
| 5 | Raspberry Pi CM4 (IO board) | ✅ O22 (CAM0 needs J6 jumpers) |
| 6 | NVIDIA Jetson Nano (A02/B01) | ⚠️ O15, CAM_IO1 = MCLK from host |
| 7 | NVIDIA Jetson Orin Nano (Super) | ⚠️ O22, or O15 + 15-22 cable; 1.8 V GPIO |
| 8 | Radxa ROCK 5B/5B+ | ⚠️ through Radxa AC008/AC020 cables |
| 9 | Orange Pi 5 / 5 Plus | ❌ custom cable |
| 10 | BeagleBone AI-64 / BeagleY-AI | ✅ O22 |
| 11 | Google Coral Dev Board | ❌ 24-pin passive adapter |
| 12 | NVIDIA Jetson Xavier NX | ⚠️ O15, as Jetson Nano |
| 13 | Khadas VIM3 / VIM4 | ❌ custom interposer (1.8 V) |
| 14 | Libre Le Potato / Banana Pi BPI-M5 | no camera connector |
| 15 | TI SK-AM62B / SK-AM62A-LP | ✅ O15 / O22 |

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
   1.8 V), NXP Mini-SAS, Qualcomm, Toradex Verdin, Variscite.
5. **Already covered by FMC_MIPI**: Jetson TX2 (and probably AGX Xavier/AGX Orin, to verify) take
   FMC_MIPI J2 directly.
6. **Out of scope**: boards without a MIPI camera connector (Pi 400/500, Le Potato, BPI-M5, Orange Pi
   Zero 3, KR260, Portenta H7, Libre Tritium with parallel camera), and Libre Renegade Elite (5 V on the
   camera power pin).
7. **Coralboard SL**: measure the connector first. If it is R22 with 3.3 V I/O, it is in group 1.

## Cables and adapters

| Cable / adapter | Ends | Used for |
|---|---|---|
| RPi standard camera cable | 15p 1.0 mm to 15p 1.0 mm | Pi 1-4 |
| RPi camera cable for Pi Zero / Pi 5 | 15p 1.0 mm (camera) to 22p 0.5 mm (host), 2 lanes | Pi Zero, Pi 5, CM IO boards; also Machina J206 and Orin Nano |
| RPi CMCDA (Compute Module Camera/Display Adapter) | 22p (CMIO, Molex 54548-2271) to 15p, 1:1 signals | CM1/CM3/CM3+/CM4S IO board to 15-pin cameras |
| Radxa AC004 | 15p 0.3 mm to 15p 1.0 mm, same side | ROCK 4C+ |
| Radxa AC008 | 31p 0.3 mm to 15p 1.0 mm, same side | ROCK 5A/5B/5B+/5C, Cubie A5E/A7A/A7Z/A7S |
| Radxa AC020 | 31p 0.3 mm to 22p 0.5 mm, same side | ROCK 5 series to RPi 22-pin cameras |
| Radxa AC015 | 22p 0.5 mm to 15p 1.0 mm, same side | ZERO 3W/3E |
| Radxa AC014 | 15p 1.0 mm to 15p 1.0 mm, opposite side | ROCK 3C / 4SE / 4D, Dragon Q6A |
| NXP MINISASTOCSI | Mini-SAS to NXP camera module | i.MX 8M Plus / Mini EVK |
| NXP RPI-CAM-MIPI | 22p FPC accessory with AR0144 + AP1302 | i.MX 93 EVK / FRDM-IMX93; not shown to accept a stock RPi camera |
| TI / e-con 15-to-22 cable | 15p 1.0 mm to 22p 0.5 mm | e-CAM modules on SK-AM68 |
| Sipeed RPi 15p to LicheeRV 22p adapter | 15p 1.0 mm to 22p | LicheeRV Nano / MaixCAM |
| Arducam / uctronics 15-to-22 cables | 15p 1.0 mm to 22p 0.5 mm | BeaglePlay (recommended by BeagleBoard docs) and other R22 hosts |
| Arducam "universal" adapter boards | various | marketed for many hosts; check each pinout against the host documentation |

## Pitfalls

* **Same connector does not mean the same pinout**: ROCK 4SE/3C and Milk-V Duo S J2 use the R15
  envelope with reversed signals, and Libre Solitude/Alta carries a second clock pair on R22 pins 17/18.
  Compare the signal order, not the pin count.
* **Pin numbering direction differs**: Synaptics J206 and NVIDIA Orin Nano number R22 from the 3V3 end.
  The research survey misread the Orin Nano as "reversed" for this reason. NVIDIA states that an RPi
  v2 camera works there with a 15-to-22 cable.
* **Contact side**: bottom-contact (Machina J206, Orin Nano, most BeagleBoards) versus top-contact
  connectors decide whether a same-side or an opposite-side cable is needed. A 15-22 cable carries only
  2 lanes.
* **22-pin does not mean 4 lanes**: Pi Zero, the CMIO board, STM32MP257F and some RISC-V boards wire only
  2 lanes on a 22-pin connector.
* **I/O levels**: some hosts use 1.8 V I2C (TI SK default, Khadas, Rockchip boards, Variscite, Qualcomm).
  Orin Nano mixes 3.3 V I2C with 1.8 V GPIO, so the bridge's host-side GPIO inputs must switch at 1.8 V
  levels.
* **Camera power pin**: usually 3.3 V, but Libre Renegade Elite puts 5 V (VCC_SYS) on it. Industrial
  boards often provide several camera rails (2.8/1.8/1.2 V: UP Squared, CrossLink-NX, Qualcomm, i.MX 93
  through I2C expanders, Star64). No vendor publishes the camera-supply current budget.
* **GPIO meaning differs**: power-enable (RPi), power-down (Jetson, Coral; polarity differs), MCLK
  output (Jetson Nano pin 12), clock out (Radxa ZERO 3), second clock pair (Libre Alta). Many hosts
  drive an MCLK (Jetson, Toradex, UP, Radxa ROCK 4SE/3C, Pine64, StarFive). Never drive CAM_IO0/IO1 from
  the bridge by default, and accept or ignore a host clock.
* **D-PHY lane order and P/N order vary**: Radxa ROCK 3C/4SE reverse both, ROCK 5 reverses lane order,
  Qualcomm's Vision mezzanine mixes P/N order on one connector, CrossLink-NX uses CK, D3, D1, D0, D2.
  FMC_MIPI's lane order and polarity are fixed in copper, so adapters must fix them in copper. A
  firmware swap may be possible because FMC_MIPI drives each LP line separately, but it has not been
  tried.
* **I2C jumpers**: CM4 IO (CAM0) and CM5 IO (CAM/DISP1) need J6 jumpers.
* **I2C topology**: Jetson dual-camera carriers use an I2C mux, TI uses a TCA9543A switch per connector,
  BeagleBoard gives each connector its own bus. Some boards share the camera bus with an ID EEPROM or
  the GPIO header (BeagleV-Fire, Milk-V Duo S).
* **Shared I2C buses**: Machina's camera bus also carries power management, and the Pi 3B+ camera bus is
  shared with the display. The bridge must never hold the bus low, and the emulated sensor address must
  be free (FMC_MIPI's EEPROM also answers at 0x54/0x5C).
* **Board-to-board connectors are not camera connectors**: Ultra96, RB5, Portenta X8 and ZCU104 expose
  CSI only as raw pins on a general expansion connector.
* **Host software**: the host needs a driver and device-tree entry for the emulated sensor. OV5647
  (0x36) is supported by the Pi, Machina and Coralboard. IMX219 (0x10) is supported by the Pi, Jetson
  Nano/Xavier NX/Orin Nano and VisionFive 2. FMC_MIPI's current firmware profile is the NVIDIA E3326
  (OV5693). Electrical fit and driver support are separate questions: Libre Alta takes an RPi camera
  cable but has no driver for it, while VisionFive 2 / Milk-V Mars have IMX219/IMX708 drivers but a
  different connector.

## Unknowns

* Coralboard SL camera connector: type, pin 1, pinout, I2C level. The kit photos on
  developers.google.com show it, but they could not be analysed in this session.
* The Molex part number behind Machina J206 (`CON_5051102296`) and its exact contact side.
* Whether FMC_MIPI J2 is pin-compatible with the Jetson AGX Xavier / AGX Orin camera connectors.
* Pi 5: the board-level pin table is not schematic-confirmed (RPi documentation and the CM5 IO
  datasheet agree with R22).
* Jetson Xavier NX / AGX / TX2 and NXP i.MX 8M / i.MX 93 connector details are behind vendor logins.
* Contact side (top or bottom) is published for only a few boards (RPi, BeagleBoard, Orin Nano, Machina).
* Per-lane rates at board level are mostly unpublished (known: Pi 3B+/4B 1 Gb/s, Pi 5 and SL2610
  1.5 Gb/s).
* Radxa cable wiring diagrams (JavaScript-rendered pages) and the Firefly camera I2C level were not
  available.
