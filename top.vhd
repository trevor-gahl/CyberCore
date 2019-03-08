library IEEE;
use iEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
library xil_defaultlib;
use xil_defaultlib.instructions_core_1.all;

entity top is
  port (CLK         : in  std_logic;
        RESET       : in  std_logic;
        SW          : in  std_logic_vector (3 downto 0);
        LED         : out std_logic_vector (7 downto 0);
        led_display : out std_logic_vector (6 downto 0);
        anode_sel   : out std_logic_vector(3 downto 0);
        Rx          : in  std_logic;
        Tx          : out std_logic
        );

end entity;

architecture top_arch of top is

  component char_driver is
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      bin_in      : in  std_logic_vector(15 downto 0);
      anode_sel   : out std_logic_vector(3 downto 0);
      led_display : out std_logic_vector(6 downto 0)
      );
  end component;

  component clk_wiz_0 is
    port
      (clk_out1 : out std_logic;
       reset    : in  std_logic;
       clk_in1  : in  std_logic);
  end component;

  component uart_tx is
    generic (
      clks_per_bit : integer := 868     -- Needs to be set correctly
      );
    port (
      clk       : in  std_logic;
      tx_dv     : in  std_logic;
      tx_byte   : in  std_logic_vector(7 downto 0);
      tx_active : out std_logic;
      tx_serial : out std_logic;
      tx_done   : out std_logic
      );
  end component uart_tx;

  component uart_rx is
    generic (
      clks_per_bit : integer := 868     -- Needs to be set correctly
      );
    port (
      clk       : in  std_logic;
      rx_serial : in  std_logic;
      rx_dv     : out std_logic;
      rx_byte   : out std_logic_vector(7 downto 0)
      );
  end component uart_rx;
--  component char_decoder
--    port (bin_in        : in  std_logic_vector (3 downto 0);
--          seven_seg_out : out std_logic_vector (6 downto 0));
--  end component;

  component clock_div_prec
    port (Clock_in  : in  std_logic;
          Sel       : in  std_logic_vector (1 downto 0);
          Reset     : in  std_logic;
          Clock_Out : out std_logic);
  end component;

  component computer_core_1
    port (
      port_in_00    : in  std_logic_vector (7 downto 0);
      port_in_01    : in  std_logic_vector (7 downto 0);
      port_in_02    : in  std_logic_vector (7 downto 0);
      port_in_03    : in  std_logic_vector (7 downto 0);
      port_in_04    : in  std_logic_vector (7 downto 0);
      port_in_05    : in  std_logic_vector (7 downto 0);
      port_in_06    : in  std_logic_vector (7 downto 0);
      port_in_07    : in  std_logic_vector (7 downto 0);
      port_in_08    : in  std_logic_vector (7 downto 0);
      port_in_09    : in  std_logic_vector (7 downto 0);
      port_in_10    : in  std_logic_vector (7 downto 0);
      port_in_11    : in  std_logic_vector (7 downto 0);
      port_in_12    : in  std_logic_vector (7 downto 0);
      port_in_13    : in  std_logic_vector (7 downto 0);
      port_in_14    : in  std_logic_vector (7 downto 0);
      port_in_15    : in  std_logic_vector (7 downto 0);
      port_out_00   : out std_logic_vector (7 downto 0);
      port_out_01   : out std_logic_vector (7 downto 0);
      port_out_02   : out std_logic_vector (7 downto 0);
      port_out_03   : out std_logic_vector (7 downto 0);
      port_out_04   : out std_logic_vector (7 downto 0);
      port_out_05   : out std_logic_vector (7 downto 0);
      port_out_06   : out std_logic_vector (7 downto 0);
      port_out_07   : out std_logic_vector (7 downto 0);
      port_out_08   : out std_logic_vector (7 downto 0);
      port_out_09   : out std_logic_vector (7 downto 0);
      port_out_10   : out std_logic_vector (7 downto 0);
      port_out_11   : out std_logic_vector (7 downto 0);
      port_out_12   : out std_logic_vector (7 downto 0);
      port_out_13   : out std_logic_vector (7 downto 0);
      port_out_14   : out std_logic_vector (7 downto 0);
      port_out_15   : out std_logic_vector (7 downto 0);
      interrupt_clr : out std_logic;
      interrupt     : in  std_logic_vector (3 downto 0);
      reset         : in  std_logic;
      clock         : in  std_logic;
      cpu_exception : out std_logic);
  end component;

  component ila_0 is
    port(
      clk    : in std_logic;
      probe0 : in std_logic_vector(7 downto 0);
      probe1 : in std_logic_vector(7 downto 0);
      probe2 : in std_logic_vector(7 downto 0);
      probe3 : in std_logic_vector(7 downto 0);
      probe4 : in std_logic_vector(7 downto 0)
      );
  end component;

  signal port_out_temp01, port_out_temp02, port_out_temp03       : std_logic_vector(7 downto 0);
  signal clock_slow                                              : std_logic;
  signal highs, sw_data_in, GPIO_01, GPIO_02                     : std_logic_vector(7 downto 0);
  signal voter_result                                            : std_logic_vector(7 downto 0);
  signal OutA, OutB, OutC                                        : std_logic_vector(7 downto 0);
  signal exception_flag_1, exception_flag_2, exception_flag_3    : std_logic;
  signal voter_exception_1, voter_exception_2, voter_exception_3 : std_logic;
  signal display_value                                           : std_logic_vector(15 downto 0);

  -- UART
  signal clks_per_bit                                           : integer := 87;
  signal uart_clk                                               : std_logic;
  signal rx_dv_sig                                              : std_logic;
  signal rx_byte_val                                            : std_logic_vector(7 downto 0);
  signal tx_dv_sig                                              : std_logic;
  signal tx_byte_val                                            : std_logic_vector(7 downto 0);
  signal tx_done_sig                                            : std_logic;
  signal buff_address                                           : std_logic_vector(3 downto 0);
  signal buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8 : std_logic_vector(7 downto 0);

  -- Interrupts
  signal interrupt     : std_logic_vector(3 downto 0) := "0000";
  signal interrupt_clr : std_logic                    := '0';
  signal rx_read       : std_logic_vector(7 downto 0);
  signal uart          : std_logic                    := '0';

  -- Debugging
  signal probe1 : std_logic_vector(7 downto 0);
  signal probe2 : std_logic_vector(7 downto 0);

begin

  LED(0) <= exception_flag_1;
  LED(1) <= exception_flag_2;
  LED(2) <= exception_flag_3;

--  sw_data_in <= "0000" & SW;

uart_clock_div : clk_wiz_0 port map (clk_in1  => CLK,
                                     reset    => RESET,
                                     clk_out1 => uart_clk);

  display_value <= rx_read & port_out_temp01;
  clock_div : clock_div_prec port map (Clock_in  => CLK,
                                       Sel       => "11",
                                       Reset     => RESET,
                                       Clock_out => clock_slow);

  comp1 : computer_core_1 port map (clock         => CLK,
                                    RESET         => Reset,
                                    interrupt     => interrupt,
                                    interrupt_clr => interrupt_clr,
                                    cpu_exception => exception_flag_1,
                                    port_in_00    => rx_read,
                                    port_in_01    => highs,
                                    port_in_02    => highs,
                                    port_in_03    => highs,
                                    port_in_04    => highs,
                                    port_in_05    => highs,
                                    port_in_06    => highs,
                                    port_in_07    => highs,
                                    port_in_08    => buff1,
                                    port_in_09    => buff2,
                                    port_in_10    => buff3,
                                    port_in_11    => buff4,
                                    port_in_12    => buff5,
                                    port_in_13    => buff6,
                                    port_in_14    => CLI,
                                    port_in_15    => RTI,
                                    port_out_00   => port_out_temp01,
                                    port_out_01   => port_out_temp02,
                                    port_out_02   => port_out_temp03
                                    );

  probe1 <= "0000000"&uart;
  probe2 <= buff_address&interrupt;

  debug : ila_0 port map(
    clk    => CLK,
    probe0 => port_out_temp01,
    probe1 => probe1,
    probe2 => probe2,
    probe3 => rx_read,
    probe4 => rx_byte_val
    );

  display_out : char_driver port map
    (
      clk         => CLK,
      reset       => RESET,
      bin_in      => display_value,
      anode_sel   => anode_sel,
      led_display => led_display
      );

end architecture;
