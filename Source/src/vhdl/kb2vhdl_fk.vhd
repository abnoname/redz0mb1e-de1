------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  kb2vhdl_vu.vhd
-- Author     :  fpgakuechle
-- Company    : hobbyist
-- Created    : 2012-03-23
-- Last update: 2013-04-02
-- Licence     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- reads from ps2 keyboard scancode sets flags indicating key is from extended set
-- (i.e. multimediakeys) and signals if key was pressed or released,
-- a '1' pulse indicates end of scnacode receive
--
-- rewritten from the scratch

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity keyboardVhdl_fk is
  port (
    CLK, RST       : in  std_logic;
    KD, KC         : in  std_logic;     --ps2 interface (i2c like)
    kyb_out        : out std_logic_vector (7 downto 0);
    is_released_oq : out std_logic;  --key with code kyb_out is '1': released; '0' pressed
    is_extended_oq : out std_logic;  --key with code kyb_out is extended ("windows"-key, numPad,..)
    done_oq        : out std_logic);   --'1' pulse -> key released
end keyboardVhdl_fk;

architecture Behavioral of keyboardVhdl_fk is

  CONSTANT C_LENGTH_SHFTREG : integer RANGE 8 TO 11 := 10;
  signal kdat_sync     : std_logic_vector(2 downto 0) := (others => '0');
  signal kclk_sync     : std_logic_vector(2 downto 0) := (others => '0');
  signal kclk_fal     : boolean;
  signal kclk_ris     : boolean;

  type   T_IF_STATE is (IDLE, START, DATA, STOP);
  signal if_state_q    : T_IF_STATE := IDLE;
  signal word_complete : boolean;

  signal data_reg_q : std_logic_vector(C_LENGTH_SHFTREG - 1 downto 0);

  type   T_SCAN_SEQ is (IDLE, INCOMING, EXTENDED, RELEASED, COMPLETE);
  signal scan_seq_q : T_SCAN_SEQ := IDLE;
  
  begin
  --sync in
  P_sync_in : process (clk)  
  begin
    if rising_edge(clk) then
      kdat_sync <= kdat_sync(1 downto 0) & KD;
      kclk_sync <= kclk_sync(1 downto 0) & KC;
    end if;
  end process P_sync_in;

  kclk_fal <= kclk_sync(2 downto 1) = "10";
  kclk_ris <= kclk_sync(2 downto 1) = "01";

  P_data_in : PROCESS (clk)
  BEGIN
      IF rising_edge(clk) THEN
          IF if_state_q = IDLE THEN
              --clear all bits, set Countbit
              data_reg_q((C_LENGTH_SHFTREG - 2) DOWNTO 0) <= (OTHERS => '0');
              data_reg_q(C_LENGTH_SHFTREG - 1)            <= '1';  --own "Startbit" to detect final shift
          ELSIF (if_state_q = DATA) AND kclk_fal THEN
              data_reg_q <= kdat_sync(2) & data_reg_q(C_LENGTH_SHFTREG - 1 DOWNTO 1);
          END IF;
      END IF;
  END PROCESS P_data_in;
  
  --IF control state machine-process a single word
  P_IF_FSM : process(clk)
  begin
    if rising_edge(clk) then
      word_complete <= false;
      case if_state_q is
        when IDLE =>
          if (kclk_sync(2) = '1') and (kdat_sync(2) = '1')  and  (kdat_sync(1) = '0') then
            if_state_q <= START;
          end if;

        when START =>
          if kclk_ris then
            if_state_q <= DATA;
          end if;

        when DATA =>  --databits and parity
          if data_reg_q(0) = '1' THEN  --all bits shifted
            word_complete <= true;
            if_state_q <= STOP;
          end if;

        when STOP =>
          if kclk_ris then
            if_state_q    <= IDLE;
          end if;
      end case;
    end if;
  end process P_IF_FSM;

  --scancode sequence FSM - process sequence (Extended Mark, Break mark, real scancode)
  P_SEQ : process(clk)
  begin
    if rising_edge(clk) then
      done_oq <= '0';
      case scan_seq_q is
        --wait for new scancode
        when IDLE =>
          if word_complete then         --after every word (Stopbit)    
            scan_seq_q <= INCOMING;
          end if;

        --wait to process 1st byte  
        when INCOMING =>
          is_extended_oq <= '0';
          is_released_oq <= '0';
          --extended marked by 1st byte xE0 -> one (pressed) or two bytes
          --(released) will follow,
          if data_reg_q(8 downto 1) = x"E0" then
            scan_seq_q     <= EXTENDED;
            is_extended_oq <= '1';
            --released marked byte xF0 -> one byte will follow
          elsif data_reg_q(8 downto 1) = x"F0" then
            is_released_oq <= '1';
            scan_seq_q     <= RELEASED;
            --1st byte is final byte: real keycode  
          else
            scan_seq_q <= COMPLETE;
          end if;

         --wait/process for second byte when extended code
        when EXTENDED =>
          if word_complete then
            if data_reg_q(8 downto 1) = x"F0" then
              scan_seq_q     <= RELEASED;
              is_released_oq <= '1';
            else
              scan_seq_q <= COMPLETE;
            end if;
          end if;
          --wait/process for second byte

        --wait/process for final byte: real keycode  
        when RELEASED =>
          if word_complete then
            scan_seq_q <= COMPLETE;
          end if;

          --all bytes processed, copy key code to output
        when COMPLETE =>
          --shifted data minus start (0),Parity(9),stop(10)  
          kyb_out    <= data_reg_q(8 downto 1);
          scan_seq_q <= IDLE;
          done_oq    <= '1';
      end case;
    end if;
  end process P_SEQ;
end Behavioral;
