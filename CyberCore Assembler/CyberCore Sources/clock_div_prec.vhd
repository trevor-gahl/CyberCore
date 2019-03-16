library IEEE;
use iEEE.STD_LOGIC_1164.all;


entity clock_div_prec is
  port (Clock_in  : in  std_logic;
        Reset     : in  std_logic;
        Sel       : in  std_logic_vector (1 downto 0);
        Clock_out : out std_logic);
end entity;

architecture clock_div_prec_arch of clock_div_prec is


  signal counter    : integer;
  signal clock_temp : std_logic;


begin


  clock_div_prec_process : process(Clock_In, reset)
  begin
    if(reset = '1') then
      counter    <= 0;
      clock_temp <= '0';
    elsif(rising_edge(Clock_In)) then
      counter <= counter + 1;

      case(Sel) is
        when "00" =>
          if (counter >= 25000000) then
            clock_temp <= not clock_temp;
            counter    <= 0;
          end if;
        when "01" =>
          if (counter >= 2500000) then
            clock_temp <= not clock_temp;
            counter    <= 0;
          end if;
        when "10" =>
          if (counter >= 2) then
            clock_temp <= not clock_temp;
            counter    <= 0;
          end if;
        when "11" =>
          if (counter >= 25000) then
            clock_temp <= not clock_temp;
            counter    <= 0;
          end if;
        when others => clock_temp <= clock_temp;
      end case;
    end if;
  end process;
  Clock_out <= clock_temp;



end architecture;
