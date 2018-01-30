------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  kyb_emu.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-12
-- Last update: 2013-04-03
-- Licence     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
--Keyboard converter
--PS/2 serial to 8x4 matrix
--drives rows from an IO-Access
--convert via dual-port ram
-----------------------------------------------------------------------------
--Status: standard keys (letters, numbers) work fine
------------------------------------------------------------------------------
--Firmware keyboard releation
--2.02 -> 8x4
--A.2  -> 8x8
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.scancode_pkg.all;

entity kyb_emu is
  port(
    clk_4x8      : in  std_logic;
    clk_ps2      : in  std_logic;
    data_i       : in  std_logic_vector(7 downto 0);
    --row driver connected as IO-device
    ce_key_ni    : in  std_logic;
    -- scanned data from keyb column to pio
    --Z1013: 4 bits as "row(s) selected"
    col_o        : out std_logic_vector(7 downto 0);
    --from PS/2 keyboard
    scancode_in  : in  std_logic_vector(7 downto 0);
    key_released : in  std_logic;
    key_event    : in  std_logic;
    key_extended : in  std_logic
    );  
end entity kyb_emu;

architecture behave of kyb_emu is
  signal ce_key_del_q : std_logic;

  --only 3 bits used for standard keyboard
  signal Keyb_nu_q : std_logic_vector(3 downto 0) := (others => '0');
  signal scancode          : T_SCANCODE;  --type converted input
  signal scancode_old_q    : T_SCANCODE;  --for edge detection
  signal scancode_active_q : T_SCANCODE := 16#26#;  --scancode for released/pressed key coding
  signal key_changed       : boolean;
  signal shift_pressed_q   : boolean := false;

--kybmatrix
--           col0    col1    col2   col3 ...    col9
--  row0 ->   1        1
--  row1 ->   1        0
--  row2 ->   1        1
--  row3 ->   1        1
--
-- example shows pressed as coloum 1|row1  


  --8x4 emulated matrix
  subtype T_COL is std_logic_vector(3 downto 0);
  subtype T_ROW is integer range 0 to 7;
  type    T_KEYMATRIX is array (T_ROW) of T_COL;

  signal keyb_matrix : T_KEYMATRIX := (others => "1111");

  --translation from scancode to 8x4
  --ROM 7bit address (scancode) 7bit data_out
  --
  signal kybtrans_table       : T_KYBTRANS_TABLE := C_KYBTRANS_INIT;
  signal kybtrans_table_o     : T_KYBTRANS;                    -- 7 bit
  signal row_sel_decode       : std_logic_vector(3 downto 0);  --"one hot" endcoding
  signal keyb_matrix_ps2_do   : std_logic_vector(3 downto 0);
  signal key_matrix_di        : std_logic_vector(3 downto 0);
  signal current_row          : std_logic_vector(3 downto 0);
--
  signal shift_col_sel_decode : std_logic_vector(2 downto 0);  --coloum of shift key pressed 
  signal col_to_write         : std_logic_vector(2 downto 0);


  --control 
  signal do_write    : boolean := false;
  signal shift_press : boolean := false;
  signal key_release : boolean := false;

  type   T_KYB_CTRL_STATE is (IDLE, MATRIX_WR, PREP_KEY);
  signal kyb_ctrl_state : T_KYB_CTRL_STATE := IDLE;

  --3.125 MHz (CPU-clock) 320 ns
  --wait time between keyboard actions ~10 ms -> 31250
  
  subtype T_WAITCOUNT is integer range 400000  downto 0;
  signal  waitcounter_q    : T_WAITCOUNT := T_WAITCOUNT'low;
  signal  do_wait, waiting : boolean;
  
begin
  --read decode matrix
-- datapath:
-- port scanport_i -> register scancode used -> kybtranstable -> kybtranstable_o
-- a) adr : kybtranstable_o
--  (6 downto 0) -> decode to shift_col_sel  -> M   
--                                              U  -> col_to_write -> kyb_matix
--  (2 downto 0) col_sel                     -> X 
  scancode         <= to_integer(unsigned(scancode_in(7 downto 0)));
  kybtrans_table_o <= kybtrans_table(scancode_active_q);

  --decode new matrix setting
  with kybtrans_table_o(3 to 4) select
    row_sel_decode <= "0001" when "00",    --upper row 8x4
    "0010"                   when "01",
    "0100"                   when "10",
    "1000"                   when "11",   --lower row
    "0000"                   when others;

  ------------------------
  --spaltentreiber
  process(clk_4x8)
  begin
    if falling_edge(clk_4x8) then
      ce_key_del_q <= ce_key_ni;
      if ce_key_ni = '0' and ce_key_del_q = '1' then
        Keyb_nu_q <= data_i(3 downto 0);
      end if;
    end if;
  end process;

  --reading 8x4 side 
  process(clk_4x8)
  begin
    if falling_edge(clk_4x8) then
      col_o <= "1111" & keyb_matrix(to_integer(unsigned(Keyb_nu_q(2 downto 0))));
    end if;
  end process;

  --writing (modifying) ps2 side 
  col_to_write <= kybtrans_table_o(0 to 2) when not shift_press else
                  shift_col_sel_decode;

  --shift key
  with kybtrans_table_o(5 to 6) select
    shift_col_sel_decode <=
    "000" when "01",                    --S1
    "001" when "10",                    --S2
    "010" when "11",                    --S3
    "110" when "00",                    --NONE -> Cursor LFT
    "110" when others;
  
  current_row <= row_sel_decode when not shift_press else
                 "1000"         when     shift_press and kybtrans_table_o(5 to 6) /= "00" else
                 "0000";        --no shift key
  

  GEN_KEY_MATRIX_WR : for i in 0 to 3 generate
    key_matrix_di(i) <= '1'                                           when  key_release ELSE
                        not current_row(i) and    keyb_matrix_ps2_do(i);
--                      '1': do press/release  '1': not pressed  
  end GENERATE GEN_KEY_MATRIX_WR;

  process(clk_ps2)
  begin
    if falling_edge(clk_ps2) then
      if do_write then
        keyb_matrix(to_integer(unsigned(col_to_write))) <= key_matrix_di;
      end if;
      keyb_matrix_ps2_do <= keyb_matrix(to_integer(unsigned(col_to_write))); --to late when buffered?
    end if;
  end process;

  --control 

  key_changed <= --scancode_old_q /= scancode;
                 key_event = '1';
  process(clk_ps2)
  begin
    if rising_edge(clk_ps2) then
      do_write       <= false;
      case kyb_ctrl_state is
        when IDLE =>
          shift_press <= true;
          key_release <= key_released = '1';  --release prev. key when leaving idle
          if key_changed then
            if shift_pressed_q then
              scancode_active_q <= to_integer(unsigned('1' & scancode_in(6 downto 0)));
            else
              scancode_active_q <= to_integer(unsigned('0' & scancode_in(6 downto 0)));
            end if;
            if (scancode = 16#12#) or (scancode = 16#59#) then    --shift key
              if key_released = '1' then
                shift_pressed_q <= false;
              else
                shift_pressed_q <= true;
              end if;
            else
              do_write       <= true;
              kyb_ctrl_state <= MATRIX_WR;
            end if;
          end if;
          
        when MATRIX_WR =>
          do_write <= false;            --write active when entering state
          if not waiting then
            if shift_press then         --emulate shift
              kyb_ctrl_state <= PREP_KEY;
              shift_press    <= false;
            else                        --emualte real key
              kyb_ctrl_state <= IDLE;
            end if;
          end if;

        when PREP_KEY =>
          --check if we're done 
          if key_release then
            do_write       <= true;
            kyb_ctrl_state <= MATRIX_WR;
          else
            do_write       <= true;
            kyb_ctrl_state <= MATRIX_WR;
          end if;

        when others =>
          kyb_ctrl_state <= IDLE;
      end case;
    end if;
  end process;

  do_wait <= ((kyb_ctrl_state = IDLE)       and     key_changed) or
              (kyb_ctrl_state = PREP_KEY);
             
  --waitcounter 
  process(clk_ps2)
  begin
    if rising_edge(clk_ps2) then
      if do_wait then
        waitcounter_q <= T_WAITCOUNT'high;
      elsif waiting then
        waitcounter_q <= waitcounter_q - 1;
      end if;
    end if;
  end process;

    waiting <= waitcounter_q /= T_WAITCOUNT'low;
  
end architecture;
