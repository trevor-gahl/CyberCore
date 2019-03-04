library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
library xil_defaultlib;
use xil_defaultlib.instructions_core_1.all;

entity control_unit_core_1 is
  port (
    IR_Load       : out std_logic;
    MAR_Load      : out std_logic;
    PC_Load       : out std_logic;
    PC_Inc        : out std_logic;
    A_Load        : out std_logic;
    B_Load        : out std_logic;
    ALU_Sel       : out std_logic_vector (2 downto 0);
    CCR_Load      : out std_logic;
    Bus2_Sel      : out std_logic_vector (1 downto 0);
    Bus1_Sel      : out std_logic_vector (1 downto 0);
    write         : out std_logic;
    cpu_exception : out std_logic;
    SP_Inc        : out std_logic;
    SP_Dec        : out std_logic;
    SP_Enable     : out std_logic;
    illegal_op    : out std_logic;
    interrupt_clr : out std_logic;
    fault_trigger : out std_logic_vector(3 downto 0);
    interrupt     : in  std_logic_vector(3 downto 0);
    reset         : in  std_logic;
    clock         : in  std_logic;
    IR            : in  std_logic_vector (7 downto 0);
    CCR_Result    : in  std_logic_vector (3 downto 0)
    );
end entity;

architecture control_unit_arch of control_unit_core_1 is

-- Type declration
  type state_type is(
    -- Fetches opcodes from memory
    S_FETCH_0, S_FETCH_1, S_FETCH_2,

    -- Decodes opcodes
    S_DECODE_3,

    -- Load A Immediate
    S_LDA_IMM_4, S_LDA_IMM_5, S_LDA_IMM_6,

    -- Load A Direct
    S_LDA_DIR_4, S_LDA_DIR_5, S_LDA_DIR_6, S_LDA_DIR_7, S_LDA_DIR_8,

    -- Store A Direct
    S_STA_DIR_4, S_STA_DIR_5, S_STA_DIR_6, S_STA_DIR_7,

    -- Load B Immediate
    S_LDB_IMM_4, S_LDB_IMM_5, S_LDB_IMM_6,

    -- Load B Direct
    S_LDB_DIR_4, S_LDB_DIR_5, S_LDB_DIR_6, S_LDB_DIR_7,

    -- Store B Direct
    S_STB_DIR_4, S_STB_DIR_5, S_STB_DIR_6, S_STB_DIR_7,

    -- Add A=A+B
    S_ADD_AB_4,

    -- Subtract A=A-B
    S_SUB_AB_4,

    -- Increment A -> A=A+1
    S_INC_A_4,

    -- Decrement A -> A=A-1
    S_DEC_A_4,

    -- Increment B -> B=B+1
    S_INC_B_4,

    -- Decrement B -> B=B-1
    S_DEC_B_4,

    -- And A = A and B
    S_AND_AB_4,

    -- Or A = A or B
    S_ORR_AB_4,

    -- Push A (Pushes the contents of A onto the stack)
    S_PSH_A_4, S_PSH_A_5,
    
    -- Push B
    S_PSH_B_4, S_PSH_B_5,
    
    -- Push PC
    S_PSH_PC_4, S_PSH_PC_5,
    
    -- Pull PC
    S_PLL_PC_4, S_PLL_PC_5, S_PLL_PC_6, S_PLL_PC_7,
    
    -- Pull A
    S_PLL_A_4, S_PLL_A_5, S_PLL_A_6, S_PLL_A_7,
    
    -- Pull B
    S_PLL_B_4, S_PLL_B_5, S_PLL_B_6, S_PLL_B_7,
    
    -- STI (PC, B, A) (Start Interrupt)
    S_STI_4, S_STI_5,   -- PSH_PC
    S_STI_6, S_STI_7,   -- PSH_B
    S_STI_8, S_STI_9,   -- PSH_A
    
    -- CLI (Clear interrupt)
    S_CLI_4,
    
    -- RTI (A, B, PC) (Return Interrupt)
    S_RTI_4, S_RTI_5, S_RTI_6, S_RTI_7,         -- PLL_A
    S_RTI_8, S_RTI_9, S_RTI_10, S_RTI_11,       -- PLL_B
    S_RTI_12, S_RTI_13, S_RTI_14, S_RTI_15,     -- PLL_PC

    -- Branch Always
    S_BRA_4, S_BRA_5, S_BRA_6,

    -- Branch if Equal to zero (Branches if Z flag is set)
    S_BEQ_4, S_BEQ_5, S_BEQ_6, S_BEQ_7,

    -- Branch if Equal to zero (Branches if Z flag is set)
    S_BMI_4, S_BMI_5, S_BMI_6, S_BMI_7,

    -- Branch if Equal to zero (Branches if Z flag is set)
    S_BCS_4, S_BCS_5, S_BCS_6, S_BCS_7,

    -- Branch if Equal to zero (Branches if Z flag is set)
    S_BVS_4, S_BVS_5, S_BVS_6, S_BVS_7,

    -- Illegal opcode state (Fault)
    S_ILL_OP_4,
    
    -- Load Illegal Opcode Fault Vector
    S_LD_ILL_OP_VEC_4,
    
    -- Load Interrupt Vector
    S_LD_INT_VEC_4
    );

  signal current_state, next_state : state_type;
  signal fault : std_logic_vector(3 downto 0);

-- start architecture
begin
  
  fault_trigger <= fault;
  
  -- State memory for the next state and the instructions wanted (LDA, BRA etc)
  STATE_MEMORY : process(clock, reset)
  begin
    if(Reset = '1') then
      current_state <= S_FETCH_0;
    elsif(clock'event and clock = '1') then
      current_state <= next_state;
    end if;
  end process;

  -- Control path for the progression of instructions
  -- (Fetch -> Decode -> Instruction Path)
  NEXT_STATE_LOGIC : process (current_state, IR, CCR_Result)
  begin

    -----------
    -- Fetch --
    -----------

    if(current_state = S_FETCH_0) then
      if (fault > "0000") then              -- Check for internal faults
        next_state <= S_STI_4;
      elsif (interrupt > "0000") then       -- Check for external interrupts
        next_state <= S_STI_4;
      else
        next_state <= S_FETCH_1;
      end if;
      
    elsif(current_state = S_FETCH_1) then
      next_state <= S_FETCH_2;
    elsif(current_state = S_FETCH_2) then
      next_state <= S_DECODE_3;

    ------------
    -- Decode --
    ------------
      
    elsif(current_state = S_DECODE_3) then

      -- Load A Immediate
      if(IR = LDA_IMM) then
        next_state <= S_LDA_IMM_4;

      -- Load A Direct
      elsif(IR = LDA_DIR) then    
        next_state <= S_LDA_DIR_4;

      -- Store A Direct
      elsif(IR = STA_DIR) then    
        next_state <= S_STA_DIR_4;

      -- Load B Immediate
      elsif (IR = LDB_IMM) then
        next_state <= S_LDB_IMM_4;

      -- Load B Direct
      elsif (IR = LDB_DIR) then
        next_state <= S_LDB_DIR_4;

      -- Store B Direct
      elsif (IR = STB_DIR) then
        next_state <= S_STB_DIR_4;

      -- Add
      elsif (IR = ADD_AB) then
        next_state <= S_ADD_AB_4;

      -- Subtract
      elsif (IR = SUB_AB) then
        next_state <= S_SUB_AB_4;

      -- Increment A
      elsif (IR = INC_A) then 
        next_state <= S_INC_A_4;

      -- Decrement A
      elsif (IR = DEC_A) then 
        next_state <= S_DEC_A_4;

      -- Increment B
      elsif (IR = INC_B) then 
        next_state <= S_INC_B_4;

      -- Decrement B
      elsif (IR = DEC_B) then 
        next_state <= S_DEC_B_4;

      -- AND
      elsif (IR = AND_AB) then
        next_state <= S_AND_AB_4;

      -- OR
      elsif (IR = ORR_AB) then
        next_state <= S_ORR_AB_4;

      -- Branch Always
      elsif(IR = BRA) then 
        next_state <= S_BRA_4;

      -- Branch if Equal to Zero
      elsif (IR = BEQ and CCR_Result(2) = '1') then
        next_state <= S_BEQ_4;
      elsif (IR = BEQ and CCR_Result(2) = '0') then
        next_state <= S_BEQ_7;

      -- Branch if Equal to Zero
      elsif (IR = BMI and CCR_Result(3) = '1') then
        next_state <= S_BMI_4;
      elsif (IR = BMI and CCR_Result(3) = '0') then
        next_state <= S_BMI_7;

      -- Branch if Equal to Zero
      elsif (IR = BCS and CCR_Result(0) = '1') then
        next_state <= S_BCS_4;
      elsif (IR = BCS and CCR_Result(0) = '0') then
        next_state <= S_BCS_7;

      -- Branch if Equal to Zero
      elsif (IR = BVS and CCR_Result(1) = '1') then
        next_state <= S_BVS_4;
      elsif (IR = BVS and CCR_Result(1) = '0') then
        next_state <= S_BVS_7;

      -- Push A to Stack
      elsif(IR = PSH_A) then
        next_state <= S_PSH_A_4;
        
      -- Push B to Stack
      elsif(IR = PSH_B) then
        next_state <= S_PSH_B_4;
        
      -- Push PC to Stack
      elsif(IR = PSH_PC) then
        next_state <= S_PSH_PC_4;
        
      -- Pull PC from Stack
      elsif(IR = PLL_PC) then
        next_state <= S_PLL_PC_4;
        
      -- Pull A from Stack
      elsif(IR = PLL_A) then
        next_state <= S_PLL_A_4;
        
      -- Pull B from Stack
      elsif(IR = PLL_B) then
        next_state <= S_PLL_B_4;
      
      -- CLI
      elsif(IR = CLI) then
        next_state <= S_CLI_4;
        
      -- RTI
      elsif(IR = RTI) then
        next_state <= S_RTI_4;
        
      -- Illegal Opcode Trap
      else
        next_state <= S_ILL_OP_4;
      end if;


    -----------------------
    -- Instruction Paths --
    -----------------------
      
    -- LDA_IMM
    elsif (current_state = S_LDA_IMM_4) then
      next_state <= S_LDA_IMM_5;
    elsif (current_state = S_LDA_IMM_5) then
      next_state <= S_LDA_IMM_6;
    elsif (current_state = S_LDA_IMM_6) then
      next_state <= S_FETCH_0;

    -- LDA_DIR
    elsif (current_state = S_LDA_DIR_4) then
      next_state <= S_LDA_DIR_5;
    elsif (current_state = S_LDA_DIR_5) then
      next_state <= S_LDA_DIR_6;
    elsif (current_state = S_LDA_DIR_6) then
      next_state <= S_LDA_DIR_7;
    elsif (current_state = S_LDA_DIR_7) then
      next_state <= S_LDA_DIR_8;
    elsif (current_state = S_LDA_DIR_8) then
      next_state <= S_FETCH_0;

    -- STA_DIR
    elsif (current_state = S_STA_DIR_4) then
      next_state <= S_STA_DIR_5;
    elsif (current_state = S_STA_DIR_5) then
      next_state <= S_STA_DIR_6;
    elsif (current_state = S_STA_DIR_6) then
      next_state <= S_STA_DIR_7;
    elsif (current_state = S_STA_DIR_7) then
      next_state <= S_FETCH_0;

    -- LDB_IMM
    elsif (current_state = S_LDB_IMM_4) then
      next_state <= S_LDB_IMM_5;
    elsif (current_state = S_LDB_IMM_5) then
      next_state <= S_LDB_IMM_6;
    elsif (current_state = S_LDB_IMM_6) then
      next_state <= S_FETCH_0;

    -- LDB_DIR
    elsif (current_state = S_LDB_DIR_4) then
      next_state <= S_LDB_DIR_5;
    elsif (current_state = S_LDB_DIR_5) then
      next_state <= S_LDB_DIR_6;
    elsif (current_state = S_LDB_DIR_6) then
      next_state <= S_LDB_DIR_7;
    elsif (current_state = S_LDB_DIR_7) then
      next_state <= S_FETCH_0;

    -- STB_DIR
    elsif (current_state = S_STB_DIR_4) then
      next_state <= S_STB_DIR_5;
    elsif (current_state = S_STB_DIR_5) then
      next_state <= S_STB_DIR_6;
    elsif (current_state = S_STB_DIR_6) then
      next_state <= S_STB_DIR_7;
    elsif (current_state = S_STB_DIR_7) then
      next_state <= S_FETCH_0;

    -- BRA
    elsif (current_state = S_BRA_4) then
      next_state <= S_BRA_5;
    elsif (current_state = S_BRA_5) then
      next_state <= S_BRA_6;
    elsif (current_state = S_BRA_6) then
      next_state <= S_FETCH_0;

    -- BEQ & Z=1
    elsif (current_state = S_BEQ_4) then
      next_state <= S_BEQ_5;
    elsif (current_state = S_BEQ_5) then
      next_state <= S_BEQ_6;
    elsif (current_state = S_BEQ_6) then
      next_state <= S_FETCH_0;
    -- BEQ & Z=0
    elsif (current_state = S_BEQ_7) then
      next_state <= S_FETCH_0;
      
    -- BMI & N=1
    elsif (current_state = S_BMI_4) then
      next_state <= S_BMI_5;
    elsif (current_state = S_BMI_5) then
      next_state <= S_BMI_6;
    elsif (current_state = S_BMI_6) then
      next_state <= S_FETCH_0;
    -- BMI & N=0
    elsif (current_state = S_BMI_7) then
      next_state <= S_FETCH_0;      

    -- BCS & C=1
    elsif (current_state = S_BCS_4) then
      next_state <= S_BCS_5;
    elsif (current_state = S_BCS_5) then
      next_state <= S_BCS_6;
    elsif (current_state = S_BCS_6) then
      next_state <= S_FETCH_0;
    -- BCS & C=0
    elsif (current_state = S_BCS_7) then
      next_state <= S_FETCH_0;

    -- BVS & V=1
    elsif (current_state = S_BVS_4) then
      next_state <= S_BVS_5;
    elsif (current_state = S_BVS_5) then
      next_state <= S_BVS_6;
    elsif (current_state = S_BVS_6) then
      next_state <= S_FETCH_0;
    -- BVS & V=0
    elsif (current_state = S_BVS_7) then
      next_state <= S_FETCH_0;

    -- ADD_AB
    elsif (current_state = S_ADD_AB_4) then  -- Path for ADD_AB_AB instruction
      next_state <= S_FETCH_0;

    -- SUB_AB
    elsif (current_state = S_SUB_AB_4) then
      next_state <= S_FETCH_0;

    -- INC_A
    elsif (current_state = S_INC_A_4) then
      next_state <= S_FETCH_0;

    -- DEC_A
    elsif (current_state = S_DEC_A_4) then
      next_state <= S_FETCH_0;

    -- INC_B
    elsif (current_state = S_INC_B_4) then
      next_state <= S_FETCH_0;

    -- DEC_B
    elsif (current_state = S_DEC_B_4) then
      next_state <= S_FETCH_0;

    -- ORR_AB
    elsif (current_state = S_ORR_AB_4) then
      next_state <= S_FETCH_0;

    -- AND_AB
    elsif (current_state = S_AND_AB_4) then
      next_state <= S_FETCH_0;

    -- PSH_A
    elsif (current_state = S_PSH_A_4) then
      next_state <= S_PSH_A_5;
    elsif (current_state = S_PSH_A_5) then
      case(fault) is
      when "0001" =>
        next_state <= S_LD_ILL_OP_VEC_4;
      when others =>
      next_state <= S_FETCH_0;
      end case;
      
      -- PSH_B
    elsif (current_state = S_PSH_B_4) then
      next_state <= S_PSH_B_5;
    elsif (current_state = S_PSH_B_5) then
      case(fault) is
      when "0001" =>
        next_state <= S_PSH_A_4;
      when others =>
      next_state <= S_FETCH_0;
      end case;
      
      -- PSH_PC
    elsif (current_state = S_PSH_PC_4) then
      next_state <= S_PSH_PC_5;
    elsif (current_state = S_PSH_PC_5) then
      case(fault) is
      when "0001" =>
        next_state <= S_PSH_B_4;
      when others =>
      next_state <= S_FETCH_0;
      end case;
      
      -- PLL_PC
    elsif (current_state = S_PLL_PC_4) then
        next_state <= S_PLL_PC_5;
    elsif (current_state = S_PLL_PC_5) then
        next_state <= S_PLL_PC_6;
    elsif (current_state = S_PLL_PC_6) then
        next_state <= S_PLL_PC_7;
    elsif (current_state = S_PLL_PC_7) then
        next_state <= S_FETCH_0;

      -- PLL_A
    elsif (current_state = S_PLL_A_4) then
        next_state <= S_PLL_A_5;
    elsif (current_state = S_PLL_A_5) then
        next_state <= S_PLL_A_6;
    elsif (current_state = S_PLL_A_6) then
        next_state <= S_PLL_A_7;
    elsif (current_state = S_PLL_A_7) then
        next_state <= S_FETCH_0;        
        
      -- PLL_B
    elsif (current_state = S_PLL_B_4) then
        next_state <= S_PLL_B_5;
    elsif (current_state = S_PLL_B_5) then
        next_state <= S_PLL_B_6;
    elsif (current_state = S_PLL_B_6) then
        next_state <= S_PLL_B_7;
    elsif (current_state = S_PLL_B_7) then
        next_state <= S_FETCH_0;
        
     -- RTI
     elsif (current_state = S_RTI_4) then
        next_state <= S_RTI_5;        
     elsif (current_state = S_RTI_5) then
        next_state <= S_RTI_6;
     elsif (current_state = S_RTI_6) then
        next_state <= S_RTI_7;
     elsif (current_state = S_RTI_7) then
        next_state <= S_RTI_8;        
     elsif (current_state = S_RTI_8) then
        next_state <= S_RTI_9;
     elsif (current_state = S_RTI_9) then
        next_state <= S_RTI_10;        
     elsif (current_state = S_RTI_10) then
        next_state <= S_RTI_11;        
     elsif (current_state = S_RTI_11) then
        next_state <= S_RTI_12;
     elsif (current_state = S_RTI_12) then
        next_state <= S_RTI_13;
     elsif (current_state = S_RTI_13) then
        next_state <= S_RTI_14;        
     elsif (current_state = S_RTI_14) then
        next_state <= S_RTI_15;
     elsif (current_state = S_RTI_15) then
        next_state <= S_FETCH_0;  
    
    -- STI
      elsif (current_state = S_STI_4) then
        next_state <= S_STI_5;        
     elsif (current_state = S_STI_5) then
        next_state <= S_STI_6;
     elsif (current_state = S_STI_6) then
        next_state <= S_STI_7;
     elsif (current_state = S_STI_7) then
        next_state <= S_STI_8;        
     elsif (current_state = S_STI_8) then
        next_state <= S_STI_9;
     elsif (current_state = S_STI_9) then
        if (fault > "0000") then
            next_state <= S_LD_ILL_OP_VEC_4;
        else
            next_state <= S_LD_INT_VEC_4;
        end if;       
    
    -- CLI
    elsif (current_state = S_CLI_4) then
        next_state <= S_FETCH_0;   
    
    -- Fault vector lookup
    elsif (current_state = S_LD_ILL_OP_VEC_4) then
        next_state <= S_FETCH_0;
        
    -- Interrupt vector lookup
    elsif (current_state = S_LD_INT_VEC_4) then
        next_state <= S_FETCH_0;
            
     -- Triggers Illegal Opcode Fault Handling
    elsif (current_state <= S_ILL_OP_4) then
        next_state <= S_FETCH_0;
        
    -- Illegal Opcode Trap
    else
      next_state <= S_ILL_OP_4;
    end if;
  end process;


  

  OUTPUT_LOGIC : process (current_state)
  -- Output logic for each state
  begin
    case(current_state) is
      when S_FETCH_0 =>                 --Put PC onto MAR to read Opcode
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
        interrupt_clr <= '0';
--        fault         <= "0000";

      when S_FETCH_1 =>                 -- Increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_FETCH_2 =>                 -- Opcode available on Bus2 and latched onto IR
        IR_Load       <= '1';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_DECODE_3 =>                -- opcode now in IR and is decoded
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

-- Load A Immediate
      when S_LDA_IMM_4 =>               -- Operand is being loaded into A, pointer at location so load in MAR
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_IMM_5 =>               -- Increment PC for the clock cycle to send operand
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_IMM_6 =>               -- operand is now on Bus2 and can be latched to A
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

-- starts LDA DIR
      when S_LDA_DIR_4 =>               -- operand of instruction is address
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_DIR_5 =>               -- increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_DIR_6 =>               -- operand is now on Bus2 and can be loaded in MAR
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_DIR_7 =>               -- Giving time without moving PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDA_DIR_8 =>               -- operand is now on Bus2 and can be latched to A
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

-- Store A direct
      when S_STA_DIR_4 =>               
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STA_DIR_5 =>               
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STA_DIR_6 =>               
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STA_DIR_7 =>               
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "01";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_IMM_4 =>               -- Put PC into MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_IMM_5 =>               -- Increment PC, Operand will be available next state
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_IMM_6 =>               -- Operand is available, latch into B
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '1';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      -- LDB_DIR
      when S_LDB_DIR_4 =>               -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_DIR_5 =>               -- Prepare to receive Operand from memory, increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_DIR_6 =>               -- Put Operand into MAR (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_LDB_DIR_7 =>               -- Put data arriving on "from_memory" into B
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '1';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      --------------------------------------------------------------------------------------------------
      -- STB_DIR
      --------------------------------------------------------------------------------------------------
      when S_STB_DIR_4 =>               -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STB_DIR_5 =>               -- Prepare to receive Operand from memory, increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STB_DIR_6 =>               -- Put Operand into MAR (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_STB_DIR_7 =>               -- Put B onto Bus2, which is connected to "to_memory", assert write
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "10";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      --------------------------------------------------------------------------------------------------
      -- ADD_AB_AB
      --------------------------------------------------------------------------------------------------
      when S_ADD_AB_4 =>                -- Assert control signals to perfom addition
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_SUB_AB_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= sub;
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";                                        

      when S_AND_AB_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= andab;
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_ORR_AB_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= orrab;
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";           

      when S_INC_A_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= inca;
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_DEC_A_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_Load        <= '0';
        ALU_Sel       <= deca;
        CCR_Load      <= '1';
        Bus1_Sel      <= "01";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
                                       
      when S_INC_B_4 =>

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '1';
        ALU_Sel       <= incb;
        CCR_Load      <= '1';
        Bus1_Sel      <= "00";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
                                      
      when S_DEC_B_4 =>                 -- Load B, Send decrement value to ALU
                                        -- and load CCR

        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '1';
        ALU_Sel       <= decb;
        CCR_Load      <= '1';
        Bus1_Sel      <= "00";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_PSH_A_4 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PSH_A_5 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "01";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PSH_B_4 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PSH_B_5 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "10";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
    when S_PSH_PC_4 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PSH_PC_5 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
    when S_PLL_PC_4 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PLL_PC_5 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PLL_PC_6 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
      when S_PLL_PC_7 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
    when S_PLL_A_4 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PLL_A_5 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
      when S_PLL_A_6 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0'; 
--        fault         <= "0000";       
        
      when S_PLL_A_7 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
    when S_PLL_B_4 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_PLL_B_5 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
      when S_PLL_B_6 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';   
--        fault         <= "0000"; 
                    
      when S_PLL_B_7 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '1';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
    when S_STI_4 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_STI_5 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";        
      when S_STI_6 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_STI_7 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "10";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";        

      when S_STI_8 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_STI_9 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "01";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '1';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '1';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

    when S_RTI_4 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_RTI_5 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
      when S_RTI_6 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0'; 
--        fault         <= "0000";       
        
      when S_RTI_7 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '1';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

    when S_RTI_8 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_RTI_9 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";
        
      when S_RTI_10 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';   
--        fault         <= "0000"; 
                    
      when S_RTI_11 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '1';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

    when S_RTI_12 =>                  -- Decrement Stack Pointer
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '1';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_RTI_13 =>                -- Load MAR with Stack Pointer address   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '1';
--        fault         <= "0000";

      when S_RTI_14 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
      when S_RTI_15 =>              -- Load Program Counter with value stored in Stack     
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

-- Branch Always
      when S_BRA_4 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BRA_5 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BRA_6 =>                   
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC, "01"=A, "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU_Result, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BEQ_4 =>                   -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BEQ_5 =>                   -- Prepare to receive Operand from memory
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BEQ_6 =>                   -- Put Operand into PC (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BEQ_7 =>                   -- Z=0 so just increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BMI_4 =>                   -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BMI_5 =>                   -- Prepare to receive Operand from memory
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BMI_6 =>                   -- Put Operand into PC (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BMI_7 =>                   -- Z=0 so just increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BCS_4 =>                   -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BCS_5 =>                   -- Prepare to receive Operand from memory
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BCS_6 =>                   -- Put Operand into PC (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BCS_7 =>                   -- Z=0 so just increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BVS_4 =>                   -- Put PC onto MAR to provide address of Operand
        IR_Load       <= '0';
        MAR_Load      <= '1';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "01";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BVS_5 =>                   -- Prepare to receive Operand from memory
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BVS_6 =>                   -- Put Operand into PC (Leave Bus2=from_memory)
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "10";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";

      when S_BVS_7 =>                   -- Z=0 so just increment PC
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '1';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "00";          -- "00"=ALU, "01"=Bus1, "10"=from_memory
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
      when S_LD_ILL_OP_VEC_4 =>
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "11";          -- "00"=ALU, "01"=Bus1, "10"=from_memory, "11"=Vector
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '1';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
        fault         <= "0000";      

      when S_LD_INT_VEC_4 =>
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '1';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00"=PC,  "01"=A,    "10"=B
        Bus2_Sel      <= "11";          -- "00"=ALU, "01"=Bus1, "10"=from_memory, "11"=Vector
        write         <= '0';
        cpu_exception <= '0';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
        fault         <= "0000"; 
        interrupt_clr <= '1';
        
      when S_ILL_OP_4 =>
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_Inc        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";
        Bus2_Sel      <= "00";
        write         <= '0';
        cpu_exception <= '1';
        illegal_op    <= '1';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
        fault         <= "0001";

      when others =>
        IR_Load       <= '0';
        MAR_Load      <= '0';
        PC_Load       <= '0';
        PC_INC        <= '0';
        A_Load        <= '0';
        B_Load        <= '0';
        ALU_Sel       <= "000";
        CCR_Load      <= '0';
        Bus1_Sel      <= "00";          -- "00" = PC, "01" = A, "10" = B
        Bus2_Sel      <= "00";          -- "00" = ALU_Result, "01" = Bus1, "10" = from_memory
        write         <= '0';
        cpu_exception <= '1';
        illegal_op    <= '0';
        SP_Inc        <= '0';
        SP_Dec        <= '0';
        SP_Enable     <= '0';
--        fault         <= "0000";
        
    end case;
  end process;
end architecture;
