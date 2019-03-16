library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

entity cpu_core_3 is
  port (
    write         : out std_logic;
    reset         : in  std_logic;
    clock         : in  std_logic;
    from_memory   : in  std_logic_vector (7 downto 0);
    interrupt     : in  std_logic_vector (3 downto 0);
    interrupt_clr : out std_logic;
    to_memory     : out std_logic_vector (7 downto 0);
    address       : out std_logic_vector (7 downto 0);
    cpu_exception : out std_logic
    );
end entity;

architecture cpu_arch of cpu_core_3 is

  component data_path_core_3
    port (
      IR_Load       : in  std_logic;
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
      interrupt     : in  std_logic_vector (3 downto 0);
      fault_trigger : in  std_logic_vector (3 downto 0);
      to_memory     : out std_logic_vector (7 downto 0);
      IR            : out std_logic_vector (7 downto 0);
      address       : out std_logic_vector (7 downto 0);
      CCR_Result    : out std_logic_vector (3 downto 0)
      );
  end component;

  component control_unit_core_3
    port (
      IR_Load       : out std_logic;
      MAR_Load      : out std_logic;
      PC_Load       : out std_logic;
      PC_Inc        : out std_logic;
      SP_Enable     : out std_logic;
      SP_Inc        : out std_logic;
      SP_Dec        : out std_logic;
      A_Load        : out std_logic;
      B_Load        : out std_logic;
      ALU_Sel       : out std_logic_vector (2 downto 0);
      CCR_Load      : out std_logic;
      Bus2_Sel      : out std_logic_vector (1 downto 0);
      Bus1_Sel      : out std_logic_vector (1 downto 0);
      write         : out std_logic;
      cpu_exception : out std_logic;
      illegal_op    : out std_logic;
      fault_trigger : out std_logic_vector (3 downto 0);
      interrupt_clr : out std_logic;
      interrupt     : in  std_logic_vector (3 downto 0);
      reset         : in  std_logic;
      clock         : in  std_logic;
      IR            : in  std_logic_vector (7 downto 0);
      CCR_Result    : in  std_logic_vector (3 downto 0)
      );
  end component;

  signal IR            : std_logic_vector (7 downto 0);
  signal ALU_Sel       : std_logic_vector(2 downto 0);
  signal CCR_Result    : std_logic_vector(3 downto 0);
  signal Bus2_Sel      : std_logic_vector (1 downto 0);
  signal Bus1_Sel      : std_logic_vector (1 downto 0);
  signal PC_Load       : std_logic;
  signal PC_Inc        : std_logic;
  signal A_Load        : std_logic;
  signal B_Load        : std_logic;
  signal CCR_Load      : std_logic;
  signal MAR_Load      : std_logic;
  signal IR_Load       : std_logic;
  signal illegal_op    : std_logic;
  signal SP_Enable     : std_logic;
  signal SP_Inc        : std_logic;
  signal SP_Dec        : std_logic;
  signal fault_trigger : std_logic_vector(3 downto 0);

begin

  data_path3 : data_path_core_3
    port map (clock         => clock,
              reset         => reset,
              IR_Load       => IR_Load,
              IR            => IR,
              MAR_Load      => MAR_Load,
              PC_Load       => PC_Load,
              PC_Inc        => PC_Inc,
              SP_Enable     => SP_Enable,
              SP_Inc        => SP_Inc,
              SP_Dec        => SP_Dec,
              A_Load        => A_Load,
              B_Load        => B_Load,
              ALU_Sel       => ALU_Sel,
              CCR_Result    => CCR_Result,
              CCR_Load      => CCR_Load,
              Bus2_Sel      => Bus2_Sel,
              Bus1_Sel      => Bus1_Sel,
              fault_trigger => fault_trigger,
              interrupt     => interrupt,
              to_memory     => to_memory,
              from_memory   => from_memory,
              illegal_op    => illegal_op,
              address       => address);

  control_unit3 : control_unit_core_3
    port map (clock         => clock,
              reset         => reset,
              IR_Load       => IR_Load,
              IR            => IR,
              MAR_Load      => MAR_Load,
              PC_Load       => PC_Load,
              PC_Inc        => PC_Inc,
              SP_Enable     => SP_Enable,
              SP_Inc        => SP_Inc,
              SP_Dec        => SP_Dec,
              A_Load        => A_Load,
              B_Load        => B_Load,
              ALU_Sel       => ALU_Sel,
              CCR_Result    => CCR_Result,
              CCR_Load      => CCR_Load,
              Bus2_Sel      => Bus2_Sel,
              Bus1_Sel      => Bus1_Sel,
              fault_trigger => fault_trigger,
              interrupt     => interrupt,
              interrupt_clr => interrupt_clr,
              write         => write,
              cpu_exception => cpu_exception,
              illegal_op    => illegal_op);

end architecture;
