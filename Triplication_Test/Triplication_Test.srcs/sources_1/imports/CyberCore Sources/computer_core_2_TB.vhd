----------------------------------------------------------------------
-- File name   : ucat_TB.vhd
--
-- Project     : 8-bit Microcomputer
--
-- Description : VHDL testbench
--
-- Author(s)   : Brock J. LaMeres
--               Montana State University
--               lameres@ece.montana.edu
--
-- Date        : April 15, 2014
--
----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity computer_core_2_TB is
end entity;

architecture computer_TB_arch of computer_core_2_TB is

  constant t_clk_per : time := 20 ns;   -- Period of a 50MHZ Clock

-- Component Declaration

  component computer_core_2
    port (clock         : in  std_logic;
          reset         : in  std_logic;
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
          interrupt     : in  std_logic_vector (3 downto 0);
          interrupt_clr : out std_logic;
          cpu_exception : out std_logic);
  end component;

  -- Signal Declaration

  signal clock_TB       : std_logic;
  signal reset_TB       : std_logic;
  signal port_out_00_TB : std_logic_vector (7 downto 0);
  signal port_out_01_TB : std_logic_vector (7 downto 0);
  signal port_out_02_TB : std_logic_vector (7 downto 0);
  signal port_out_03_TB : std_logic_vector (7 downto 0);
  signal port_out_04_TB : std_logic_vector (7 downto 0);
  signal port_out_05_TB : std_logic_vector (7 downto 0);
  signal port_out_06_TB : std_logic_vector (7 downto 0);
  signal port_out_07_TB : std_logic_vector (7 downto 0);
  signal port_out_08_TB : std_logic_vector (7 downto 0);
  signal port_out_09_TB : std_logic_vector (7 downto 0);
  signal port_out_10_TB : std_logic_vector (7 downto 0);
  signal port_out_11_TB : std_logic_vector (7 downto 0);
  signal port_out_12_TB : std_logic_vector (7 downto 0);
  signal port_out_13_TB : std_logic_vector (7 downto 0);
  signal port_out_14_TB : std_logic_vector (7 downto 0);
  signal port_out_15_TB : std_logic_vector (7 downto 0);
  signal port_in_00_TB  : std_logic_vector (7 downto 0);
  signal port_in_01_TB  : std_logic_vector (7 downto 0);
  signal port_in_02_TB  : std_logic_vector (7 downto 0);
  signal port_in_03_TB  : std_logic_vector (7 downto 0);
  signal port_in_04_TB  : std_logic_vector (7 downto 0);
  signal port_in_05_TB  : std_logic_vector (7 downto 0);
  signal port_in_06_TB  : std_logic_vector (7 downto 0);
  signal port_in_07_TB  : std_logic_vector (7 downto 0);
  signal port_in_08_TB  : std_logic_vector (7 downto 0);
  signal port_in_09_TB  : std_logic_vector (7 downto 0);
  signal port_in_10_TB  : std_logic_vector (7 downto 0);
  signal port_in_11_TB  : std_logic_vector (7 downto 0);
  signal port_in_12_TB  : std_logic_vector (7 downto 0);
  signal port_in_13_TB  : std_logic_vector (7 downto 0);
  signal port_in_14_TB  : std_logic_vector (7 downto 0);
  signal port_in_15_TB  : std_logic_vector (7 downto 0);
  signal interrupt_TB   : std_logic_vector (3 downto 0) := "0000";
  signal interrupt_clr  : std_logic;
  signal cpu_exception  : std_logic;
  signal int_cnt        : std_logic_vector (5 downto 0) := (others => '0');
  signal rx_sig         : std_logic_vector (7 downto 0) := (others => '0');

begin
  DUT1 : computer_core_2
    port map (clock         => clock_TB,
              reset         => reset_TB,
              port_out_00   => port_out_00_TB,
              port_out_01   => port_out_01_TB,
              port_out_02   => port_out_02_TB,
              port_out_03   => port_out_03_TB,
              port_out_04   => port_out_04_TB,
              port_out_05   => port_out_05_TB,
              port_out_06   => port_out_06_TB,
              port_out_07   => port_out_07_TB,
              port_out_08   => port_out_08_TB,
              port_out_09   => port_out_09_TB,
              port_out_10   => port_out_10_TB,
              port_out_11   => port_out_11_TB,
              port_out_12   => port_out_12_TB,
              port_out_13   => port_out_13_TB,
              port_out_14   => port_out_14_TB,
              port_out_15   => port_out_15_TB,
              port_in_00    => rx_sig,
              port_in_01    => port_in_01_TB,
              port_in_02    => port_in_02_TB,
              port_in_03    => port_in_03_TB,
              port_in_04    => port_in_04_TB,
              port_in_05    => port_in_05_TB,
              port_in_06    => port_in_06_TB,
              port_in_07    => port_in_07_TB,
              port_in_08    => x"30",
              port_in_09    => x"30",
              port_in_10    => x"38",
              port_in_11    => x"38",
              port_in_12    => x"34",
              port_in_13    => x"60",
              port_in_14    => x"56",
              port_in_15    => x"55",
              cpu_exception => cpu_exception,
              interrupt     => interrupt_TB,
              interrupt_clr => interrupt_clr);

-----------------------------------------------
  HEADER : process
  begin
    report "8-Bit Microcomputer System Test Bench Initiating..." severity note;
    wait;
  end process;
-----------------------------------------------
  CLOCK_STIM : process
  begin
    clock_TB <= '0'; wait for 0.5*t_clk_per;
    clock_TB <= '1'; wait for 0.5*t_clk_per;
  end process;
-----------------------------------------------
  RESET_STIM : process
  begin
    reset_TB <= '1'; wait for 0.25*t_clk_per;
    reset_TB <= '0'; wait;
  end process;
-----------------------------------------------
--int_clr : process(interrupt_clr)
--    begin
--    if(interrupt_clr = '1') then
--      interrupt_TB <= "0000";
--    end if;
--    end process;

  rx_sig_proc : process (clock_TB)
  begin
    if(rising_edge(clock_TB)) then
      if(rx_sig >= "11111111") then
        rx_sig <= (others => '0');
      else
        rx_sig <= rx_sig +1;
      end if;
    end if;
  end process;

  int_proc : process(clock_TB)
  begin
    if(rising_edge(clock_TB)) then
      if(interrupt_clr = '1') then
        interrupt_TB <= "0000";
      else
        if(int_cnt >= "111111") then
          interrupt_TB <= "0001";
          int_cnt      <= (others => '0');
        else
          int_cnt <= int_cnt + 1;
        end if;
      end if;
    end if;
  end process;
end architecture;
