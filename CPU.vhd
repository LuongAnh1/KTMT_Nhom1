LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SingleCycleCPU IS
    PORT (
        clk, reset : IN STD_LOGIC
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
            Instruction => Instruction
        );

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
    -- 4. Register File
    ------------------------------------------------------------------------
    RF_inst: ENTITY work.RegisterFile
        PORT MAP (
            clk        => clk,
            RegWrite   => RegWrite,
            ReadReg1   => Instruction(25 DOWNTO 21),
            ReadReg2   => Instruction(20 DOWNTO 16),
            WriteReg   => WriteRegAddr,
            WriteData  => WriteDataReg,
            ReadData1  => ReadData1,
            ReadData2  => ReadData2
        );

    ------------------------------------------------------------------------
    -- MUX ALUSrc (chọn ALU input B: ReadData2 hoặc SignImm)
    ------------------------------------------------------------------------
    ALU_B <= SignImm WHEN ALUSrc = '1' ELSE ReadData2;


    ------------------------------------------------------------------------
    -- 5. ALU Control
    ------------------------------------------------------------------------
    ALUC_inst: ENTITY work.ALUControl
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
