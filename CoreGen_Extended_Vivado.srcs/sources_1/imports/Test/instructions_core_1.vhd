library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
package instructions_core_1 is 
 
 constant LDA_IMM : std_logic_vector (7 downto 0) :=x"c3"; 
 constant LDA_DIR : std_logic_vector (7 downto 0) :=x"64"; 
 constant STA_DIR : std_logic_vector (7 downto 0) :=x"ac"; 
 constant BRA     : std_logic_vector (7 downto 0) :=x"a4"; 
 
 end package instructions_core_1;