#### IP CORE ORX_SWITCH_CONTROLLER
###### Version 2.0

---
Contents
---
[1. Author](#part4)

[2. Description](#part1)

[3. Tools and language](#part2)

[5. Initial Setup](#part5)

**1. Author<a id="part4"></a>**
  * [Trung C. Nguyen](mailto:nguyencanhtrung@me.com "Send an email to Trung")
  

**2. Description<a id="part1"></a>**
   
   **_IP CORE_** is used to control ORX switching of transceiver ADRV9009.
- Input: command from Digital Pre-Distortion IP core, it is the index of antenna which DPD need to acquire data from.
- Output: command to transceiver IC to order its stream processor to switch its internal data-path to required antenna.

  
**3. Tools and language<a id="part2"></a>**
   - Development board: ZCU102
   - Platform: Linux OS
   - Synthesize tool: Xilinx Vivado 2017.2
   - Simulation tool: ISIM
   - Language: VHDL
 
---
Initial Setup Tutorial<a id="part5"></a>
---
**Setup git**

1. Download and install git for linux/windows
2. Open terminal or git bash
3. Set your name $git config --global user.name "<name>"
4. Set your mail address $git conifg --global user.email email@xx.com

**Get the current version**

1. Open terminal or git bash
2. Go to a location of your choice
3. Clone repository $git clone https://github.com/nguyencanhtrung/orx_switching_controller.git

