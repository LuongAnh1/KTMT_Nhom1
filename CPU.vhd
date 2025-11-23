-- B1: Nhập lệnh dưới dạng mã hex vào Instruction Memory (ROM)
-- B2: Kết nối các khối để tạo thành CPU đơn chu kỳ hoàn chỉnh
-- Biên dịch CPU đơn chu kỳ:
-- ghdl -a ./PC/PC.vhd ./InstructionMemory/InstructionMemory.vhd ./CU/CU.vhd ./RegisterFile/RegisterFile.vhd ./ALUControl/ALUControl.vhd ./ALU/ALU.vhd ./DataMemory/DataMemory.vhd ./MUX_WriteBack/MUX_WriteBack.vhd CPU.vhd CPU_tb.vhd
-- ghdl -e SingleCycleCPU_tb
-- ghdl -r SingleCycleCPU_tb --vcd=singlecpu.vcd --stop-time=300ns

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SingleCycleCPU IS
    PORT (
        clk, reset : IN STD_LOGIC;

        -- Debug interface for testbench
        dbg_write_enable : in std_logic := '0'; 
        dbg_write_reg    : in std_logic_vector(4 downto 0) := (others => '0'); 
        dbg_write_data   : in std_logic_vector(31 downto 0) := (others => '0');
        dbg_read_reg     : in std_logic_vector(4 downto 0) := (others => '0');
        dbg_read_data    : out std_logic_vector(31 downto 0)
    );
END ENTITY;

ARCHITECTURE behavior OF SingleCycleCPU IS

    -- ==== Tín hiệu liên kết các khối ====
    SIGNAL PC_in, PC_out             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Instruction               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ReadData1, ReadData2      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL SignImm                   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALUResult, MemReadData    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL WriteDataReg              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL Zero                      : STD_LOGIC;
    SIGNAL ALUControlSig             : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- Tín hiệu cho các MUX
    SIGNAL WriteRegAddr              : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL ALU_B                     : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Control Unit outputs
    SIGNAL RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch : STD_LOGIC;
    SIGNAL ALUOp                     : STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- Debug signals
    signal RF_WriteReg  : std_logic_vector(4 downto 0);
    signal RF_WriteData : std_logic_vector(31 downto 0);
    signal RF_RegWrite  : std_logic;
    signal Instruction_raw : std_logic_vector(31 downto 0);

BEGIN
    ------------------------------------------------------------------------
    -- 1. Program Counter
    ------------------------------------------------------------------------
    PC_inst: ENTITY work.PC
        PORT MAP (
            clk => clk,
            reset => reset,
            PC_in => PC_in,
            PC_out => PC_out
        );

    ------------------------------------------------------------------------
    -- 2. Instruction Memory
    ------------------------------------------------------------------------
    IM_inst: ENTITY work.InstructionMemory
        PORT MAP (
            Address => PC_out,
            Instruction => Instruction_raw
        );

    -- Debug: Force NOP when writing to registers
    Instruction <= (others => '0') when dbg_write_enable = '1'
                   else Instruction_raw;

    ------------------------------------------------------------------------
    -- 3. Control Unit
    ------------------------------------------------------------------------
    CU_inst: ENTITY work.ControlUnit
        PORT MAP (
            opcode    => Instruction(31 DOWNTO 26),
            RegDst    => RegDst,
            ALUSrc    => ALUSrc,
            MemToReg  => MemToReg,
            RegWrite  => RegWrite,
            MemRead   => MemRead,
            MemWrite  => MemWrite,
            Branch    => Branch,
            ALUOp     => ALUOp
        );

    ------------------------------------------------------------------------
    -- Sign Extend (16-bit immediate -> 32-bit)
    ------------------------------------------------------------------------
    SignImm <= (31 DOWNTO 16 => Instruction(15)) & Instruction(15 DOWNTO 0);

    ------------------------------------------------------------------------
    -- MUX RegDst (chọn WriteReg: rd hoặc rt)
    ------------------------------------------------------------------------
    WriteRegAddr <= Instruction(15 DOWNTO 11) WHEN RegDst = '1' 
                    ELSE Instruction(20 DOWNTO 16);

    ------------------------------------------------------------------------
    -- Debug control for Register File
    ------------------------------------------------------------------------
    RF_RegWrite  <= dbg_write_enable or RegWrite;
    RF_WriteReg  <= dbg_write_reg when dbg_write_enable = '1'
                    else WriteRegAddr;
    RF_WriteData <= dbg_write_data when dbg_write_enable = '1'
                    else WriteDataReg;

    ------------------------------------------------------------------------
    -- 4. Register File
    ------------------------------------------------------------------------
    RF_inst: ENTITY work.RegisterFile
        PORT MAP (
            clk        => clk,
            RegWrite   => RF_RegWrite,
            ReadReg1   => Instruction(25 DOWNTO 21),
            ReadReg2   => Instruction(20 DOWNTO 16),
            WriteReg   => RF_WriteReg,
            WriteData  => RF_WriteData,
            ReadData1  => ReadData1,
            ReadData2  => ReadData2
        );

    ------------------------------------------------------------------------
    -- MUX ALUSrc (chọn ALU input B)
    ------------------------------------------------------------------------
    ALU_B <= SignImm WHEN ALUSrc = '1' ELSE ReadData2;

    ------------------------------------------------------------------------
    -- 5. ALU Control
    ------------------------------------------------------------------------
    ALUC_inst: ENTITY work.ALUCO
        PORT MAP (
            ALUOp      => ALUOp,
            funct      => Instruction(5 DOWNTO 0),
            ALUControl => ALUControlSig
        );

    ------------------------------------------------------------------------
    -- 6. ALU
    ------------------------------------------------------------------------
    ALU_inst: ENTITY work.ALU
        PORT MAP (
            A           => ReadData1,
            B           => ALU_B,
            ALUControl  => ALUControlSig,
            Result      => ALUResult,
            Zero        => Zero
        );

    ------------------------------------------------------------------------
    -- 7. Data Memory
    ------------------------------------------------------------------------
    DM_inst: ENTITY work.DataMemory
        PORT MAP (
            clk        => clk,
            MemRead    => MemRead,
            MemWrite   => MemWrite,
            Address    => ALUResult,
            WriteData  => ReadData2,
            ReadData   => MemReadData
        );

    ------------------------------------------------------------------------
    -- 8. MUX WriteBack
    ------------------------------------------------------------------------
    WB_mux: ENTITY work.MUX_WriteBack
        PORT MAP (
            ALUResult  => ALUResult,
            ReadData   => MemReadData,
            MemToReg   => MemToReg,
            WriteData  => WriteDataReg
        );

    ------------------------------------------------------------------------
    -- 9. PC Update (tăng +4 đơn giản)
    ------------------------------------------------------------------------
    PC_in <= STD_LOGIC_VECTOR(unsigned(PC_out) + 4);

END ARCHITECTURE;