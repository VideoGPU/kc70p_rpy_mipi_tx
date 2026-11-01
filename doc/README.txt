Documentation
=============

Project documents
-----------------

  Document: fmc_mipi_interface.txt
  Content: FMC_MIPI J2 (Samtec QTH-060, Jetson TX2 camera pinout): pin map from the
    netlist, signal levels, power, consequences for the bridge
  --------------------------------------------------------------------
  Document: target_boards.txt
  Content: Camera connectors of the three targets: Raspberry Pi 3 B+, Astra Machina
    SL2610, Coralboard SL
  --------------------------------------------------------------------
  Document: board_compatibility.txt
  Content: Other popular boards: connector requirements, mechanical and out-of-the-box
    electrical interchangeability

Third-party reference documents
-------------------------------

fetch_docs.sh downloads every entry of sources.txt into
vendor/<sub-directory>/. The files are git-ignored. vendor.sha256 <vendor.sha256>
records the checksums of the last download.

  Sub-directory: raspberry_pi/
  What is in it: Pi 3B+ schematics, mechanical drawing (PDF + DXF), product brief, power
    supply; official 15/22-pin CSI pinout and CSI-2 usage text; camera cable drawings;
    HQ camera schematics; Pi 4, Zero 2 W, Pi 5, CM4 IO (+ KiCad), CM5 IO references
  Used for: Target #1, RPi-compatible connectors, cable types
  --------------------------------------------------------------------
  Sub-directory: synaptics_sl2610/
  What is in it: SL2610 datasheet and product brief; Machina SL2600 dev-kit brief, user
    guide, I/O-board and core-module schematics; CSI camera, TWSI (I2C) and GPIO app
    notes; SDK hardware and ISP sensor guides
  Used for: Target #2 (J206), SL2610 CSI-2 RX limits
  --------------------------------------------------------------------
  Sub-directory: coralboard/
  What is in it: Google Coral product brief; Grinn OV5647 device-tree overlay
  Used for: Target #3
  --------------------------------------------------------------------
  Sub-directory: connectors/
  What is in it: Samtec QSH/QTH product spec, QSH/QTH drawings, QSH footprint
  Used for: Bridge connector mating FMC_MIPI J2
  --------------------------------------------------------------------
  Sub-directory: fpga_amd/
  What is in it: XAPP894 (D-PHY with resistor networks), UG810 (KC705)
  Used for: FPGA-side D-PHY and FMC details
  --------------------------------------------------------------------
  Sub-directory: fmc_mipi_parts/
  What is in it: TCA9406, SN74AVCH16T245, TS3DDR3812, AT24MAC402
  Used for: Electrical behaviour of the FMC_MIPI side of J2
  --------------------------------------------------------------------
  Sub-directory: bridge_parts/
  What is in it: PCA9306, LSF0102
  Used for: Candidate I2C/GPIO translators for the bridge
  --------------------------------------------------------------------
  Sub-directory: other_boards/
  What is in it: Coral Dev Board schematic and datasheet page; NVIDIA Orin Nano hardware
    layout; Jetson Nano 2GB user guide
  Used for: Evidence for board_compatibility.txt

Documents that must be fetched by hand
--------------------------------------

  Document: NVIDIA Jetson TX1/TX2 Developer Kit Carrier Board Specification (camera
    connector)
  Link:
    https://developer.nvidia.com/embedded/dlc/jetson-tx1-tx2-developer-kit-carrier-board-spec
  Why not scripted: NVIDIA developer login
  --------------------------------------------------------------------
  Document: NVIDIA Jetson Orin Nano Developer Kit Carrier Board Specification
    (SP-11324-001, camera pin levels)
  Link: https://developer.nvidia.com/embedded/downloads
  Why not scripted: NVIDIA developer login
  --------------------------------------------------------------------
  Document: NXP i.MX 8M Plus / i.MX 93 EVK schematics (camera connectors)
  Link: https://www.nxp.com/
  Why not scripted: NXP account login
  --------------------------------------------------------------------
  Document: Amphenol SFW15R-2STE1LF (RPi 15-pin 1.0 mm) drawing
  Link: https://www.amphenol-cs.com/product/sfw15r2ste1lf.html
  Why not scripted: site blocks scripts
  --------------------------------------------------------------------
  Document: Amphenol F32Q-1A7H1-11022 (RPi 22-pin 0.5 mm) drawing
  Link: https://www.amphenol-cs.com/product/f32q1a7h111022.html
  Why not scripted: site blocks scripts
  --------------------------------------------------------------------
  Document: Molex 505110-2296 (probable Machina J206 part)
  Link: https://www.molex.com/en-us/products/part-detail/5051102296
  Why not scripted: site not reachable from scripts; part number not confirmed
  --------------------------------------------------------------------
  Document: Coralboard SL schematics / camera connector pinout
  Link: Synaptics support portal:
    https://synacsm.atlassian.net/servicedesk/customer/portal/2987
  Why not scripted: not published
  --------------------------------------------------------------------
  Document: Coralboard kit photos (CSI connector and flex cable)
  Link: https://developers.google.com/coral/products/SL2610-get-started
  Why not scripted: check by eye; could not be analysed in this session
  --------------------------------------------------------------------
  Document: Coralboard SDK
  Link: https://www.synaptics.com/coralboard-sdk-download
  Why not scripted: "coming soon" page
  --------------------------------------------------------------------
  Document: Astra SDK offline documentation zip
  Link: https://synaptics-astra.github.io/doc/v/latest/documentation.zip
  Why not scripted: linked from the docs site but returns 404; use the online docs
  --------------------------------------------------------------------
  Document: Samtec high-speed board-to-board design guide (19 MB, optional)
  Link: https://suddendocs.samtec.com/literature/samtec-high-speed-b2b-design-guide.pdf
  Why not scripted: large, optional
  --------------------------------------------------------------------
  Document: MIPI CSI-2 and D-PHY specifications
  Link: https://www.mipi.org/specifications
  Why not scripted: MIPI Alliance members only
  --------------------------------------------------------------------
  Document: ANSI/VITA 57.1 FMC standard
  Link: https://www.vita.com/
  Why not scripted: paid standard
