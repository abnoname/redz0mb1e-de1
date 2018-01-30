------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  kleinkram/sevenseg.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-03-03
-- Lizenz     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- 4bit to seven segment display
-- display on a single 7seg
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity sevenseg is
  port(
    cntr : in  std_logic_vector(3 downto 0);
    dig  : out std_logic_vector(0 to 6));
end entity;

architecture behave of sevenseg is
  begin
  --         gfedcba
  dig <=    "1000000" when cntr = "0000" else
            "1111001" when cntr = "0001" else
            "0100100" when cntr = "0010" else
            "0110000" when cntr = "0011" else
            "0011001" when cntr = "0100" else
            "0010010" when cntr = "0101" else
            "0000010" when cntr = "0110" else
            "1111000" when cntr = "0111" else
            "0000000" when cntr = "1000" else
            "0010000" when cntr = "1001" else
            "0001000" when cntr = "1010" else  --A
            "0000011" when cntr = "1011" else  --b
            "0100111" when cntr = "1100" else  --c
            "0100001" when cntr = "1101" else  --d
            "0000110" when cntr = "1110" else  --E
            "0001110" when cntr = "1111" else  --F
            "0110110";
end architecture behave;
