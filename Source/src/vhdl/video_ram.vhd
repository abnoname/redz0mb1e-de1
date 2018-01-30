------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  video_ram.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-03-16
-- Licence    : GNU General Public License (http://www.gnu.de/documents/gpl.de.html) 
------------------------------------------------------------------------------
-- Description: 
-- Video subsysten
-- Video ram, character,rom, display output
-- Z1013 display is 32 x 32 xharactes on a 8x8 font
-- output format here is 800x600 pixel
-- the z1013 display will stretched to 512x512 (ever font-element quadrupelt)
-- and placed at 1st line starting at hor. pos 44
--
-- setting the generic G_readonly to true disables any writes from the cpu
-- so the videocontroller displays the initilized ram pattern
-- defined in video_ram_pkg.vhd
--
-- dualport ram as video - 
-- cpu stores 32x32 words 8 bit long, operating at cpu-clk (3.125M)
-- video controller reads from other port at video clk (40 MHz)
------------------------------------------------------------------------------
--Status: dimensions OK, same ghost pixels and a ghost pixel line 
-----------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.pkg_redz0mb1e.all;
use work.video_ram_pkg.all;             --video ram (types, powerup scr

entity video_ram is
  generic(G_System   : T_SYSTEM := DEV;
          G_READONLY : boolean  := false);  --true:fixes Bild aus initialisierten videoram);
  port(
    cpu_clk      : in  std_logic;       --cpu clk (i.e. 3.2 MHz)
    cpu_cs_ni    : in  std_logic;
    cpu_we_ni    : in  std_logic;
    cpu_addr_i   : in  std_logic_vector(9 downto 0);
    cpu_data_o   : out std_logic_vector(7 downto 0);
    cpu_data_i   : in  std_logic_vector(7 downto 0);
    video_clk    : in  std_logic;       --videoclk (i.e. 40MHz for 800x600@60)
    video_cs_ni  : in  std_logic;
    video_addr_i : in  std_logic_vector(9 downto 0);
    video_data_o : out std_logic_vector(7 downto 0));
end entity video_ram;

architecture behave of video_ram is
  signal vram_array : T_VRAM :=         --C_VRAM_ARRAY_SPACES_INIT;
                                     C_VRAM_ARRAY_INIT;
  signal selected4CPU   : boolean;
  signal s_we_n         : std_logic;
  signal selected4video : boolean := true;

  signal cpu_addr_integer   : T_VRAM_INDEX;
  signal video_addr_integer : T_VRAM_INDEX;

begin
  cpu_addr_integer   <= to_integer(unsigned(cpu_addr_i  (9 downto 0)));
  video_addr_integer <= to_integer(unsigned(video_addr_i(9 downto 0)));

  selected4CPU   <= cpu_cs_ni = '0';
  selected4video <= video_cs_ni = '0';
  s_we_n         <= cpu_we_ni when G_READONLY = false else
                    '1';
  
  process(cpu_clk)
  begin
    if falling_edge(cpu_clk) then
      if selected4CPU then
        if s_we_n = '0' then
          vram_array(cpu_addr_integer) <= to_integer(unsigned(cpu_data_i));
        else
          cpu_data_o <= std_logic_vector(to_unsigned(vram_array(cpu_addr_integer), 8));
        end if;
      end if;
    end if;
  end process;

  process(video_clk)
  begin
    if rising_edge(video_clk) then
      if selected4video then
        video_data_o <= std_logic_vector(to_unsigned(vram_array(video_addr_integer), 8));
      end if;
    end if;
  end process;
end architecture behave;
