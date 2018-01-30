
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_loader is
    generic (
        clk_frequency : natural := 60_000_000;
        timeout_msec  : natural := 100
    );
    port (
        clk     : in  std_ulogic;
        uart_rx : in  std_ulogic;
        active  : out std_ulogic;
        --
        ramAddr : out std_logic_vector(13 downto 0);
        ramData : out std_logic_vector( 7 downto 0);
        ramOe_N : out std_logic; 
        ramCE_N : out std_logic;
        ramWe_N : out std_logic
    );
end entity uart_loader;


architecture rtl of uart_loader is
  
    constant timeout_range  : natural := clk_frequency / 1000 * timeout_msec;
    constant header_address : natural := 16#0E0#;

    type state_t is (IDLE, ADDR);
    
    signal state         : state_t := IDLE;
    signal header        : natural range 0 to 32; 
    signal data          : std_logic_vector(7 downto 0);
    signal data_en       : std_ulogic;
    signal address       : unsigned(13 downto 0) := to_unsigned( header_address, 14);
    signal start_address : std_logic_vector(15 downto 0);
    signal timeout       : natural range 0 to timeout_range := timeout_range;
                      

begin

    process
    begin
        wait until rising_edge( clk);
        -- defaults
        ramOe_N <= '1';
        ramCE_N <= '1';
        ramWe_N <= '1';

        -- time out counter
        if timeout > 0 then
            timeout <= timeout - 1;
            active  <= '1';
        else
            -- reset address and header
            address <= to_unsigned( header_address, 14);
            header  <= 0;
            active  <= '0';
        end if;

        -- state machine for ram access
        case state is
          when IDLE =>
            if data_en = '1' then
              ramAddr <= std_logic_vector( address);
              address <= address + 1;
              ramData <= data;
              ramCE_N <= '0';

              -- interpret start address from header
              -- change save address on end of header
              if header < 32 then
                case header is
                    when 0 =>
                        start_address( 7 downto 0) <= data;
                    when 1 =>
                        start_address(15 downto 8) <= data;
                    when 31 =>
                        address <= unsigned( start_address( address'range));
                    when others =>
                end case;
                header <= header + 1;
              end if;
              
              state   <= ADDR;
              timeout <= timeout_range;
              active  <= '1';
            end if;
       
          when ADDR =>
            ramWe_N <= '0';
            ramCE_N <= '0';
            state   <= IDLE;

        end case;
    
    end process;


    rs232_i0: entity work.rs232 
    generic map ( 
        Quarz_Taktfrequenz => clk_frequency, --  : integer   := 60_000_000;  -- Hertz 
        Baudrate           => 9600        --  : integer   := 9600         -- Bits/Sec     
    ) 
    port map ( 
        clk     => clk,                   --  : in   std_logic;
        --
        rxd     => uart_rx,               --  : in   std_logic;
        txd     => open,                  --  : out  std_logic;
        --
        rx_data => data,                  --  : out  std_logic_vector (7 downto 0);
        rx_en   => data_en,               --  : out  std_logic;
        --
        tx_data => "00000000",            --  : in   std_logic_vector (7 downto 0);
        tx_en   => '0',                   --  : in   std_logic;
        tx_busy => open                   --  : out  std_logic
    );

end architecture rtl;

