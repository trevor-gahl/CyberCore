library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library xil_defaultlib;
use xil_defaultlib.instructions_core_3.all;

entity rom_128x8_sync_core_3 is
  port (address  : in  std_logic_vector (7 downto 0);
        clock    : in  std_logic;
        data_out : out std_logic_vector (7 downto 0));
end entity;

architecture rom_128x8_sync_arch of rom_128x8_sync_core_3 is

-- Declaring constants for later use
--constant LDA_IMM : std_logic_vector (7 downto 0) :=x"87";
--constant LDA_DIR : std_logic_vector (7 downto 0) :=x"88";
--constant STA_DIR : std_logic_vector (7 downto 0) :=x"89";
--constant BRA   : std_logic_vector (7 downto 0) :=x"21";
--constant PSH : std_logic_vector (7 downto 0) := x"23";

  signal EN : std_logic;

  type rom_type is array (0 to 95) of std_logic_vector(7 downto 0);

  constant ROM : rom_type := (
    0 => LDA_IMM,
    1 => x"01",
    2 => INC_A,
    3 => INC_A,
    4 => BRA,
    5 => x"00",

    50 => LDA_IMM,
    51 => x"01",  -- Start of Illegal Opcode Fault. Pushes A, B, and PC to Stack
    52 => STA_DIR,
    53 => x"E0",
    54 => RTI,

    66 => LDA_IMM,                      -- UART Interrupt
    67 => x"F0",
    68 => STA_DIR,
    69 => x"60",
    70 => CLI,
    71 => RTI,

    others => x"00");
--
begin
--enables ROM and port_outs
  enable : process(address)
  begin
    if ((to_integer(unsigned(address)) >= 0) and
        (to_integer(unsigned(address)) <= 95)) then
      EN <= '1';
    else
      EN <= '0';
    end if;
  end process;

  memory : process(clock)
  begin
    if (clock'event and clock = '1') then
      if (EN = '1') then
        data_out <= ROM(to_integer(unsigned(address)));
      end if;
    end if;
  end process;
end architecture;
