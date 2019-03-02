library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_unsigned.all;


entity char_driver is
  port (
    clk         : in  std_logic;
    reset       : in  std_logic;
    bin_in      : in  std_logic_vector(15 downto 0);
    anode_sel   : out  std_logic_vector(3 downto 0);
    led_display : out std_logic_vector(6 downto 0)
    );
end char_driver;

architecture Behavioral of char_driver is

-- Signals
  -- Creates 10.5 ms refresh period
  signal refresh_counter                : std_logic_vector(19 downto 0);
  --signal bin_in                         : std_logic_vector(15 downto 0);
  signal activating_counter             : std_logic_vector(1 downto 0);
  signal char_1, char_2, char_3, char_4 : std_logic_vector(3 downto 0);
  signal disp_1, disp_2, disp_3, disp_4 : std_logic_vector(6 downto 0);
-- Component
  component char_decoder is
    port (
      char_in     : in  std_logic_vector(3 downto 0);
      led_display : out std_logic_vector(6 downto 0)
      );
  end component;

begin

------------------------------------
--   -       -       -       -    --
--  | |     | |     | |     | |   --
--   -       -       -       -    --
--  | |     | |     | |     | |   --
--   -       -       -       -    --
-- Char_1  Char_2  Char_3  Char_4 --
------------------------------------
--bin_in <= "0001001000110101";
  char_1 <= bin_in(15 downto 12);
  char_2 <= bin_in(11 downto 8);
  char_3 <= bin_in(7 downto 4);
  char_4 <= bin_in(3 downto 0);

--char_1 <= "0001";
--char_2 <= "0010";
--char_3 <= "0011";
--char_4 <= "0100";

  char_1_decoder: char_decoder  port map
    (char_in => char_1,
     led_display => disp_1);
  
  char_2_decoder: char_decoder  port map
    (char_in => char_2,
     led_display => disp_2);
  
  char_3_decoder: char_decoder  port map
    (char_in => char_3,
     led_display => disp_3);
  
  char_4_decoder: char_decoder  port map
    (char_in => char_4,
     led_display => disp_4);
  
  refresh_rate : process(clk, reset)
  begin
    if(reset = '1') then
      refresh_counter <= (others => '0');
    elsif(rising_edge(clk))then
      refresh_counter <= refresh_counter + 1;
    end if;
  end process;
  activating_counter <= refresh_counter(19 downto 18);

  display: process(activating_counter)
  begin
    case activating_counter is
      when "00" =>
        anode_sel <= "0111";
        led_display <= disp_1;
      when "01" =>
        anode_sel <= "1011";
        led_display <= disp_2;
      when "10" =>
        anode_sel <= "1101";
        led_display <= disp_3;
      when "11" =>
        anode_sel <= "1110";
        led_display <= disp_4;
    end case;
  end process;
end Behavioral;
