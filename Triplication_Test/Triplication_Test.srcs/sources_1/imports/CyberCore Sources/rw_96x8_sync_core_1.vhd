library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity rw_96x8_sync_core_1 is
  port (address  : in  std_logic_vector (7 downto 0);
        clock    : in  std_logic;
        data_out : out std_logic_vector (7 downto 0);
        data_in  : in  std_logic_vector (7 downto 0);
        write    : in  std_logic);
end entity;

architecture rw_96x8_sync_arch of rw_96x8_sync_core_1 is

  type rw_type is array (128 to 199) of std_logic_vector(7 downto 0);
  signal RW : rw_type;
  signal EN : std_logic;

begin
-- RW enables and memory
  enable : process(address)
  begin
    if((to_integer(unsigned(address)) >= 128) and
       (to_integer(unsigned(address)) <= 199)) then
      EN <= '1';
    else
      EN <= '0';
    end if;
  end process;

  memory1 : process(clock)
  begin
    if(clock'event and clock = '1') then
      if(EN = '1' and write = '1') then
        RW(to_integer(unsigned(address))) <= data_in;
      elsif (EN = '1' and write = '0') then
        data_out <= RW(to_integer(unsigned(address)));
      end if;
    end if;
  end process;

end architecture;
