ModelSim Altera Edition README.TXT 

Although we have made every effort to ensure that this version 
functions correctly, there may be problems that we have not  
encountered. If you have a question or problem that is not 
answered by the information provided in this readme file, please 
contact Altera Technical Support. 

mySupport: www.altera.com/mysupport
Technical Support Hotline:  (800) 800-EPLD or (408) 544-8767
Fax:  (408) 544-6401 

For additional help, you can search the Solutions in Altera's 
Find Answers located on the Support Center page at the 
following URL: www.altera.com.
 
ModelSim Altera Edition version 6.5b
 
This readme.txt file for the ModelSim(tm) Altera Edition software 
includes information that was not incorporated in the printed 
documentation or online help. 
This file contains the following sections:

* Quartus II Version Compatibility 
* VHDL 87/93 Compatibility
* Installation & Licensing 
* Potential Problems & Recommendations 


Quartus II Version Compatibility
================================

It is critical that the compiled libraries provided in the 
<modelsim install path>/altera directory be compatible with 
version of Quartus II that is used to create the simulation 
netlist. To ensure that you have the right version of libraries 
installed, you can use either of the following methods:

1.  Check the <modelsim install path>/altera/version.txt file
2.  Perform the following steps:

        cd <modelsim install path>/altera
        <modelsim install path>/win32aloem/vdir -l -lib <library name> 
        where <library name> = stratixii, cycloneii,..etc.
        Check for Quartus II version in 'Library Version' tags

VHDL87/93/2002 Compatibility
============================
The default VHDL support in ModelSim-Altera 6.5b is VHDL-2002. 
Compiling with the -93 option disables the support for VHDL-1987 
and VHDL-2002. Compiling with the -87 option disables the support 
for VHDL-1993 and VHDL-2002.

VHDL-1993 precompiled libraries are mapped by default in the 
ModelSim Altera Edition software.

For VHDL designs, to map to the VHDL-1987 precompiled libraries for 
simulating HDL designs with megafunctions, use the following models:

  vmap lpm <ModelSim-Altera install directory>/altera/vhdl/220model_87
  vmap 220model  <ModelSim-Altera install directory>/altera/vhdl/220model_87
  vmap altera_mf <ModelSim-Altera install directory>/altera/vhdl/altera_mf_87



System Requirements
===================

For details on tool system requirements, refer to the following page
on the Altera web site:
http://www.altera.com/support/software/os_support/oss-index.html

Installation & Licensing
========================
 
Be sure to read all information on installation and licensing 
requirements in this file before you install the 
ModelSim Altera Edition software.

Installing ModelSim-Altera edition on a windows-based computer
==============================================================

1.  Change directory to the <dvdrom_drive>/modelsim_ae/ 
    directory
2.  Run modelsim_ae_windows.exe

	If you are using a software guard-based license, you 
	must select "yes" when asked to install the Sentinel Drivers 
	during the installation process. You must reboot your 
	computer after installation completes for the Sentinel 
	driver to be recognized.


Installing ModelSim-Altera edition on Linux workstations
====================================================================

1.  Change directory to the <dvdrom_drive>/modelsim_ae/
    directory.
2.  Type 'install' and follow the instructions on screen.


Licensing your Model Technology ModelSim-Altera software
========================================================

1. Visit the Licensing page of the Altera web site at www.altera.com
   to request a license file to enable your Model Technology 
   ModelSim-Altera software.

2. The ModelSim-Altera software supports licenses using the Mentor 
   Graphics license daemon 'mgcld'.

   The mgcld daemon can be found in the ModelSim-Altera installation
   at the following location 
   PC       -  <installation directory>\win32aloem\ 
   Solaris  - <installation directory>/sunos5aloem/
   Linux    - <installation directory>/linuxaloem/

3. For more information on setting up an Altera License, refer to 
   Application Note 340, Understanding Altera Software Licensing, 
   available in the Literature section of the Altera web site 
   (www.altera.com). 

4. Before running the ModelSim-Altera software, set your 
   LM_LICENSE_FILE environment variable to the location and filename 
   of the license file for ModelSim-Altera.  For example, the 
   LM_LICENSE_FILE environment variable should be set to the location 
   and filename of your license file (c:\licenses\eda\license.dat) or 
   with the port@host notation (1900@set).

   * On Windows XP: From the Start menu, select Control Panel.  
    If needed, click the Switch to Classic View link.  
    Choose the System icon and select the Advanced tab.  
    Click the Environment Variables button. 

   * On Windows 2000: From the Start menu, select Settings -> 
    Control Panel.Choose the System icon and select the 
    Advanced tab. Click the Environment Variables button. 


Potential Problems & Recommendations 
====================================

1. The "Locate to Quartus" feature in the Quartus II NativeLink 
   integration with ModelSim-Altera is not supported on the OEM 
   version of ModelSim-Altera. A full version of Modelsim is 
   required if you want to be able to locate signals back to 
   the Quartus II software from the Modelsim waveform window.

2. The installation contains both VHDL-1987 and VHDL-1993 pre-compiled 
   libraries for LPMs (220model), and megafunctions 
   (altera_mf). The default mapping present in the modelsim.ini 
   file of the installation is for VHDL93 libraries. If you 
   want to simulate your design using VHDL87 libraries, then 
   you must explicitly change the mapping:

   vmap lpm $(MODEL_TECH)/../altera/vhdl/220model_87
   vmap altera_mf $(MODEL_TECH)/../altera/vhdl/altera_mf_87

3. You may get the following errors when loading projects created
   using previous versions of ModelSim-Altera in ModelSim-Altera 6.5b 

# ** Error: (vsim-3193) Load of "<modelsim-altera_install_dir>\win32aloem/../win32aloem/convert_hex2ver.dll" failed: File not found.

# ** Error: (vsim-PLI-3002) Failed to load PLI object file "<modelsim-altera_install_dir>\win32aloem/../win32aloem/convert_hex2ver.dll".

  You should remove the modelsim.ini located in your design directory
  to resolve this issue. Alternately, you can edit the file modelsim.ini
  and remove the line

Veriuser = $MODEL_TECH/../win32aloem/convert_hex2ver.dll

4. ModelSim-Altera 6.5b is not supported for Windows XP 64-bit.
