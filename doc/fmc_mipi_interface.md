# FMC_MIPI J2 interface (bridge input side)

The bridge plugs into connector **J2** of the [FMC_MIPI](https://github.com/VideoGPU/FMC_MIPI) board.
J2 carries the NVIDIA Jetson TX1/TX2 developer-kit camera-connector pinout: towards J2 the FMC_MIPI
board looks like a Jetson camera module (E3326-like). The bridge must look like the Jetson carrier
board to FMC_MIPI, and like a camera module to the target host boards.

Source of the data below: `VideoGPU/FMC_MIPI` commit `6afc7c8` (branch `rev_2021_reduced`; the design
files are identical on `master` `319e640`), netlist `FMC_MIPI_v2.net` (KiCad 6.0.9), sheets
`Jetson_connector`, `LVDS_to_Jetson_lines`, `Slow_signals_level_shifters`, `Power`.

## Connector

| Item | Value |
|---|---|
| FMC_MIPI J2 | Samtec **QTH-060-01-L-D-A** (0.5 mm pitch terminal strip, 120 signal pins + 8 ground-plane pads G1-G8) |
| Bridge mate | Samtec **QSH-060-01-L-D-A** socket (same part as on the Jetson TX1/TX2 carrier), 5 mm mated height |
| Footprint | `FMC_MIPI/Libraries/FMC_MIPI_v2.pretty/samtec-qsh-QSH-060-01-X-D-A.kicad_mod` can be reused (check pin-1 orientation against the Samtec drawing in `doc/vendor/connectors/`) |
| SI rating | 10.5 GHz / 21 Gb/s differential at 5 mm stack (Samtec QSH/QTH product spec) |

## FPGA side (for firmware and bring-up)

FMC_MIPI J1 is a Samtec ASP-134488-01 (FMC HPC footprint). Only LA-bank pins are used. The
MIPI_CSI2_TX constraints (`constrains_for_KC705.xdc`) place it on the KC705 **FMC HPC connector J22**:
`cam0_mclk` is FPGA pin G22 = HPC LA31_P (UG810). KC705 VADJ_FPGA powers the FPGA side of every FMC_MIPI
level shifter. Its default is 2.5 V (1.8 V and 3.3 V are possible; UG810).

| Function | FMC pin | FMC_MIPI path |
|---|---|---|
| HS port C: CLK / D0 / D1 | LA00_CC / LA07 / LA04 | resistor networks -> U5 B port |
| HS port D: CLK / D0 / D1 | LA32 / LA30 / LA28 | resistor networks -> U6 B port |
| LP port C: CLK / D0 / D1 | LA19 / LA15 / LA11 | U8 (1.2 V side) -> U5 C port |
| LP port D: CLK / D0 / D1 | LA20 / LA16 / LA12 | U8 (1.2 V side) -> U6 C port |
| HS/LP select, data lanes of C and D | LA08_P | IC1 -> SEL1 of U5 and U6 |
| HS/LP select, clock lanes of C and D | LA08_N | IC1 -> SEL2 of U5 and U6 |
| Port C switch enable (EN_U5) | LA09_P, net `FMC_EN_MIPI_OUT_DATA_VADJ`, xdc `en_mipi_out_data_vadj` | IC1 -> R37 -> U5 EN |
| Port D switch enable (EN_U6) | LA09_N, net `FMC_EN_MIPI_OUT_CLOCK_VADJ`, xdc `en_mipi_out_clock_vadj` | IC1 -> R38 -> U6 EN |
| FPGA -> host GPIO enable (active low) | LA13_P | IC7 -> U3 2OE |
| I2C_CAM / CAM_I2C2 / I2C_GP0 (SCL, SDA) | LA22_N, LA22_P / LA03_P, LA05_P / LA02_P, LA03_N | IC3 / IC4 / IC5 TCA9406 |
| MCLK / PWR / RST from host | LA31_P / LA29_P / LA25_N | U3 |
| GPIO9 / CAM_INTR to host | LA26_N / LA26_P | U3 |
| Host rail sense 3V3 / 2V8 / 1V8 / 1V2 | LA01_N_CC / LA01_P_CC / LA25_P / LA02_N | U2 / U2 / U3 / IC6 |

The "DATA" and "CLOCK" names of the two switch-enable nets are misleading: LA09_P enables the whole
port C switch, and LA09_N enables the whole port D switch.

## Known limitation of this FMC_MIPI revision

`FMC_MIPI/review_2021.txt` notes that the TS3DDR3812 switch (U5/U6) is "not good for handling SLVS
signals" (D-PHY HS). It points to XAPP1339 and suggests HD3SS3411, TMUXHS4412, Diodes PI3WVR628 (a MIPI
switch) or TS5MP645 for a future revision. The bridge cannot fix this. It should add as little as
possible to the channel (short, 100 Ohm differential, no stubs or test points on the lanes), and the
lane eye should be checked at the host connector during bring-up.

## Pins used by FMC_MIPI

Direction is seen from FMC_MIPI ("Out" = FMC_MIPI drives towards the host).

| J2 pin | TX2 carrier signal | FMC_MIPI net | Dir (FMC_MIPI) | Level | FMC_MIPI path |
|---|---|---|---|---|---|
| 19 | CSI2_D0+ | `CSI_C_D0_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA07_P; LP: U8 |
| 20 | CSI3_D0+ | `CSI_D_D0_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA30_P; LP: U8 |
| 21 | CSI2_D0- | `CSI_C_D0_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA07_N; LP: U8 |
| 22 | CSI3_D0- | `CSI_D_D0_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA30_N; LP: U8 |
| 25 | CSI2_CLK+ | `CSI_C_CLK_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA00_P_CC; LP: U8 |
| 26 | CSI3_CLK+ | `CSI_D_CLK_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA32_P; LP: U8 |
| 27 | CSI2_CLK- | `CSI_C_CLK_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA00_N_CC; LP: U8 |
| 28 | CSI3_CLK- | `CSI_D_CLK_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA32_N; LP: U8 |
| 31 | CSI2_D1+ | `CSI_C_D1_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA04_P; LP: U8 |
| 32 | CSI3_D1+ | `CSI_D_D1_P` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA28_P; LP: U8 |
| 33 | CSI2_D1- | `CSI_C_D1_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U5 TS3DDR3812 -> HS: FPGA LA04_N; LP: U8 |
| 34 | CSI3_D1- | `CSI_D_D1_N` | Out | D-PHY (HS via resistor network / LP 1.2 V) | U6 TS3DDR3812 -> HS: FPGA LA28_N; LP: U8 |
| 75 | I2C_CAM_CLK | `JT_1p8V_I2C_CAM_CLK` | I/O (OD) | 1.8 V I2C | IC3 TCA9406 -> FPGA LA22_N/P; also AT24MAC402 EEPROM (0x54/0x5C) |
| 77 | I2C_CAM_DAT | `JT_1p8V_I2C_CAM_DAT` | I/O (OD) | 1.8 V I2C | IC3 TCA9406 -> FPGA LA22_N/P; also AT24MAC402 EEPROM (0x54/0x5C) |
| 81 | AVDD_CAM | `JT_VDD_2V8` | Sense | host 2.8 V rail | R32 2.2k -> U2 A1 (3.3 V side) -> FPGA LA01_P_CC |
| 82 | AVDD_CAM | `JT_VDD_2V8` | Sense | host 2.8 V rail | R32 2.2k -> U2 A1 (3.3 V side) -> FPGA LA01_P_CC |
| 83 | AVDD_CAM | `JT_VDD_2V8` | Sense | host 2.8 V rail | R32 2.2k -> U2 A1 (3.3 V side) -> FPGA LA01_P_CC |
| 87 | CAM_I2C2_SCL | `JT_1p8V_I2C2_CAM_CLK` | I/O (OD) | 1.8 V I2C | IC4 TCA9406 -> FPGA LA03_P/LA05_P |
| 89 | CAM_I2C2_SDA | `JT_1p8V_I2C2_CAM_DAT` | I/O (OD) | 1.8 V I2C | IC4 TCA9406 -> FPGA LA03_P/LA05_P |
| 91 | CAM0_MCLK | `JT_1p8V_CAM0_MCLK` | In | 1.8 V CMOS (3.6 V tolerant, bus-hold) | U3 1A1 -> FPGA LA31_P |
| 93 | GPIO0_CAM0_PWR | `JT_1p8V_CAM0_PWR` | In | 1.8 V CMOS (3.6 V tolerant, bus-hold) | U3 1A3 -> FPGA LA29_P |
| 95 | GPIO2_CAM0_RST | `JT_1p8V_CAM0_RST` | In | 1.8 V CMOS (3.6 V tolerant, bus-hold) | U3 1A4 -> FPGA LA25_N |
| 101 | DVDD_CAM_IO_1V2 | `JT_VDD_1V2` | Sense | host 1.2 V rail | R29 2.2k -> IC6 -> FPGA LA02_N |
| 102 | DVDD_CAM_IO_1V8 | `JT_VDD_1V8` | Sense | host 1.8 V rail | R31 2.2k -> U3 1A5 -> FPGA LA25_P; JP1 option: EEPROM VCC |
| 105 | I2C_GP0_CLK_1V8 | `JT_1p8V_I2C3_CAM_CLK` | I/O (OD) | 1.8 V I2C | IC5 TCA9406 -> FPGA LA02_P/LA03_N |
| 107 | I2C_GP0_DAT_1V8 | `JT_1p8V_I2C3_CAM_DAT` | I/O (OD) | 1.8 V I2C | IC5 TCA9406 -> FPGA LA02_P/LA03_N |
| 108 | VDD_3V3_SLP1 | `JT_VDD_3V3` | Sense | host 3.3 V rail | R34 2.2k -> U2 A2 (3.3 V side) -> FPGA LA01_N_CC |
| 109 | VDD_5V | `JT_VDD_5V` | - | host 5 V rail | not connected on FMC_MIPI (J2 pins only) |
| 110 | VDD_3V3_SLP2 | `JT_VDD_3V3` | Sense | host 3.3 V rail | R34 2.2k -> U2 A2 (3.3 V side) -> FPGA LA01_N_CC |
| 112 | 112 | `JT_1p8V_GPIO9_IN` | Out (3-state) | 1.8 V CMOS | U3 2A5 <- FPGA LA26_N (OE: LA13_P via IC7) |
| 117 | CAM_INTR | `JT_1p8V_GPIO17_IN` | Out (3-state) | 1.8 V CMOS | U3 2A6 <- FPGA LA26_P (OE: LA13_P via IC7) |
| 118 | VDD_5V | `JT_VDD_5V` | - | host 5 V rail | not connected on FMC_MIPI (J2 pins only) |
| 120 | VDD_5V | `JT_VDD_5V` | - | host 5 V rail | not connected on FMC_MIPI (J2 pins only) |

**GND pins:** 5, 6, 11, 12, 17, 18, 23, 24, 29, 30, 35, 36, 41, 42, 47, 48, 53, 54, 70, 79, 80, 99, 100, 115, 116, G1, G2, G3, G4, G5, G6, G7, G8

**Not connected on FMC_MIPI** (the bridge can leave them open): 1 (CSI0_D0+); 2 (CSI1_D0_P); 3 (CSI0_D0-); 4 (CSI1_D0_N); 7 (CSI0_CLK+); 8 (CSI1_CLK_P); 9 (CSI0_CLK-); 10 (CSI1_CLK_N); 13 (CSI0_D1+); 14 (CSI1_D1_P); 15 (CSI0_D1-); 16 (CSI1_D1_N); 37 (CSI4_D0+); 38 (CSI5_D0+); 39 (CSI4_D0-); 40 (CSI5_D0-); 43 (CSI4_CLK+); 44 (CSI5_CLK+); 45 (CSI4_CLK-); 46 (CSI5_CLK-); 49 (CSI4_D1+); 50 (CSI5_D1+); 51 (CSI4_D1-); 52 (CSI5_D1-); 55 (DVDD_CAM_LV1); 56 (DVDD_CAM_LV1); 57 (DVDD_CAM_LV2); 58 (DVDD_CAM_LV2); 59 (59); 60 (60); 61 (61); 62 (62); 63 (63); 64 (64); 65 (65); 66 (66); 67 (67); 68 (68); 69 (69); 71 (71); 72 (I2S3_CLK); 73 (73); 74 (I2S3_LRCLK); 76 (I2S3_SDIN); 78 (I2S3_SDOUT); 84 (VDD_AF); 85 (CAM_AF_PWDN); 86 (CAM_VSYNC); 88 (CAM1_MCLK); 90 (CAM1_PWDN); 92 (CAM1_RST_L); 94 (CAM2_MCLK); 96 (CAM2_PWDN); 97 (GPIO5_CAM_FLASH_EN); 98 (CAM2_RST); 103 (SNN_FLASH_MASK); 104 (104); 106 (106); 111 (IR_READY); 113 (IR_TRIGGER); 114 (114); 119 (VDD_SYS_EN)

## What this means for the bridge

### CSI-2 lanes
* Two 2-lane D-PHY ports: **port C** (Jetson CSI2: D0 19/21, D1 31/33, CLK 25/27) and **port D**
  (Jetson CSI3: D0 20/22, D1 32/34, CLK 26/28). HS comes from FPGA LVDS outputs through XAPP894-style
  resistor networks (220/47/9.1 ohm), LP comes from 1.2 V CMOS drivers (U8, SN74AVCH16T245 at 1.2 V),
  and the TS3DDR3812 switches U5/U6 select HS or LP. Lane rate in the existing firmware
  ([MIPI_CSI2_TX](https://github.com/VideoGPU/MIPI_CSI2_TX)): 800 Mb/s per lane.
* **Ports C and D share their HS/LP select lines** (`SWITCH_DATA_LANES_CSI_CD` drives SEL1 and
  `SWITCH_CLOCK_LANES_CSI_CD` drives SEL2 of both U5 and U6). The two ports therefore enter and leave HS
  mode together. Possible uses:
  1. one 2-lane port (C or D) to one host;
  2. the same 2-lane stream on C and D to two hosts at the same time;
  3. one 4-lane port: clock = C_CLK, lanes 0..3 = C_D0, C_D1, D_D0, D_D1 (D_CLK unused), provided
     the firmware drives both ports with the same timing.

  Two independent streams with different timing are not possible without reworking FMC_MIPI.
* Route each pair as 100 ohm differential with matched lengths, and keep the P/N polarity and lane
  order as they are (no swaps), so that every output works with the existing firmware.

### I2C
* Three independent 1.8 V I2C buses: `I2C_CAM` (75/77), `CAM_I2C2` (87/89), `I2C_GP0` (105/107).
  Each goes through its own TCA9406 to separate FPGA pins, so each bridge output connector can get its
  own bus (and its own emulated sensor).
* On the J2 side each TCA9406 has internal 10 kOhm pull-ups to the FMC_MIPI 1.8 V rail. When FMC_MIPI is
  unpowered the TCA9406 pins are high-impedance (Ioff <= 2 uA), so an unpowered FPGA stack does not load
  the host's bus.
* `I2C_CAM` also has an AT24MAC402 EEPROM on it (A2=1, A1=A0=0: EEPROM at **0x54**, serial/EUI at
  **0x5C**). Hosts will see these addresses. JP1 selects the EEPROM supply (FMC_MIPI 1.8 V by default,
  or the host 1.8 V from J2 pin 102).
* Host-side levels differ (Raspberry Pi: 3.3 V with 1.8 kOhm pull-ups on the Pi). The bridge needs a
  1.8 V <-> host-level translator. Use a passive pass-FET type (PCA9306, LSF0102 or discrete BSS138),
  not a second one-shot/auto-direction translator in series with the TCA9406. The pass-FET type also
  passes clock stretching.

### Control and GPIO signals
* Host -> FPGA: `CAM0_MCLK` (91), `GPIO0_CAM0_PWR` (93), `GPIO2_CAM0_RST` (95). They are A-side inputs
  of SN74AVCH16T245 U3 with VCCA = 1.8 V: VIH = 0.65 x 1.8 V = 1.17 V, and the input range is 0..3.6 V,
  so 1.8 V and 3.3 V host GPIOs can drive them directly (add a series resistor). The inputs have
  **bus-hold**; TI does not recommend pull resistors on bus-hold inputs.
* Proposed mapping for RPi-style connectors: `CAM_IO0` (power enable) -> pin 93; `CAM_IO1`
  (LED / GPIO) -> pin 95 through a 0 ohm / jumper option.
* FPGA -> host: `GPIO9` (112) and `CAM_INTR` (117) are 1.8 V push-pull outputs that the FPGA can
  tri-state (LA13_P). They need level shifting before they drive a 3.3 V host input.

### Power
* FMC_MIPI is powered from the FMC (KC705). It does **not** supply any power on J2, and it draws only
  sensing current from the host rails: 3V3 (108/110), 2V8 (81-83), 1V8 (102) and 1V2 (101) go through
  2.2 kOhm resistors to level shifters and then to the FPGA as "host rail present" flags. VDD_5V
  (109/118/120) is not connected on FMC_MIPI.
* The bridge should connect the host 3.3 V (camera connector supply pin) to J2 108/110, so that the
  firmware can keep the D-PHY outputs disabled (EN_U5/EN_U6) until the host is powered. This avoids
  back-powering an unpowered host's D-PHY receiver through its ESD diodes.
* Optional: a small 1.8 V LDO from the host 3.3 V, enabled by the host's power-enable GPIO, can drive
  J2 102 (1V8 "module powered" flag, optional EEPROM supply). This copies how a real camera module turns
  on its regulators from `CAM_IO0`.
