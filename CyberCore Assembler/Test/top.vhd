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
        LED         : out std_logic_vector (15 downto 0);
        led_display : out std_logic_vector (6 downto 0);
        anode_sel   : out std_logic_vector(3 downto 0);
        Rx          : in  std_logic;
        Tx          : out std_logic
        );

end entity;

architecture top_arch of top is

  type state_type is(interrupt_state, interrupt_idle);

  signal current_state, next_state : state_type;

  component attack_voter is
    port(
      core_1_val     : in std_logic_vector(7 downto 0);
      core_2_val     : in std_logic_vector(7 downto 0);
      core_3_val     : in std_logic_vector(7 downto 0);
      output_val     : out std_logic_vector(7 downto 0)
      );
  end component;

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

  component uart is
    port (
      clk           : in  std_logic;
      uart_clk      : in  std_logic;
      Rx            : in  std_logic;
      Tx            : out std_logic;
      ready_flag    : out std_logic;
      received_byte : out std_logic_vector(7 downto 0);
      address_out   : out std_logic_vector(2 downto 0);
      output_1      : out std_logic_vector(7 downto 0);
      output_2      : out std_logic_vector(7 downto 0);
      output_3      : out std_logic_vector(7 downto 0);
      output_4      : out std_logic_vector(7 downto 0);
      output_5      : out std_logic_vector(7 downto 0);
      output_6      : out std_logic_vector(7 downto 0);
      output_7      : out std_logic_vector(7 downto 0);
      output_8      : out std_logic_vector(7 downto 0)
      );
  end component;

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

  component computer_core_2
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

  component computer_core_3
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
      clk     : in std_logic;
      probe0  : in std_logic_vector(7 downto 0);
      probe1  : in std_logic_vector(2 downto 0);
      probe2  : in std_logic_vector(3 downto 0);
      probe3  : in std_logic_vector(7 downto 0);
      probe4  : in std_logic_vector(7 downto 0);
      probe5  : in std_logic_vector(7 downto 0);
      probe6  : in std_logic_vector(7 downto 0);
      probe7  : in std_logic_vector(7 downto 0);
      probe8  : in std_logic_vector(7 downto 0);
      probe9  : in std_logic_vector(7 downto 0);
      probe10 : in std_logic_vector(7 downto 0);
      probe11 : in std_logic;
      probe12 : in std_logic;
      probe13 : in std_logic
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

  signal buff_ready                                             : std_logic;
  signal buff_address                                           : std_logic_vector(3 downto 0);
  signal buff1, buff2, buff3, buff4, buff5, buff6, buff7, buff8 : std_logic_vector(7 downto 0);

  -- Interrupts
  signal interrupt     : std_logic_vector(3 downto 0) := "0000";
  signal interrupt_clr_1, interrupt_clr_2, interrupt_clr_3, interrupt_clr_top : std_logic                    := '0';
  signal rx_read       : std_logic_vector(7 downto 0);
--  signal uart          : std_logic                    := '0';

  signal uart_clk    : std_logic;
  signal rx_byte_val : std_logic_vector(7 downto 0);
  -- Debugging
  signal address_out : std_logic_vector(2 downto 0);
  signal probe1      : std_logic_vector(7 downto 0);
  signal probe2      : std_logic_vector(7 downto 0);

begin

  LED(0) <= exception_flag_1;
  LED(1) <= exception_flag_2;
  LED(2) <= exception_flag_3;
  LED(15 downto 8) <= rx_byte_val;

  display_value <= voter_result(3 downto 0) & port_out_temp01(3 downto 0) & port_out_temp02(3 downto 0) & port_out_temp03(3 downto 0);
  
  clock_div : clock_div_prec port map (Clock_in  => CLK,
                                       Sel       => "11",
                                       Reset     => RESET,
                                       Clock_out => clock_slow);

  uart_clock_div : clk_wiz_0 port map (clk_in1  => CLK,
                                       reset    => RESET,
                                       clk_out1 => uart_clk);

  uart_comp : uart port map (clk           => CLK,
                             uart_clk      => uart_clk,
                             Rx            => Rx,
                             Tx            => Tx,
                             ready_flag    => buff_ready,
                             received_byte => rx_byte_val,
                             address_out   => address_out,
                             output_1      => buff1,
                             output_2      => buff2,
                             output_3      => buff3,
                             output_4      => buff4,
                             output_5      => buff5,
                             output_6      => buff6,
                             output_7      => buff7,
                             output_8      => buff8);

  comp1 : computer_core_1 port map (clock         => CLK,
                                    RESET         => Reset,
                                    interrupt     => interrupt,
                                    interrupt_clr => interrupt_clr_1,
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
                                    port_in_14    => buff7,
                                    port_in_15    => buff8,
                                    port_out_00   => port_out_temp01
                                    );

  comp2 : computer_core_2 port map (clock         => CLK,
                                    RESET         => Reset,
                                    interrupt     => interrupt,
                                    interrupt_clr => interrupt_clr_2,
                                    cpu_exception => exception_flag_2,
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
                                    port_in_14    => buff7,
                                    port_in_15    => buff8,
                                    port_out_00   => port_out_temp02
                                    );

  comp3 : computer_core_3 port map (clock         => CLK,
                                    RESET         => Reset,
                                    interrupt     => interrupt,
                                    interrupt_clr => interrupt_clr_3,
                                    cpu_exception => exception_flag_3,
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
                                    port_in_14    => buff7,
                                    port_in_15    => buff8,
                                    port_out_00   => port_out_temp03
                                    );

  debug : ila_0 port map(
    clk     => CLK,
    probe0  => port_out_temp01,
    probe1  => address_out,
    probe2  => interrupt,
    probe3  => buff1,
    probe4  => buff2,
    probe5  => buff3,
    probe6  => buff4,
    probe7  => buff5,
    probe8  => buff6,
    probe9  => buff7,
    probe10 => buff8,
    probe11 => interrupt_clr_1,
    probe12 => buff_ready,
    probe13 => exception_flag_1
    );

  attack_voter_1 : attack_voter port map(
    core_1_val => port_out_temp01,
    core_2_val => port_out_temp02,
    core_3_val => port_out_temp03,
    output_val => voter_result
    );
    

  next_state_logic : process(CLK)
  begin
    if(rising_edge(CLK)) then
      current_state <= next_state;
    end if;
  end process;

  state_logic : process (CLK, interrupt_clr_1, buff_ready)
  begin

    if(current_state = interrupt_state and interrupt_clr_1 = '1') then
      next_state <= interrupt_idle;
    elsif(current_state = interrupt_idle) then
      if(rising_edge(buff_ready)) then
        next_state <= interrupt_state;
      end if;
    else
      next_state <= current_state;
    end if;
  end process;

  state_output : process(current_state)
  begin
    case(current_state) is
      when interrupt_idle =>
        interrupt <= "0000";
      when interrupt_state =>
        interrupt <= "0001";
    end case;
  end process;

  display_out : char_driver port map
    (
      clk         => CLK,
      reset       => RESET,
      bin_in      => display_value,
      anode_sel   => anode_sel,
      led_display => led_display
      );


end architecture;
