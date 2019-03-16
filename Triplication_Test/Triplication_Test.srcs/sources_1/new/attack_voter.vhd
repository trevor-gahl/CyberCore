library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity attack_voter is
  port (
        core_1_val  : in std_logic_vector(7 downto 0);
        core_2_val  : in std_logic_vector(7 downto 0);
        core_3_val  : in std_logic_vector(7 downto 0);
        output_val  : out std_logic_vector(7 downto 0)
   );
end attack_voter;

architecture Behavioral of attack_voter is

begin

voter: process(core_1_val, core_2_val, core_3_val)
begin

if(core_1_val = core_2_val and core_2_val = core_3_val) then
  output_val <= core_1_val;
else
  output_val <= "10101010";
end if;
end process;

end Behavioral;
