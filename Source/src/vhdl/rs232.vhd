--
-- RS232 nach Lothar Moller (modifiziert)
-- http://www.lothar-miller.de/s9y/categories/42-RS232

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity rs232 is
    generic ( 
        Quarz_Taktfrequenz : integer   := 50_000_000;  -- Hertz 
        Baudrate           : integer   := 9600         -- Bits/Sec     
    ); 
    port ( 
        clk      : in   std_logic;
        --
        rxd      : in   std_logic;
        txd      : out  std_logic;
        --
        rx_data  : out  std_logic_vector (7 downto 0);
        rx_en    : out  std_logic;
        --
        tx_data  : in   std_logic_vector (7 downto 0);
        tx_en    : in   std_logic;
        tx_busy  : out  std_logic
    );
end entity rs232;


architecture Behavioral of RS232 is
signal txsr     : std_logic_vector  (9 downto 0) := "1111111111";  -- Startbit, 8 Datenbits, Stopbit
signal txbitcnt : integer range 0 to 10 := 10;
signal txcnt    : integer range 0 to (Quarz_Taktfrequenz/Baudrate)-1;

type rx_state_t is (IDLE, BUSY, READY);
signal rx_state : rx_state_t := IDLE;
signal rxd_sr   : std_logic_vector (3 downto 0) := "1111";         -- Flankenerkennung und Eintakten
signal rxsr     : std_logic_vector (7 downto 0) := "00000000";     -- 8 Datenbits
signal rxbitcnt : integer range 0 to 9 := 9;
signal rxcnt    : integer range 0 to (Quarz_Taktfrequenz/Baudrate)-1; 

begin
   -- Senden
   process begin
      wait until rising_edge(CLK);
      if tx_en = '1' then                    -- los gehts
         txcnt    <= 0;                      -- Zähler initialisieren
         txbitcnt <= 0;                      
         txsr     <= '1' & TX_Data & '0';    -- Stopbit, 8 Datenbits, Startbit, rechts gehts los
      else
         if(txcnt<(Quarz_Taktfrequenz/Baudrate)-1) then
            txcnt <= txcnt+1;
         else  -- nächstes Bit ausgeben  
            if (txbitcnt<10) then
              txcnt    <= 0;
              txbitcnt <= txbitcnt+1;
              txsr     <= '1' & txsr(txsr'left downto 1);
            end if;
         end if;
      end if;
   end process;
   TXD     <= txsr(0);  -- LSB first
   TX_Busy <= '1' when (tx_en='1' or txbitcnt<10) else '0';
   
   -- Empfangen
   process begin
      wait until rising_edge(CLK);
      rxd_sr <= rxd_sr(rxd_sr'left-1 downto 0) & RXD;
      RX_en     <= '0';
      
      case rx_state is
        when IDLE => -- warten auf Startbit
         if (rxd_sr(3 downto 2) = "10") then                 -- fallende Flanke Startbit
            rxcnt    <= ((Quarz_Taktfrequenz/Baudrate)-1)/2; -- erst mal nur halbe Bitzeit abwarten
            rxbitcnt <= 0;
            rx_state <= BUSY;
         end if;

        when BUSY =>
          if (rxbitcnt<9) then    -- Empfang läuft
             if(rxcnt<(Quarz_Taktfrequenz/Baudrate)-1) then 
                rxcnt    <= rxcnt+1;
             else
                rxcnt    <= 0; 
                rxbitcnt <= rxbitcnt+1;
                rxsr     <= rxd_sr(rxd_sr'left-1) & rxsr(rxsr'left downto 1); -- rechts schieben, weil LSB first
             end if;
          else
             rx_state <= READY;
          end if;
        when READY =>
            RX_Data  <= rxsr;
            RX_en    <= '1';
            rx_state <= IDLE;
      end case;

   end process;

end Behavioral;
