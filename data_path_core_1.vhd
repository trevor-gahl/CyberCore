library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity data_path_core_1 is
  port (IR_Load       : in  std_logic;
        MAR_Load      : in  std_logic;
        PC_Load       : in  std_logic;
        PC_Inc        : in  std_logic;
        SP_Enable     : in  std_logic;
        SP_Inc        : in  std_logic;
        SP_Dec        : in  std_logic;
        A_Load        : in  std_logic;
        B_Load        : in  std_logic;
        ALU_Sel       : in  std_logic_vector (2 downto 0);
        CCR_Load      : in  std_logic;
        Bus2_Sel      : in  std_logic_vector (1 downto 0);
        Bus1_Sel      : in  std_logic_vector (1 downto 0);
        reset         : in  std_logic;
        clock         : in  std_logic;
        from_memory   : in  std_logic_vector (7 downto 0);
        illegal_op    : in  std_logic;
        fault_trigger : in  std_logic_vector (3 downto 0);
        interrupt     : in  std_logic_vector (3 downto 0);
        to_memory     : out std_logic_vector (7 downto 0);
        IR            : out std_logic_vector (7 downto 0);
        address       : out std_logic_vector (7 downto 0);
        CCR_Result    : out std_logic_vector (3 downto 0));
end entity;

architecture data_path_arch of data_path_core_1 is

  component alu_core_1
    port (ALU_Sel    : in  std_logic_vector (2 downto 0);
          A          : in  std_logic_vector (7 downto 0);
          B          : in  std_logic_vector (7 downto 0);
          ALU_Result : out std_logic_vector (7 downto 0);
          NZVC       : out std_logic_vector (3 downto 0));
  end component;

-- signal assignments
  signal BUS2             : std_logic_vector(7 downto 0);
  signal BUS1             : std_logic_vector(7 downto 0);
  signal A                : std_logic_vector(7 downto 0);
  signal B                : std_logic_vector(7 downto 0);
  signal PC               : std_logic_vector(7 downto 0);
  signal MAR              : std_logic_vector(7 downto 0);
  signal IR_Sig           : std_logic_vector(7 downto 0);
  signal CCR              : std_logic_vector(3 downto 0);
  signal ALU_Result       : std_logic_vector(7 downto 0);
  signal PC_uns           : unsigned (7 downto 0);
  signal NZVC             : std_logic_vector(3 downto 0);
  signal SP               : std_logic_vector(7 downto 0) := x"C8";
  signal SP_uns           : unsigned (7 downto 0)        := x"C8";
  signal Fault_Vector     : std_logic_vector(7 downto 0);
  signal Interrupt_Vector : std_logic_vector(7 downto 0);

begin

  ALU0 : alu_core_1 port map (
    ALU_Sel    => ALU_Sel,
    A          => A,
    B          => B,
    NZVC       => NZVC,
    ALU_Result => ALU_Result);

  FAULT_VECTOR0 : process (fault_trigger)
  begin
    case (fault_trigger) is
      when "0001" => Fault_Vector <= x"32";
      when others => Fault_Vector <= x"00";
    end case;
  end process;

  INTERRUPT_VECTOR0 : process (interrupt)
  begin
    case (interrupt) is
      when "0001" => Interrupt_Vector <= x"42";
      when "0010" => Interrupt_Vector <= x"52";
      when others => Interrupt_Vector <= x"00";
    end case;
  end process;

  MUX_BUS1 : process (Bus1_Sel, PC, A, B)
  begin
    case (Bus1_Sel) is
      when "00"   => Bus1 <= PC;
      when "01"   => Bus1 <= A;
      when "10"   => Bus1 <= B;
      when others => Bus1 <= x"00";
    end case;
  end process;

  MUX_BUS2 : process (Bus2_Sel, ALU_Result, Bus1, from_memory)
  begin
    case (Bus2_Sel) is
      when "00" => Bus2 <= ALU_Result;
      when "01" => Bus2 <= Bus1;
      when "10" => Bus2 <= from_memory;
      when "11" =>
        if(illegal_op = '1') then
          Bus2 <= Fault_Vector;
        else
          Bus2 <= Interrupt_Vector;
        end if;
      when others => Bus2 <= x"00";
    end case;
  end process;

  address   <= MAR;
  to_memory <= Bus1;

  INSTRUCTION_REGISTER : process (clock, reset)
  begin
    if (Reset = '1') then
      IR <= x"00";
    elsif (clock'event and clock = '1') then
      if (IR_Load = '1') then
        IR <= Bus2;
      end if;
    end if;
  end process;

  MEMORY_ADDRESS_REGISTER : process (clock, reset)
  begin
    if (Reset = '1') then
      MAR <= x"00";
    elsif (clock'event and clock = '1') then
      if (MAR_Load = '1' and SP_Enable = '0') then
        MAR <= Bus2;
      elsif (MAR_Load = '1' and SP_Enable = '1') then
        MAR <= SP;
      end if;
    end if;
  end process;

  PROGRAM_COUNTER : process (clock, reset)
  begin
    if (reset = '1') then
      PC_uns <= x"00";
    elsif (clock'event and clock = '1') then
      if (PC_Load = '1') then
        PC_uns <= unsigned(Bus2);
      elsif (PC_Inc = '1') then
        PC_uns <= PC_uns+1;
      end if;
    end if;
  end process;
  PC <= std_logic_vector(PC_uns);

  A_REGISTER : process (clock, reset)
  begin
    if (reset = '1') then
      A <= x"00";
    elsif (clock'event and clock = '1') then
      if (A_Load = '1') then
        A <= Bus2;
      end if;
    end if;
  end process;

  B_REGISTER : process (clock, reset)
  begin
    if (reset = '1') then
      B <= x"00";
    elsif (clock'event and clock = '1') then
      if (B_Load = '1') then
        B <= Bus2;
      end if;
    end if;
  end process;

  CONDITION_CODE_REGISTER : process (clock, reset)
  begin
    if (reset = '1') then
      CCR_Result <= x"0";
    elsif (clock'event and clock = '1') then
      if (CCR_Load = '1') then
        CCR_Result <= NZVC;
      end if;
    end if;
  end process;

  STACK_POINTER : process (clock, reset)
  begin
    if (reset = '1') then
      SP_uns <= x"C8";
    elsif(clock'event and clock = '1') then
      if (SP_Enable = '1') then
        if(SP_Inc = '1') then
          SP_uns <= SP_uns +1;
        elsif(SP_Dec = '1') then
          SP_uns <= SP_uns -1;
        end if;
      end if;
    end if;
  end process;
  SP <= std_logic_vector(SP_uns);
end architecture;
