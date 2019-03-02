library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library xil_defaultlib;
use xil_defaultlib.instructions_core_1.all;

entity alu_core_1 is
  port (ALU_Sel    : in  std_logic_vector (2 downto 0);
        A          : in  std_logic_vector (7 downto 0);
        B          : in  std_logic_vector (7 downto 0);
        ALU_Result : out std_logic_vector (7 downto 0);
        NZVC       : out std_logic_vector (3 downto 0));
end entity;

architecture alu_arch of alu_core_1 is

begin
  ALU_PROCESS : process (A, B, ALU_Sel)

    variable Sum_uns : unsigned(8 downto 0);
--      variable Sub_uns : unsigned(8 downto 0);

  begin
    if (ALU_Sel = add) then             -- ADDITION
-- Sum Calc
      Sum_uns    := unsigned('0'&A) + unsigned('0'&B);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
-- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
-- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
-- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
-- Carry (C)
      NZVC(0) <= Sum_uns(8);
    end if;

    if(ALU_Sel = sub) then
      Sum_uns    := unsigned('0'&A) - unsigned('0'&B);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
      -- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      -- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
      -- Carry (C)
      NZVC(0) <= Sum_uns(8);
    end if;

    if(ALU_Sel = andab) then
      Sum_uns    := unsigned('0'&A) and unsigned('0'&B);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

      -- Negative Flag (N)
      NZVC(3) <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      NZVC(1) <= '0';
      NZVC(0) <= '0';
    end if;

    if (ALU_Sel = orrab) then
      Sum_uns    := unsigned('0'&A) or unsigned('0'&B);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));

      -- Negative Flag (N)
      NZVC(3) <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      NZVC(1) <= '0';
      NZVC(0) <= '0';
    end if;

    if (ALU_Sel = inca) then
      Sum_uns    := unsigned('0'&A) + to_unsigned(1, 8);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
      -- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      -- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
      -- Carry (C)
    NZVC(0) <= Sum_uns(8);
    end if;

    if (ALU_Sel = deca) then
      Sum_uns    := unsigned('0'&A) - to_unsigned(1, 8);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
      -- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      -- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
      -- Carry (C)
      NZVC(0) <= Sum_uns(8);
    end if;

    if (ALU_Sel = incb) then
      Sum_uns    := unsigned('0'&B) + to_unsigned(1, 8);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
      -- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      -- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
      -- Carry (C)
      NZVC(0) <= Sum_uns(8);
    end if;

    if (ALU_Sel = decb) then
      Sum_uns    := unsigned('0'&B) - to_unsigned(1, 8);
      ALU_Result <= std_logic_vector(Sum_uns(7 downto 0));
      -- Negative Flag (N)
      NZVC(3)    <= Sum_uns(7);
      -- Zero Flag (Z)
      if (Sum_uns(7 downto 0) = x"00") then
        NZVC(2) <= '1';
      else
        NZVC(2) <= '0';
      end if;
      -- Overflow Flag (V)
      if ((A(7) = '0' and B(7) = '0' and Sum_uns(7) = '1') or
          (A(7) = '1' and B(7) = '1' and Sum_uns(7) = '0')) then
        NZVC(1) <= '1';
      else
        NZVC(1) <= '0';
      end if;
      -- Carry (C)
      NZVC(0) <= Sum_uns(8);
    end if;
  end process;
end architecture;
