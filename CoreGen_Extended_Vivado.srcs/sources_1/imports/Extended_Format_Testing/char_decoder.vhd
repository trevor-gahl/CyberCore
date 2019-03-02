library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity char_decoder is
  port (bin_in        : in  std_logic_vector(3 downto 0);
        seven_seg_out : out std_logic_vector(6 downto 0));
end char_decoder;

architecture Behavioral of char_decoder is

begin
  process (bin_in)
  begin
    case (bin_in) is
      when x"0" => seven_seg_out <= "1000000";
      when x"1" => seven_seg_out <= "1111001";
      when x"2" => seven_seg_out <= "0100100";
      when x"3" => seven_seg_out <= "0110000";

      when x"4" => seven_seg_out <= "0011001";
      when x"5" => seven_seg_out <= "0010010";
      when x"6" => seven_seg_out <= "0000010";
      when x"7" => seven_seg_out <= "1111000";

      when x"8" => seven_seg_out <= "0000000";
      when x"9" => seven_seg_out <= "0010000";
      when x"a" => seven_seg_out <= "0001000";
      when x"b" => seven_seg_out <= "0000011";

      when x"c" => seven_seg_out <= "0100111";
      when x"d" => seven_seg_out <= "0100001";
      when x"e" => seven_seg_out <= "0000110";
      when x"f" => seven_seg_out <= "0001110";

      when others => seven_seg_out <= "1011100";
    end case;
  end process;
end Behavioral;
