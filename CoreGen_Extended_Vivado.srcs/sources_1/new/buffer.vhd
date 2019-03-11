----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/08/2019 01:56:51 PM
-- Design Name: 
-- Module Name: buffer - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_buffer is
  Port (address : in std_logic_vector(2 downto 0);
        write   : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
  );
end uart_buffer;

architecture Behavioral of uart_buffer is

type buff_type is array (0 to 7) of std_logic_vector(7 downto 0);

signal buffer_array : buff_type;

begin

buffer1 : process(address)
begin
    if(write = '1') then
      buffer_array(to_integer(unsigned(address))) <= data_in;
    elsif(write = '0') then
      data_out <= buffer_array(to_integer(unsigned(address)));
    end if;
end process;

end Behavioral;

