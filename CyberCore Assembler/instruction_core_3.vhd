library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
package instructions_core_3 is 
 constant LDA_IMM : std_logic_vector (7 downto 0) :=x"99"; 
 constant LDB_IMM : std_logic_vector (7 downto 0) :=x"8a"; 
 constant LDA_DIR : std_logic_vector (7 downto 0) :=x"4e"; 
 constant LDB_DIR : std_logic_vector (7 downto 0) :=x"b6"; 
 constant STA_DIR : std_logic_vector (7 downto 0) :=x"78"; 
 constant STB_DIR : std_logic_vector (7 downto 0) :=x"c3"; 
 constant ADD_AB  : std_logic_vector (7 downto 0) :=x"c1"; 
 constant SUB_AB  : std_logic_vector (7 downto 0) :=x"66"; 
 constant INC_A   : std_logic_vector (7 downto 0) :=x"6a"; 
 constant DEC_A   : std_logic_vector (7 downto 0) :=x"b9"; 
 constant INC_B   : std_logic_vector (7 downto 0) :=x"13"; 
 constant DEC_B   : std_logic_vector (7 downto 0) :=x"b2"; 
 constant AND_AB  : std_logic_vector (7 downto 0) :=x"85"; 
 constant ORR_AB  : std_logic_vector (7 downto 0) :=x"77"; 
 constant BRA     : std_logic_vector (7 downto 0) :=x"ac"; 
 constant BMI     : std_logic_vector (7 downto 0) :=x"d3"; 
 constant BEQ     : std_logic_vector (7 downto 0) :=x"a2"; 
 constant BCS     : std_logic_vector (7 downto 0) :=x"69"; 
 constant BVS     : std_logic_vector (7 downto 0) :=x"2a"; 
 constant PSH_A   : std_logic_vector (7 downto 0) :=x"c8"; 
 constant PSH_B   : std_logic_vector (7 downto 0) :=x"15"; 
 constant PSH_PC  : std_logic_vector (7 downto 0) :=x"2c"; 
 constant PLL_A   : std_logic_vector (7 downto 0) :=x"a5"; 
 constant PLL_B   : std_logic_vector (7 downto 0) :=x"59"; 
 constant PLL_PC  : std_logic_vector (7 downto 0) :=x"72"; 
 constant RTI     : std_logic_vector (7 downto 0) :=x"24"; 
 constant STI     : std_logic_vector (7 downto 0) :=x"d2"; 
 constant add     : std_logic_vector (7 downto 0) :="000"; 
 constant sub     : std_logic_vector (7 downto 0) :="001"; 
 constant andab   : std_logic_vector (7 downto 0) :="010"; 
 constant orrab   : std_logic_vector (7 downto 0) :="011"; 
 constant inca    : std_logic_vector (7 downto 0) :="100"; 
 constant deca    : std_logic_vector (7 downto 0) :="101"; 
 constant incb    : std_logic_vector (7 downto 0) :="110"; 
 constant decb    : std_logic_vector (7 downto 0) :="111"; 
 end package instructions_core_3;