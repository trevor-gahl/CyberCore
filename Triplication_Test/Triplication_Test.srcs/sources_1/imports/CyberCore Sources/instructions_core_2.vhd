library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package instructions_core_2 is


-----------------------------
-- INSTRUCTION SET OPCODES --
-----------------------------
constant LDA_IMM : std_logic_vector (7 downto 0) := x"30";  -- Loads an immediate value into register A
  constant LDB_IMM : std_logic_vector (7 downto 0) := x"31";  -- Loads an immediate value into register B
  constant LDA_DIR : std_logic_vector (7 downto 0) := x"32";  -- Directly loads a desired register into register A
  constant LDB_DIR : std_logic_vector (7 downto 0) := x"33";  -- Directly loads a desired register into register B
  constant STA_DIR : std_logic_vector (7 downto 0) := x"34";  -- Directly stores value in register A to desired location
  constant STB_DIR : std_logic_vector (7 downto 0) := x"35";  -- Directly stores value in register B to desired location
  constant ADD_AB  : std_logic_vector (7 downto 0) := x"36";  -- Adds values of register A and register B
  constant SUB_AB  : std_logic_vector (7 downto 0) := x"37";  -- Subtracts registers A and B
  constant INC_A   : std_logic_vector (7 downto 0) := x"38";  -- Increments the value in register A
  constant DEC_A   : std_logic_vector (7 downto 0) := x"39";  -- Decrements the value in register A
  constant INC_B   : std_logic_vector (7 downto 0) := x"40";  -- Increments the value in register B
  constant DEC_B   : std_logic_vector (7 downto 0) := x"41";  -- Decrements the value in register B
  constant AND_AB  : std_logic_vector (7 downto 0) := x"42";  -- Ands the values of A and B
  constant ORR_AB  : std_logic_vector (7 downto 0) := x"43";  -- Ors the values of A and B
  constant BRA     : std_logic_vector (7 downto 0) := x"44";  -- Branches to desired memory location
  constant BMI     : std_logic_vector (7 downto 0) := x"45";  -- Branches to desired memory location if negative (N Flag)
  constant BEQ     : std_logic_vector (7 downto 0) := x"46";  -- Branches to desired memory location if zero     (Z Flag)
  constant BCS     : std_logic_vector (7 downto 0) := x"47";  -- Branches to desired memory location if carry    (C Flag)
  constant BVS     : std_logic_vector (7 downto 0) := x"48";  -- Branches to desired memory location if overflow (V Flag)
  constant PSH_A   : std_logic_vector (7 downto 0) := x"49";  -- Pushes value from A onto the stack
  constant PSH_B   : std_logic_vector (7 downto 0) := x"50";  -- Pushes value from B onto the stack
  constant PSH_PC  : std_logic_vector (7 downto 0) := x"51";  -- Only used for interrupt vector, pushes program counter onto stack
  constant PLL_A   : std_logic_vector (7 downto 0) := x"52";  -- Pulls top value off stack into register A
  constant PLL_B   : std_logic_vector (7 downto 0) := x"53";  -- Pulls top value off stack into register B
  constant PLL_PC  : std_logic_vector (7 downto 0) := x"54";  -- Only used for interrupt vector, pulls program counter off of stack
  constant RTI     : std_logic_vector (7 downto 0) := x"55";  -- Returns from interrupt
  constant CLI     : std_logic_vector (7 downto 0) := x"56";  -- Clears interrupt from processor
  constant STI     : std_logic_vector (7 downto 0) := x"57";  -- Starts interrupt (For testing only)
--  constant LDA_IMM : std_logic_vector (7 downto 0) := x"32";  -- Loads an immediate value into register A
--  constant LDB_IMM : std_logic_vector (7 downto 0) := x"33";  -- Loads an immediate value into register B
--  constant LDA_DIR : std_logic_vector (7 downto 0) := x"34";  -- Directly loads a desired register into register A
--  constant LDB_DIR : std_logic_vector (7 downto 0) := x"35";  -- Directly loads a desired register into register B
--  constant STA_DIR : std_logic_vector (7 downto 0) := x"36";  -- Directly stores value in register A to desired location
--  constant STB_DIR : std_logic_vector (7 downto 0) := x"37";  -- Directly stores value in register B to desired location
--  constant ADD_AB  : std_logic_vector (7 downto 0) := x"38";  -- Adds values of register A and register B
--  constant SUB_AB  : std_logic_vector (7 downto 0) := x"39";  -- Subtracts registers A and B
--  constant INC_A   : std_logic_vector (7 downto 0) := x"40";  -- Increments the value in register A
--  constant DEC_A   : std_logic_vector (7 downto 0) := x"41";  -- Decrements the value in register A
--  constant INC_B   : std_logic_vector (7 downto 0) := x"42";  -- Increments the value in register B
--  constant DEC_B   : std_logic_vector (7 downto 0) := x"43";  -- Decrements the value in register B
--  constant AND_AB  : std_logic_vector (7 downto 0) := x"44";  -- Ands the values of A and B
--  constant ORR_AB  : std_logic_vector (7 downto 0) := x"45";  -- Ors the values of A and B
--  constant BRA     : std_logic_vector (7 downto 0) := x"46";  -- Branches to desired memory location
--  constant BMI     : std_logic_vector (7 downto 0) := x"47";  -- Branches to desired memory location if negative (N Flag)
--  constant BEQ     : std_logic_vector (7 downto 0) := x"48";  -- Branches to desired memory location if zero     (Z Flag)
--  constant BCS     : std_logic_vector (7 downto 0) := x"49";  -- Branches to desired memory location if carry    (C Flag)
--  constant BVS     : std_logic_vector (7 downto 0) := x"50";  -- Branches to desired memory location if overflow (V Flag)
--  constant PSH_A   : std_logic_vector (7 downto 0) := x"51";  -- Pushes value from A onto the stack
--  constant PSH_B   : std_logic_vector (7 downto 0) := x"52";  -- Pushes value from B onto the stack
--  constant PSH_PC  : std_logic_vector (7 downto 0) := x"53";  -- Only used for interrupt vector, pushes program counter onto stack
--  constant PLL_A   : std_logic_vector (7 downto 0) := x"54";  -- Pulls top value off stack into register A
--  constant PLL_B   : std_logic_vector (7 downto 0) := x"55";  -- Pulls top value off stack into register B
--  constant PLL_PC  : std_logic_vector (7 downto 0) := x"56";  -- Only used for interrupt vector, pulls program counter off of stack
--  constant RTI     : std_logic_vector (7 downto 0) := x"57";  -- Returns from interrupt
--  constant CLI     : std_logic_vector (7 downto 0) := x"58";  -- Clears interrupt from processor
--  constant STI     : std_logic_vector (7 downto 0) := x"59";  -- Starts interrupt (For testing only)

--------------------
-- ALU SELECTIONS --
--------------------

  constant add   : std_logic_vector (2 downto 0) := "000";
  constant sub   : std_logic_vector (2 downto 0) := "001";
  constant andab : std_logic_vector (2 downto 0) := "010";
  constant orrab : std_logic_vector (2 downto 0) := "011";
  constant inca  : std_logic_vector (2 downto 0) := "100";
  constant deca  : std_logic_vector (2 downto 0) := "101";
  constant incb  : std_logic_vector (2 downto 0) := "110";
  constant decb  : std_logic_vector (2 downto 0) := "111";

end package instructions_core_2;
