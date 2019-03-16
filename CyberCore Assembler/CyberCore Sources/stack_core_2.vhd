library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity stack_core_2 is
  port (address  : in  std_logic_vector (7 downto 0);
        clock    : in  std_logic;
        data_out : out std_logic_vector (7 downto 0);
        data_in  : in  std_logic_vector (7 downto 0);
        write    : in  std_logic);
end entity;

architecture Behavioral of stack_core_2 is

  type stack is array (200 to 255) of std_logic_vector(7 downto 0);
  signal stack_value : stack;
  signal EN          : std_logic;

begin
-- RW enables and memory
  enable_stack : process(address)
  begin
    if((to_integer(unsigned(address)) >= 200) and
       (to_integer(unsigned(address)) <= 255)) then
      EN <= '1';
    else
      EN <= '0';
    end if;
  end process;

  stack_core_2 : process(clock)
  begin
    if(clock'event and clock = '1') then
      if(EN = '1' and write = '1') then
        stack_value(to_integer(unsigned(address))) <= data_in;
      elsif (EN = '1' and write = '0') then
        data_out <= stack_value(to_integer(unsigned(address)));
      end if;
    end if;
  end process;

end Behavioral;
