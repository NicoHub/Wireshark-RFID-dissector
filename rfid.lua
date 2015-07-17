--------------------------------------------------------------------
---BinDecHex Library
-------------------------
---BSD licensed
---http://www.dialectronics.com/Lua/  
--------------------------------------------------------------------

string.gfind = string.gfind or string.gmatch

-- These functions are big-endian and take up to 32 bits
---------------------------------------------------------------------------------------------Hex2Bin
local hex2bin = {
	["0"] = "0000",
	["1"] = "0001",
	["2"] = "0010",
	["3"] = "0011",
	["4"] = "0100",
	["5"] = "0101",
	["6"] = "0110",
	["7"] = "0111",
	["8"] = "1000",
	["9"] = "1001",
	["a"] = "1010",
    ["b"] = "1011",
    ["c"] = "1100",
    ["d"] = "1101",
    ["e"] = "1110",
    ["f"] = "1111"
	}

function Hex2Bin(s) --s -> hexadecimal string

	local ret = ""
	local i = 0

	for i in string.gfind(s, ".") do
		i = string.lower(i)
		ret = ret..hex2bin[i]
	end
	
	return ret
end
---------------------------------------------------------------------------------------------Bin2Hex
local bin2hex = {
	["0000"] = "0",
	["0001"] = "1",
	["0010"] = "2",
	["0011"] = "3",
	["0100"] = "4",
	["0101"] = "5",
	["0110"] = "6",
	["0111"] = "7",
	["1000"] = "8",
	["1001"] = "9",
	["1010"] = "A",
    ["1011"] = "B",
    ["1100"] = "C",
    ["1101"] = "D",
    ["1110"] = "E",
    ["1111"] = "F"
	}
	
function Bin2Hex(s) -- s -> binary string

	local l = 0
	local h = ""
	local b = ""
	local rem

	l = string.len(s)
	rem = l % 4
	l = l-1
	h = ""

	if (rem > 0) then
		s = string.rep("0", 4 - rem)..s
	end

	for i = 1, l, 4 do
		b = string.sub(s, i, i+3)
		h = h..bin2hex[b]
	end

	return h

end


-- These functions are big-endian and will extend to 32 bits
---------------------------------------------------------------------------------------------BMAnd
function BMAnd(v, m) 

	local bv = Hex2Bin(v) -- bv	-> binary string of v
	local bm = Hex2Bin(m) -- bm	-> binary string mask

	local i = 0
	local s = "" -- s -> hex string as masked

	while (string.len(bv) < 32) do
		bv = "0000"..bv
	end

	while (string.len(bm) < 32) do
		bm = "0000"..bm
	end

	for i = 1, 32 do
		cv = string.sub(bv, i, i)
		cm = string.sub(bm, i, i)
		if cv == cm then
			if cv == "1" then
				s = s.."1"
			else
				s = s.."0"
			end
		else
			s = s.."0"
		end
	end

	return Bin2Hex(s)

end

---------------------------------------------------------------------------------------------BMXOr
function BMXOr(v, m) -- v -> hex string to be masked; m -> hex string mask

local bv = Hex2Bin(v) -- bv	-> binary string of v
local bm = Hex2Bin(m) -- bm	-> binary string mask

local i = 0
local s = "" -- s -> hex string as masked

	while (string.len(bv) < 32) do
		bv = "0000"..bv
	end

	while (string.len(bm) < 32) do
		bm = "0000"..bm
	end

	for i = 1, 32 do
		cv = string.sub(bv, i, i)
		cm = string.sub(bm, i, i)
		if cv == "1" then
			if cm == "0" then
				s = s.."1"
			else
				s = s.."0"
			end
		elseif cm == "1" then
			if cv == "0" then
				s = s.."1"
			else
				s = s.."0"
			end
		else
			-- cv and cm == "0"
			s = s.."0"
		end
	end

	return Bin2Hex(s)

end

---------------------------------------------------------------------------------------------BMNot
function BMNot(v, m) -- v -> hex string to be masked; m -> hex string mask

local bv = Hex2Bin(v) -- bv	-> binary string of v
local bm = Hex2Bin(m) -- bm	-> binary string mask

local i = 0
local s = "" -- s	-> hex string as masked

	while (string.len(bv) < 32) do
		bv = "0000"..bv
	end

	while (string.len(bm) < 32) do
		bm = "0000"..bm
	end

	for i = 1, 32 do
		cv = string.sub(bv, i, i)
		cm = string.sub(bm, i, i)
		if cm == "1" then
			if cv == "1" then
				-- turn off
				s = s.."0"
			else
				-- turn on
				s = s.."1"
			end
		else
			-- leave untouched
			s = s..cv

		end
	end

	return Bin2Hex(s)

end

-- these functions shift right and left, adding zeros to lost or gained bits
-- returned values are 32 bits long
---------------------------------------------------------------------------------------------BShRight
function BShRight(v, nb) -- v -> hexstring value to be shifted; nb -> number of bits to shift to the right

local s = Hex2Bin(v) -- s -> binary string of v

	while (string.len(s) < 32) do
		s = "0000"..s
	end

	s = string.sub(s, 1, 32 - nb)

	while (string.len(s) < 32) do
		s = "0"..s
	end

	return Bin2Hex(s)

end

---------------------------------------------------------------------------------------------BShLeft
function BShLeft(v, nb) -- v -> hexstring value to be shifted; nb -> number of bits to shift to the right

local s = Hex2Bin(v) -- s -> binary string of v

	while (string.len(s) < 32) do
		s = "0000"..s
	end

	s = string.sub(s, nb + 1, 32)

	while (string.len(s) < 32) do
		s = s.."0"
	end

	return Bin2Hex(s)

end


--------------------------------------------------------------------
---CRC-A&B calculation
-------------------------

--------------------------------------------------------------------

local First
local Second
local CRCType
local CRC_A = 1
local CRC_B = 2

function UpdateCrc(chBlock, wCrc)

	chBlock = BMXOr(chBlock, (BMAnd(wCrc, "FF")))
	chBlock = BMXOr(chBlock, (BMAnd((BShLeft(chBlock, 4)), "FF")))
	
	wCrc = BMXOr(BMXOr(BMXOr(BShRight(wCrc, 8), BShLeft(chBlock, 8)), BShLeft(chBlock, 3)), BShRight(chBlock, 4))

	return wCrc
end

function ComputeCrc(CRCType, Length)
	local wCrc
	local i = 1
	
	if CRCType == CRC_A then
		wCrc = "6363"
	elseif CRCType == CRC_B then
		wCrc = "FFFF"
	end
	
	repeat
		chBlock = BuffCRC[i]
		wCrc = UpdateCrc(chBlock, wCrc)
		i = i + 1
		Length = Length -1
	until Length == 0
	
	if CRCType == CRC_B then
		wCrc = BMNot(wCrc, "FFFF")
	end
	
	First = BMAnd(wCrc, "FF")
	Second = BMAnd((BShRight(wCrc , 8)), "FF")
end



--------------------------------------------------------------------
---Dissector
-------------------------
---Doc used: fcd-14443-3; wg8n1496_17n3613_Ballot_FCD14443-3
--------------------------------------------------------------------

--Declare our protocol
protoRFID = Proto("14443-A","RFID") --"14443-A": name use on the code; "RFID": name display on wireshark in brackets next to the payload

-- Simple field displayed in hex format
local f_header = ProtoField.string("rfid.header", "Header")
local f_data = ProtoField.string("rfid.data", "Data")  -- perhaps change for ProtoField.Byte

-- register each field
protoRFID.fields = 
  {
    f_header,
	f_data
  }
	
-- create a function to dissect it
function protoRFID.dissector (tvb,pinfo,tree)
  --pinfo.cols.protocol ="RFID"  --create a column with protocol as title and RFID as contents
  pinfo.cols.protocol = protoRFID.name	--proto name is that in first in Proto and in DLT_USER. Uppercase is not possible on the Wireshark display next to the payload
  
--********** tree **********--
	local subtree_packet = tree:add(protoRFID, tvb(),"ISO 14443-A")
	
	
--********** header **********--
	local subtree_header = subtree_packet:add(f_header, tvb(0,1), "")
	
	local header_len = 0 
	local data_start = 0
	local command
	local direction_symbol = ""
	
--********** header **********--
	--power
	local power = tvb(header_len,1):int() 
	

	if (power >= 64) and (power < 80) then --40
		command = string.format("  external signal strength %d/7 (105<->145 mVpp)",tvb(header_len,2):bitfield(1, 3))
		
	elseif (power >= 80) and (power < 96) then --50
		command = string.format("  external signal strength %d/7 (150<->205 mVpp)",tvb(header_len,2):bitfield(1, 3))
		
	elseif (power >= 96) and (power < 112) then --60
		command = string.format("  external signal strength %d/7 (210<->287 mVpp)",tvb(header_len,2):bitfield(1, 3))
		
	elseif (power >= 112) and (power <= 127) then --70
		command = string.format("  external signal strength %d/7 (295<->+325 mVpp)",tvb(header_len,2):bitfield(1, 3))
	else 
		command = "  signal reception error"
	end
	
	subtree_header:add(tvb(header_len,1), "RSSI level: "..string.format("(0x%x)", power)..command) --leave tvb at the beginning for wireshark get its bearings 
	header_len = header_len +1
	
	--protocol
	local protocol = tvb(header_len,1):uint()
	
	if protocol == 0xb0 then 
		command = "A PCD (Proximity Coupling Device, Type A):"
		subtree_header:add(tvb(header_len,1), command..string.format(" (0x%x)", protocol))
		set_color_filter_slot(5, "frame[1:1] == b1")
		direction_symbol = ">>"
		pinfo.cols.src:set("Reader")
		
	elseif protocol == 0xb1 then	--TAG
		command = "A PICC (Proximity Inductive Coupling Card, Type A):"	
		subtree_header:add(tvb(header_len,1), command..string.format(" (0x%x)", protocol))
		direction_symbol = "<<"
		pinfo.cols.src:set("Tag")
		
	elseif protocol == 0xb2 then
		command = "Unknown:"	
		subtree_header:add(tvb(header_len,1), command..string.format(" (0x%x)", protocol))
		set_color_filter_slot(1, "frame[1:1] == b2")
		direction_symbol = "  "
		pinfo.cols.src:set("Unknown")
	end
	
	header_len = header_len +1

	--speed 14443-A
	local speed = tvb(header_len,1):uint()
	
	if speed == 0xc0 then
		command = "Speed: 106 Kbit/s"
		subtree_header:add(tvb(header_len,1), command)
	
	elseif speed == 0xc1 then
		command = "Speed: 212 Kbit/s"
		subtree_header:add(tvb(header_len,1), command)
	
	elseif speed == 0xc2 then
		command = "Speed: 424 Kbit/s"
		subtree_header:add(tvb(header_len,1), command)
	
	--[[848 not supported]]--
	
	end
	
	header_len = header_len +1
	
	--timestamp
	local timestamp = tvb(header_len,4):uint()
	
	local time_end = timestamp/168000000 --168 MHz HydraBus frequency
	
	command = "Absolute timestamp (commande/response end): "
	subtree_header:add(tvb(header_len,4),command..string.format(" %.9fs",time_end))
 
	header_len = header_len +4
	
	--odd parity bit
	local parity_bit = tvb(header_len,1):uint()
	
	if parity_bit == 0xd0 then
		command = "Odd parity bit OFF"
		subtree_header:add(tvb(header_len,1), command..string.format(" (0x%x)",parity_bit))
	
	elseif parity_bit == 0xd1 then
		command = "Odd parity bit ON"
		subtree_header:add(tvb(header_len,1), command..string.format(" (0x%x)",parity_bit))
	end
	
	header_len = header_len +1
	
	
--********** data **********--
	data_start = header_len 
	data_len = tvb:len() - data_start
	data_end = data_start + data_len
	
	local data = tvb(data_start, data_len)

	local subtree_data = subtree_packet:add(f_data, data, "")
	
	--Check short frame
	if (#Hex2Bin(tostring(data)) == 8 and data:bitfield(0, 1) == 0)  then
		short_frame = "  		(short frame)"
	else short_frame = "      		          "
	end
	
	--Check CRC
	function CheckCRC (BuffCRC)
		
			ComputeCrc(CRC_A, data_len-2)
			local s1 = string.sub(First, 7, 8)
			local s2 = string.sub(Second, 7, 8)
			local command
			
			if (string.lower(s1) == tostring(tvb(data_end-2, 1)) and (string.lower(s2) == tostring(tvb(data_end-1, 1)))) then
				command = "   [CRC verified and OK!]"
			else
				command = "   [CRC verified but NOK! The calculated CRC is: "..s1..s2.."]"
			end
		return command
	end
	
		
	--ATQA handled values 0004;0002;0008;0044;0042;0344;0304;0048	OK
	if ((tostring(tvb(data_start, data_len)) == "0400") or (tostring(tvb(data_start, data_len)) == "0200") or (tostring(tvb(data_start, data_len)) == "0800")or (tostring(tvb(data_start, data_len)) == "0403")) 
		and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len), "ATQA (Answer To reQuest, Type A): "..string.format("(")..(tvb(data_start+1, 1))..(tvb(data_start, 1))..string.format(")"))
		subtree_data:add("Tag 4 bytes UID")
		UID_size = 4
	
	elseif ((tostring(tvb(data_start, data_len)) == "4400") or (tostring(tvb(data_start, data_len)) == "4200") or (tostring(tvb(data_start, data_len)) == "4403") or (tostring(tvb(data_start, data_len)) == "4800")) --or (tostring(tvb(data_start, data_len)) == "0403")
		
		and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len), "ATQA (Answer To reQuest, Type A): "..string.format("(")..(tvb(data_start+1, 1))..(tvb(data_start, 1))..string.format(")"))
		subtree_data:add("7 bytes UID tag")
		UID_size = 7
	end

	--Cascade Level 1/2/3	OK
	if (tostring(tvb(data_start, 1))) == "93" and (protocol == 0xb0) then
		subtree_data:add("SELECT command, Type A")
		subtree_data:add(tvb(data_start, 1), "  Cascade Level 1, Type A: "..string.format("(%d)", tostring(tvb(data_start, 1))))
		subtree_data:add("Number of Valid Bits, Type A")
		subtree_data:add(tvb(data_start+1, 1), "  Byte count: "..string.format("(%d)",data:bitfield(8, 4)).."  Bit count: "..string.format("(%s)",data:bitfield(12, 4)))
		
		if (tostring(tvb(data_start+1, 1))) == "70" then 
		
			if (UID_size == 4) then
				if (tostring(tvb(data_start+2, 1)) == "80") then
					command = ("     [Could be a random UID]")
				else command = ("")
				end
			subtree_data:add(tvb(data_start+2, UID_size),"Tag UID: "..string.format("(%s)", tostring(tvb(data_start+2, UID_size)))..command)
			subtree_data:add(tvb(data_start+6, 1),"BCC (Block Check Character (UID CLn check byte), Type A): "..string.format("(%s)", tostring(tvb(data_start+6, 1))))
			
			elseif (UID_size == 7) then
				if (tostring(tvb(data_start+2, 1)) == "80") then
					command = ("     [Could be a random UID]")
				else command = ("")
				end
				subtree_data:add(tvb(data_start+2, 1),"CT (Cascade Tag, Type A): "..string.format("(%s)", tostring((tvb(data_start+2, 1)))))
				subtree_data:add(tvb(data_start+3, 3),"The first 3 bytes of the tag UID "..string.format("(%s)", tostring(tvb(data_start+3, 3))))		
				subtree_data:add(tvb(data_start+6, 1),"BCC (Block Check Character (UID CLn check byte), Type A): "..string.format("(%s)", tostring(tvb(data_start+6, 1))))
			end
			
			BuffCRC = {tostring(tvb(data_start, 1)), tostring(tvb(data_start+1, 1)), tostring(tvb(data_start+2, 1)), tostring(tvb(data_start+3, 1)), tostring(tvb(data_start+4, 1)), tostring(tvb(data_start+5, 1)), tostring(tvb(data_start+6, 1))}
			subtree_data:add(tvb(data_end -2, 2), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_end -2, 2))), CheckCRC (BuffCRC))
		end
		
	elseif (tostring(tvb(data_start, 1))) == "95" and (protocol == 0xb0) then
		subtree_data:add("SELECT command, Type A")
		subtree_data:add(tvb(data_start, 1), "  Cascade Level 2, Type A: "..string.format("(%d)", tostring(tvb(data_start, 1))))
		subtree_data:add("Number of Valid Bits, Type A")
		subtree_data:add(tvb(data_start+1, 1), "  Byte count: "..string.format("(%d)",data:bitfield(8, 4)).."  Bit count: "..string.format("(%d)",data:bitfield(12, 4)))
		subtree_data:add("(7 or 10 bytes UID tag)")
		
		if (tostring(tvb(data_start+1, 1))) == "70" then 
		
			if (UID_size == 7) then
				subtree_data:add(tvb(data_start+2, 4),"The last 4 bytes of the tag UID "..string.format("(%s)",tostring(tvb(data_start+6, 1))))
			end
		
			BuffCRC = {tostring(tvb(data_start, 1)), tostring(tvb(data_start+1, 1)), tostring(tvb(data_start+2, 1)), tostring(tvb(data_start+3, 1)), tostring(tvb(data_start+4, 1)), tostring(tvb(data_start+5, 1))}
			subtree_data:add(tvb(data_end -2, 2), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_end -2, 2))), CheckCRC (BuffCRC))
		end
		
	elseif (tostring(tvb(data_start, 1))) == "97" and (protocol == 0xb0) then
		subtree_data:add("SELECT command, Type A")
		subtree_data:add(tvb(data_start, 1), "  Cascade Level 3, Type A: "..string.format("(%d)", tostring(tvb(data_start, 1))))
		subtree_data:add("Number of Valid Bits, Type A")
		subtree_data:add(tvb(data_start+1, 1), "  Byte count: "..string.format("(%d)",data:bitfield(8, 4)).."  Bit count: "..string.format("(%d)",data:bitfield(12, 4)))
		subtree_data:add("(10 bytes UID tag)")
		
		if (tostring(tvb(data_start+1, 1))) == "70" then 
			BuffCRC = {tostring(tvb(data_start, 1)), tostring(tvb(data_start+1, 1)), tostring(tvb(data_start+2, 1)), tostring(tvb(data_start+3, 1)), tostring(tvb(data_start+4, 1))}
			subtree_data:add(tvb(data_end -2, 2), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_end -2, 2))), CheckCRC (BuffCRC))
		end
	end

	--REQA/WUPA		OK
	if tostring(tvb(data_start, data_len)) == "26" and (protocol == 0xb0) then
		subtree_data:add(data, "REQA (REQuest command, Type A): "..string.format("(%d)",tostring(data)))
		set_color_filter_slot(4, "frame[8:1] == 26") --the colour coefficient must be lower than previous coefficients, to be display
	elseif	tostring(tvb(data_start, data_len)) == "52" and (protocol == 0xb0) then
		subtree_data:add(data, "WUPA (Wake-UP command, Type A): "..string.format("(%d)",tostring(data)))
		set_color_filter_slot(4, "frame[8:1] == 52")
	end
	
	--HALT		OK
	if tostring(tvb(data_start, data_len-2)) == "5000" and (protocol == 0xb0) then 
		subtree_data:add(tvb(data_start, 2), "HLTA (HaLT command, Type A): "..string.format("(%s)", tostring(tvb(data_start, 2))))
		
		BuffCRC = {tostring(tvb(data_start, 1)), tostring(tvb(data_start+1, 1))}
		subtree_data:add(tvb(data_start+2,2), "CRC_A (Cyclic Redundancy Check error detection code, Type A): ", string.format("(%s)", tostring(tvb(data_start+2,2))), CheckCRC (BuffCRC))		
	end
	
	--SAK CL1 handled values 04;24		OK
	if tostring(tvb(data_start, data_len-2)) == "04" and (protocol == 0xb0) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, -2))))
		subtree_data:add("MIFARE Cascade Level 1")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
		
	elseif tostring(tvb(data_start, data_len-2)) == "24" and (protocol == 0xb0) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, -2))))
		subtree_data:add("MIFARE DESFire or DESFire EV1 Cascade Level 1")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
	end

	--SAK CL2 handled values 09;08;18;10;11;20  --a modifier voir ce que je peux trouver de fixe dans la norme ISO
	if tostring(tvb(data_start, data_len-2)) == "09" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Mini single/double (0.3K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
	elseif tostring(tvb(data_start, data_len-2)) == "08" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Classic single/double (1K) or MIFARE Plus single/double (2K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
	elseif tostring(tvb(data_start, data_len-2)) == "18" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Classic single/double (4K) or MIFARE Plus single/double (4K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
	elseif tostring(tvb(data_start, data_len-2)) == "10" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Plus single/double (2K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
	elseif tostring(tvb(data_start, data_len-2)) == "11" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Plus single/double (4K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
		
	elseif tostring(tvb(data_start, data_len-2)) == "20" and (protocol == 0xb1) then
		subtree_data:add(tvb(data_start, data_len-2), "SAK (Select AcKnowledge, Type A): "..string.format("(%s)", tostring(tvb(data_start, data_len-2))))
		subtree_data:add("MIFARE Plus single/double (2K/4K) or Mifare DESFire double (4K) or Mifare DESFire EV1 simple (2K/4K/8K)")
		BuffCRC = {tostring(tvb(data_start, 1))}
		subtree_data:add(tvb(data_start+1, data_len-1), "CRC_A (Cyclic Redundancy Check error detection code, Type A): "..string.format("(%s)", tostring(tvb(data_start+1, data_len-1))), CheckCRC (BuffCRC))
	end	

	
--info column

-- = pinfo.abs_ts, select(2,math.modf(pinfo.abs_ts)) * 10^9  --absolute time in epoch time
--pinfo.cols.protocol:set(pinfo.delta_ts) --delta time display

time_start = pinfo.abs_ts - 1432159200
delta = time_end - time_start
pinfo.cols.info:set(protoRFID.name.."   "..direction_symbol..string.format("   %.9f(s)",delta).."    Data: "..data..short_frame)--string.format("   %.9f(s)",time_end)..





--ISO 7816
	if tostring(tvb(data_start, data_len)) == "e0803173" and (protocol == 0xb0) then
	subtree_data:add("RATS (Request for Answer To Select)")
	end
	
	if tostring(tvb(data_start, data_len)) == "d0110052a6" and (protocol == 0xb0) then
	subtree_data:add("PPS req.")
	end
	
	if tostring(tvb(data_start, data_len)) == "d07387" and (protocol == 0xb1) then
	subtree_data:add("PPS resp.")
	end
	
end
	

