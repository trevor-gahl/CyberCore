import random
import os
import shutil

programCode = []

def createProgramMemory(filename, programList, core):
    with open(filename,'w') as file:

        fileStart = """
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library xil_defaultlib;
"""
        instructionFile = "use xil_defaultlib.instructions_core_1.all;" %core

        entityName = "entity rom_128x8_sync_core_%s is" %core
        entityBlock = """
    port (address   : in  std_logic_vector (7 downto 0);
    	 clock     : in  std_logic;
    	 data_out  : out  std_logic_vector (7 downto 0));
end entity;"""
        architectureName = "architecture rom_128x8_sync_arch of rom_128x8_sync_core_%s is" %core
        architectureBlock = """
signal EN:	std_logic;

type rom_type is array (0 to 95) of std_logic_vector(7 downto 0);

constant ROM : rom_type := 	("""

        fileEnd = """
        others => x"00");
begin
    --enables ROM and port_outs
    enable: process(address)
     begin
      if ((to_integer(unsigned(address)) >=0) and
          (to_integer(unsigned(address)) <=95)) then
        EN <='1';
         else
        EN <='0';
      end if;
     end process;

    memory: process(clock)
     begin
      if (clock'event and clock='1') then
       if (EN='1') then
        data_out <= ROM(to_integer(unsigned(address)));
       end if;
      end if;
     end process;
end architecture;
        """
        file.write("%s" %(fileStart))
        file.write("%s \n" %(instructionFile))
        file.write("%s \n" %(entityName))
        file.write("%s \n" %(entityBlock))
        file.write("%s \n" %(architectureName))
        file.write("%s \n" %(architectureBlock))
        for item in programCode:
            file.write("        %s\n" % item)
        file.write("%s" %(fileEnd))

def createProgramList(filename):
    lines = [line.rstrip('\n') for line in open(filename)]
    for x in range(len(lines)):
        instruction = '%i => %s,' %(x,lines[x])
        programCode.append(instruction)

def createInstructionFile(filename,core):
    with open(filename, 'w') as file:

        opcodes = random.sample(range(16,225),27)
        for x in range(len(opcodes)):
            opcodes[x] = hex(opcodes[x])
            opcodes[x] = opcodes[x][-2:]
        print(opcodes)

        LDA_IMM = opcodes[0]
        LDB_IMM = opcodes[1]
        LDA_DIR = opcodes[2]
        LDB_DIR = opcodes[3]
        STA_DIR = opcodes[4]
        STB_DIR = opcodes[5]
        ADD_AB  = opcodes[6]
        SUB_AB  = opcodes[7]
        INC_A   = opcodes[8]
        DEC_A   = opcodes[9]
        INC_B   = opcodes[10]
        DEC_B   = opcodes[11]
        AND_AB  = opcodes[12]
        ORR_AB  = opcodes[13]
        BRA     = opcodes[14]
        BMI     = opcodes[15]
        BEQ     = opcodes[16]
        BCS     = opcodes[17]
        BVS     = opcodes[18]
        PSH_A   = opcodes[19]
        PSH_B   = opcodes[20]
        PSH_PC  = opcodes[21]
        PLL_A   = opcodes[22]
        PLL_B   = opcodes[23]
        PLL_PC  = opcodes[24]
        RTI     = opcodes[25]
        STI     = opcodes[26]


        header = """library IEEE;
use IEEE.STD_LOGIC_1164.ALL;"""
        line1 = "package instructions_core_%s is" %core
        line2 = "constant LDA_IMM : std_logic_vector (7 downto 0) :=x\"%s\";" %LDA_IMM
        line3 = "constant LDB_IMM : std_logic_vector (7 downto 0) :=x\"%s\";" %LDB_IMM
        line4 = "constant LDA_DIR : std_logic_vector (7 downto 0) :=x\"%s\";" %LDA_DIR
        line5 = "constant LDB_DIR : std_logic_vector (7 downto 0) :=x\"%s\";" %LDB_DIR
        line6 = "constant STA_DIR : std_logic_vector (7 downto 0) :=x\"%s\";" %STA_DIR
        line7 = "constant STB_DIR : std_logic_vector (7 downto 0) :=x\"%s\";" %STB_DIR
        line8 = "constant ADD_AB  : std_logic_vector (7 downto 0) :=x\"%s\";" %ADD_AB
        line9 = "constant SUB_AB  : std_logic_vector (7 downto 0) :=x\"%s\";" %SUB_AB
        line10 = "constant INC_A   : std_logic_vector (7 downto 0) :=x\"%s\";" %INC_A
        line11 = "constant DEC_A   : std_logic_vector (7 downto 0) :=x\"%s\";" %DEC_A
        line12 = "constant INC_B   : std_logic_vector (7 downto 0) :=x\"%s\";" %INC_B
        line13 = "constant DEC_B   : std_logic_vector (7 downto 0) :=x\"%s\";" %DEC_B
        line14 = "constant AND_AB  : std_logic_vector (7 downto 0) :=x\"%s\";" %AND_AB
        line15 = "constant ORR_AB  : std_logic_vector (7 downto 0) :=x\"%s\";" %ORR_AB
        line16 = "constant BRA     : std_logic_vector (7 downto 0) :=x\"%s\";" %BRA
        line17 = "constant BMI     : std_logic_vector (7 downto 0) :=x\"%s\";" %BMI
        line18 = "constant BEQ     : std_logic_vector (7 downto 0) :=x\"%s\";" %BEQ
        line19 = "constant BCS     : std_logic_vector (7 downto 0) :=x\"%s\";" %BCS
        line20 = "constant BVS     : std_logic_vector (7 downto 0) :=x\"%s\";" %BVS
        line21 = "constant PSH_A   : std_logic_vector (7 downto 0) :=x\"%s\";" %PSH_A
        line22 = "constant PSH_B   : std_logic_vector (7 downto 0) :=x\"%s\";" %PSH_B
        line23 = "constant PSH_PC  : std_logic_vector (7 downto 0) :=x\"%s\";" %PSH_PC
        line24 = "constant PLL_A   : std_logic_vector (7 downto 0) :=x\"%s\";" %PLL_A
        line25 = "constant PLL_B   : std_logic_vector (7 downto 0) :=x\"%s\";" %PLL_B
        line26 = "constant PLL_PC  : std_logic_vector (7 downto 0) :=x\"%s\";" %PLL_PC
        line27 = "constant RTI     : std_logic_vector (7 downto 0) :=x\"%s\";" %RTI
        line28 = "constant STI     : std_logic_vector (7 downto 0) :=x\"%s\";" %STI
        line29 = "constant add     : std_logic_vector (7 downto 0) :=\"000\";"
        line30 = "constant sub     : std_logic_vector (7 downto 0) :=\"001\";"
        line31 = "constant andab   : std_logic_vector (7 downto 0) :=\"010\";"
        line32 = "constant orrab   : std_logic_vector (7 downto 0) :=\"011\";"
        line33 = "constant inca    : std_logic_vector (7 downto 0) :=\"100\";"
        line34 = "constant deca    : std_logic_vector (7 downto 0) :=\"101\";"
        line35 = "constant incb    : std_logic_vector (7 downto 0) :=\"110\";"
        line36 = "constant decb    : std_logic_vector (7 downto 0) :=\"111\";"
        line37 = "end package instructions_core_%s;" %core
        file.write('%s \n' %(header))
        file.write("%s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s \n %s" %(line1, line2, line3, line4, line5, line6, line7, line8, line9, line10, line11, line12, line13, line14, line15, line16, line17, line18, line19, line20, line21, line22, line23, line24, line25, line26, line27, line28, line29, line30, line31, line32, line33, line34, line35, line36, line37))

def projectGen(source,destination):
    if not os.path.exists(destination):
        os.makedirs(destination)
    src_files = os.listdir(source)
    for file_name in src_files:
        full_file_name = os.path.join(source, file_name)
        if (os.path.isfile(full_file_name)):
            shutil.copy(full_file_name, destination)


# source = 'Master_Trip_Core'
# destination = input('Enter Project Name: ')
# projectGen(source,destination)
# file1 = '%s/instructions_core_1.vhd' %destination
# file2 = '%s/instructions_core_2.vhd' %destination
# file3 = '%s/instructions_core_3.vhd' %destination
# program = 'program.asm'
# mem1 = '%s/rom_128x8_sync_core_1.vhd' %destination
# mem2 = '%s/rom_128x8_sync_core_2.vhd' %destination
# mem3 = '%s/rom_128x8_sync_core_3.vhd' %destination


# projectGen(source,destination)
# createInstructionFile(file1,'1')
# createInstructionFile(file2,'2')
createInstructionFile("instruction_core_3.vhd",'3')
# createProgramList(program)
# createProgramMemory(mem1,programCode,'1')
# createProgramMemory(mem2,programCode,'2')
# createProgramMemory(mem3,programCode,'3')
