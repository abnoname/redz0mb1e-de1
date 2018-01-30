------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  bm204_empty_pkg.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-03-04
-- Licence     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html) 
------------------------------------------------------------------------------
-- Description: 
-- rom image
-- Z1013 EPROM-image U2632  Empty
-- Faked Firmware, only JUMP to start of firmware, the rest is NOP
-- firmware images (called monitor here) can be found at:
--
--http://hc-ddr.hucki.net/wiki/doku.php/z1013:software:monitor
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package bm204_empty_pkg is
  constant C_ADDRLINE_HIGH : integer := 10;
  subtype  T_INDEX is integer range 0 to 2**(C_ADDRLINE_HIGH + 1) - 1;
  signal   addr_integer    : T_INDEX;

  subtype T_WORD is integer range 255 downto 0;
  type    T_Mem is array (T_INDEX'low to T_INDEX'high) of T_WORD;

  constant C_MEM_ARRAY_INIT : T_Mem := (16#C3#, 16#00#, 16#F0#, others => 0);  

end package bm204_empty_pkg;
