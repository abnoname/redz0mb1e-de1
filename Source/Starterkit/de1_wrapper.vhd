------------------------------------------------------------------------------
-- Project    : Red Zombie
------------------------------------------------------------------------------
-- File       :  Altera DE1 / de1_wrapper.vhd
-- Author     :  abnoname
-- Company    : hobbyist
-- Created    : 2013-04
-- Last update: 2013-05-01
-- Licence     : GNU General Public License (http://www.gnu.de/documents/gpl.de.html)
------------------------------------------------------------------------------
-- Description: 
-- Altera DE1 wrapper file
-- connects theZ1013 computer clone with the "hardware" on the DE1 kit
-- VGA-Output, ps/2 keyboard connector, sram, uart loader
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.pkg_redz0mb1e.all;

entity de1_wrapper is

port (
    CLOCK_24_0 : in  std_logic;
    -----
    PS2_DAT    : in    std_logic;
    PS2_CLK    : in    std_logic;
    VGA_B      : out   std_logic_vector(3 downto 0);
    VGA_G      : out   std_logic_vector(3 downto 0);
    VGA_R      : out   std_logic_vector(3 downto 0);
    VGA_HS     : out   std_logic;
    VGA_VS     : out   std_logic;
    -------
    UART_RXD   : in    std_logic;
    UART_TXD   : out   std_logic;
    ------
    LEDG       : out   std_logic_vector(7 downto 0);
    LEDR       : out   std_logic_vector(9 downto 0);
    HEX0       : out   std_logic_vector(6 downto 0);
    HEX1       : out   std_logic_vector(6 downto 0);
    HEX2       : out   std_logic_vector(6 downto 0);
    HEX3       : out   std_logic_vector(6 downto 0);
    ------
    KEY        : in    std_logic_vector(3 downto 0);     
    SW         : in    std_logic_vector(9 downto 0);
    ------
    SRAM_ADDR  : out   std_logic_vector(17 downto 0);
    SRAM_DQ    : inout std_logic_vector(15 downto 0);
    SRAM_CE_N  : out   std_logic;
    SRAM_LB_N  : out  std_logic;
    SRAM_OE_N  : out  std_logic;
    SRAM_UB_N  : out  std_logic;
    SRAM_WE_N  : out  std_logic
    );  
end de1_wrapper;

architecture arch of de1_wrapper is
    type Main_States is (idle, data_in, write_sram, readout_sram, transmit_sram);
    signal MainState : Main_States := idle;

    -- clocks:
    signal clk_aux    : std_logic;
    signal video_clk  : std_logic;
    signal cpu_clk    : std_logic;

    -- reset and uart loader
    signal redzombie_reset     : std_logic;
    signal uart_loader_active  : std_logic;

    -- vga
    signal vga_1bit_r  : std_logic;
    signal vga_1bit_g  : std_logic;
    signal vga_1bit_b  : std_logic;

    -- keyboard
    signal kyb_char      : std_logic_vector(15 downto 0);
    signal kyb_char_rev  : std_logic_vector(7 downto 0);
    signal key_released  : std_logic;
    signal key_extended  : std_logic;
    signal key_event     : std_logic;

    -- ram interface redzombie
    signal ramAddr_cpu   : std_logic_vector(13 downto 0);
    signal ramData_o_cpu : std_logic_vector( 7 downto 0);
    signal ramData_i_cpu : std_logic_vector( 7 downto 0);
    signal ramOe_N_cpu   : std_logic; 
    signal ramCE_N_cpu   : std_logic;
    signal ramWe_N_cpu   : std_logic;

    -- ram interface uart loader
    signal ramAddr_uart : std_logic_vector(13 downto 0);
    signal ramData_uart : std_logic_vector( 7 downto 0);
    signal ramOe_N_uart : std_logic; 
    signal ramCE_N_uart : std_logic;
    signal ramWe_N_uart : std_logic;

begin
    -- const outputs  
    UART_TXD   <= 'Z';    
    SRAM_LB_N  <= '0'; -- IO0 ... 7 only
    SRAM_UB_N  <= '1'; -- IO0 ... 7 only 
    VGA_R(3 downto 0) <= (others => vga_1bit_r);
    VGA_G(3 downto 0) <= (others => vga_1bit_g);
    VGA_B(3 downto 0) <= (others => vga_1bit_b);
    LEDR    <= (others => '0');
    
    -- reset
    redzombie_reset <= SW(9) or uart_loader_active;

    --debug Kram
    inst_seg0 : entity work.sevenseg
    port map (cntr  => (others => '0'), dig => HEX0);
    inst_seg1 : entity work.sevenseg
    port map (cntr  => (others => '0'), dig => HEX1);
    inst_seg2 : entity work.sevenseg
    port map (cntr  => kyb_char(3 downto 0), dig => HEX2);
    inst_seg3 : entity work.sevenseg
    port map (cntr  => kyb_char(7 downto 4), dig => HEX3);

    clock_blink_50m: entity work.clock_blink
    generic map (G_TICKS_PER_SEC => 60000000)
    port map (clk => clk_aux, blink_o => LEDG(0));
    clock_blink_videoclk: entity work.clock_blink
    generic map (G_TICKS_PER_SEC => 40000000)
    port map (clk => video_clk, blink_o => LEDG(1));
    clock_blink_cpuclk: entity work.clock_blink
    generic map (G_TICKS_PER_SEC => 12000000)
    port map (clk => cpu_clk, blink_o => LEDG(2));

    LEDG(3) <= key_released;
    LEDG(4) <= ramWe_N_uart or ramWe_N_cpu;
    LEDG(5) <= redzombie_reset;
    LEDG(6) <= uart_loader_active;    

    altpll0_1: entity work.altpll0
    port map (
        inclk0   => CLOCK_24_0, 
        c0       => clk_aux,   --60MHz
        c1       => video_clk, --40MHz
        c2       => cpu_clk    --12MHz
    );    

    keyboardVhdl_fk_1: entity work.keyboardVhdl_fk
    port map (
        CLK            => clk_aux,
        RST            => '0',
        KD             => PS2_DAT,
        KC             => PS2_CLK,
        kyb_out        => kyb_char_rev,
        is_released_oq => key_released,
        is_extended_oq => key_extended,
        done_oq        => key_event
    );

    kyb_char(11 downto  8) <= kyb_char_rev(7 downto 4);
    kyb_char(15 downto 12) <= kyb_char_rev(3 downto 0);

    ------------------------------------
    --RAM MUX
    ------------------------------------  
    SRAM_ADDR(13 downto 0) <= ramAddr_uart        when uart_loader_active = '1' else ramAddr_cpu;        
    -- ram data output:
    SRAM_DQ(7 downto 0)    <= ramData_uart        when uart_loader_active = '1' and ramWe_N_uart = '0' else
                              ramData_o_cpu       when uart_loader_active = '0' and ramWe_N_cpu  = '0' else 
                              (others => 'Z')     when uart_loader_active = '0' and ramWe_N_cpu  = '1';
    -- ram data input:
    ramData_i_cpu          <= SRAM_DQ(7 downto 0) when uart_loader_active = '0' and ramWe_N_cpu  = '1';
    SRAM_OE_N              <= ramOe_N_uart        when uart_loader_active = '1' else ramOe_N_cpu;    
    SRAM_CE_N              <= ramCE_N_uart        when uart_loader_active = '1' else ramCE_N_cpu;    
    SRAM_WE_N              <= ramWe_N_uart        when uart_loader_active = '1' else ramWe_N_cpu;    

    ------------------------------------
    --uart loader
    ------------------------------------  
    uart_loader_1: entity work.uart_loader
    generic map (
        clk_frequency => 60_000_000,
        timeout_msec => 100
    )
    port map (
        clk     => clk_aux,
        uart_rx => UART_RXD,
        active  => uart_loader_active,
        --
        ramAddr => ramAddr_uart,
        ramData => ramData_uart,
        ramOe_N => ramOe_N_uart,
        ramCE_N => ramCE_N_uart,
        ramWe_N => ramWe_N_uart
    );

    ------------------------------------
    --redzomb1e
    ------------------------------------  
    redz0mb1e_1 : entity work.redz0mb1e
    port map (
        cpu_clk      => cpu_clk,
        video_clk    => video_clk,
        clk_50m      => clk_aux,
        rst_button_i => redzombie_reset,
        keys_in      => KEY(2 downto 0),    
        kyb_in       => kyb_char_rev(7 downto 0),
        key_released => key_released,
        key_event    => key_event,
        key_extended => key_extended,
        red_o        => vga_1bit_r,
        blue_o       => vga_1bit_b,
        green_o      => vga_1bit_g,
        vsync_o      => VGA_VS,
        hsync_o      => VGA_HS,
        col_fg       => SW(7 downto 5),
        col_bg       => SW(2 downto 0),
        ramAddr      => ramAddr_cpu,
        ramData_o    => ramData_o_cpu,
        ramData_i    => ramData_i_cpu,
        ramOe_N      => ramOe_N_cpu, 
        ramCE_N      => ramCE_N_cpu,
        ramWe_N      => ramWe_N_cpu       
    );    
    
end arch;
