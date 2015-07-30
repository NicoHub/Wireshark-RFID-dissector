# Wireshark-RFID-dissector

This Wireshark dissector is made to parse the HydraNFC sniffing tool output. See the original project:  [HydraNFC HydraBus]( https://github.com/bvernoux/hydranfc.).

To support this dissector, a .pcap file format output has been added to the hydrabus fw besides the .txt output.  
Note that at this moment it's not yet available in the main trunk of hydraBus but on a specific branch available at: https://github.com/NicoHub/hydrafw/tree/pcap-output

The .pcap file enable to: 
* display information more clearly than the simple .txt;
* decode and analyze data having been sniffed in raw format;
* check some data, as the CRC, to be sure sniffed data have been well recorded without error;


##Installation
Wireshark has an embedded Lua interpreter since version  0.99.4. In some older versions Lua was available as a plugin. To see if your version of Wireshark supports Lua, go to:
* __help__ menu
* __About Wireshark__ 
* __Wireshark__ tab
* look for Lua in the "Compiled with" paragraph. 
 
####How to add this plugin on Wireshark:

#####Method 1: add the Lua file on the global or personal Wireshark plugins directory.
 These folders are listed in Wireshark:
  * __help__ menu
  * __About Wireshark__  
  * __Folders__ tab

Then, the dissector file should appear on the plugins list: 
* __help__ menu
* __About Wireshark__ 
* __Plugins__ tab

#####Method 2:  add the Lua file to any folder
Edit the file __Wireshark\init.lua__ 
*  Verify this line:  
	`disable_lua = false`
*  And add this line at the end of the file (`DATA_DIR` is the dir where the dissector actually is):
	`dofile(DATA_DIR.."rfid.lua")`


#####Method 3:  loading the dissector directly from the command line
Use the argument `-X lua_script:rfid.lua`  
Example: `wireshark -r rfid_capture.pcap -X lua_script:fileshark_pcap.lua`

####How to configure wireshark to take it into account:
To let Wireshark know 14443-A as new dissector,  you have to follow these steps:

1.  click on __Edit__
2.  click on __Preferences__
3.  choose __Protocols__ on the tree on the left
4.  choose the __DTL_USER__ protocol
5.  click on __Edit...__
6.  click on __New__ and configure it as follow:

![User DLTs Table](https://cloud.githubusercontent.com/assets/12861508/8907707/0eb0e11c-3478-11e5-9859-3a51fc630441.PNG)
