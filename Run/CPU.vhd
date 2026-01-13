-- B1: Nhập lệnh dưới dạng mã hex vào Instruction Memory (ROM)
-- B2: Kết nối các khối để tạo thành CPU đơn chu kỳ hoàn chỉnh
-- Biên dịch CPU đơn chu kỳ (Nạp dữ liệu vào thanh ghi và bắt đầu chạy ở giây thứu 300ns):
-- del *.o
-- del -Recurse -Force work
-- ghdl -a BarrelShifter.vhd BrentKung_16.vhd BrentKung_32.vhd
-- ghdl -a PC.vhd InstructionMemory.vhd CU.vhd RegisterFile.vhd ALUControl.vhd ALU.vhd DataMemory.vhd MUX_WriteBack.vhd CPU.vhd CPU_tb.vhd
-- ghdl -e SingleCycleCPU_tb
-- ghdl -r SingleCycleCPU_tb --vcd=singlecpu.vcd --stop-time=500ns
-- gtkwave singlecpu.vcd

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
    SIGNAL RegWrite, MemRead, MemWrite, Branch, Jump : STD_LOGIC;
    SIGNAL ALUOp, ALUSrc, RegDst, MemToReg           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL BranchType                        : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    -- Tín hiệu cho Branch
    SIGNAL BranchTarget                      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PCSrc                             : STD_LOGIC;
    SIGNAL PC_plus_4                         : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Tín hiệu cho Jump
    SIGNAL JumpAddress               : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL PC_Branch_Decision        : STD_LOGIC_VECTOR(31 DOWNTO 0); -- Tín hiệu trung gian 

    -- Tín hiệu dịch bit (shift amount)
    signal Shamt_value, check    : STD_LOGIC_VECTOR(4 downto 0);
    signal Shamt_ext_32 : STD_LOGIC_VECTOR(31 downto 0);
    -- Tín hiệu điều khiển ALU_A MUX
    signal ALU_A_Input : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUSrcA_ctrl : STD_LOGIC; -- Tín hiệu điều khiển mới từ Control Unit (ví dụ: '0' cho ReadData1, '1' cho ReadData2)

BEGIN
    ------------------------------------------------------------------------
    -- 1. Program Counter
    ------------------------------------------------------------------------
    PC_inst: ENTITY work.PC
        PORT MAP (
            clk => clk, -- xung nhịp cho PC (in)
            reset => reset, -- tín hiệu reset cho PC (in)
            PC_in => PC_in, -- địa chỉ lệnh tiếp theo (in)
            PC_out => PC_out -- địa chỉ lệnh hiện tại (out)
        );

    ------------------------------------------------------------------------
    -- 2. Instruction Memory
    ------------------------------------------------------------------------
    IM_inst: ENTITY work.InstructionMemory
        PORT MAP (
            Address => PC_out, -- địa chỉ lệnh từ PC (in)
            Instruction => Instruction -- lệnh ra (out)
        );
    ------------------------------------------------------------------------
    -- 3. Control Unit
    ------------------------------------------------------------------------
    CU_inst: ENTITY work.ControlUnit
        PORT MAP (
            opcode    => Instruction(31 DOWNTO 26),
            funct_in  => Instruction(5 DOWNTO 0), -- Truyền funct vào Control Unit
            RegDst    => RegDst, -- tín hiệu chọn WriteReg
            ALUSrc_ctrl    => ALUSrc, -- tín hiệu chọn ALU input B (ReadData hoặc SignImm hoặc shamt)
            MemToReg  => MemToReg, -- tín hiệu chọn dữ liệu ghi vào Register File (ALUResult hoặc MemReadData)
            RegWrite  => RegWrite, -- tín hiệu cho phép ghi vào Register File
            MemRead   => MemRead, -- tín hiệu đọc từ Data Memory
            MemWrite  => MemWrite, -- tín hiệu ghi vào Data Memory
            Branch    => Branch, -- tín hiệu nhánh
            BranchType => BranchType, -- phân biệt beq (00) và bne (01)
            Jump      => Jump, -- tín hiệu jump (J-type)
            ALUSrcA   => ALUSrcA_ctrl, -- tín hiệu chọn đầu vào A cho ALU
            ALUOp     => ALUOp -- tín hiệu điều khiển ALU
        );


    ------------------------------------------------------------------------
    -- Sign Extend (16-bit immediate -> 32-bit)
    ------------------------------------------------------------------------
    SignImm <= (31 DOWNTO 16 => Instruction(15)) & Instruction(15 DOWNTO 0);

    ------------------------------------------------------------------------
    -- MUX RegDst (chọn WriteReg: rd hoặc rt)
    ------------------------------------------------------------------------
    -- Nếu RegDst = 01 ~ R-type thì chọn rd (Instruction[15:11])
    --              00 rt ~ I-type (Instruction[20:16])
    --              10 ~ $ra (31) cho jal
    WriteRegAddr <= Instruction(20 DOWNTO 16) WHEN RegDst = "00" ELSE
                    Instruction(15 DOWNTO 11) WHEN RegDst = "01" ELSE
                    "11111"; -- Chọn thanh ghi 31 (cho jal)


    ------------------------------------------------------------------------
    -- 4. Register File
    ------------------------------------------------------------------------
    RF_inst: ENTITY work.RegisterFile
        PORT MAP (
            clk        => clk, -- xung nhịp cho Register File (in)
            RegWrite   => RegWrite, -- tín hiệu từ Control Unit (Cho phép ghi hay không) (in)
            ReadReg1   => Instruction(25 DOWNTO 21), -- rs: thanh ghi nguồn 1 (in)
            ReadReg2   => Instruction(20 DOWNTO 16), -- rt: thanh ghi nguồn 2 (in)
            WriteReg   => WriteRegAddr, -- tín hiệu từ MUX RegDst (chọn rd hoặc rt) (in)
            WriteData  => WriteDataReg, -- dữ liệu ghi vào thanh ghi đích (in)
            ReadData1  => ReadData1, -- dữ liệu đọc từ thanh ghi nguồn 1 (out)
            ReadData2  => ReadData2 -- dữ liệu đọc từ thanh ghi nguồn 2 (out)
        );

    ------------------------------------------------------------------------
    -- 5. ALU Control
    ------------------------------------------------------------------------
    ALUC_inst: ENTITY work.ALUCO
        PORT MAP (
            ALUOp      => ALUOp, -- tín hiệu từ Control Unit (in)
            funct      => Instruction(5 DOWNTO 0), -- phần funct của lệnh R-type (in)
            opcode    => Instruction(31 DOWNTO 26), -- phần opcode của lệnh I-type (in)
            ALUControl => ALUControlSig -- tín hiệu điều khiển ALU (out)
        );

    ------------------------------------------------------------------------
    -- MUX ALUSrc 
    -- chọn ALU input B: ReadData2 ~ rd (R-type) hoặc SignImm ~ immediate (I-type)
    -- Chọn ALU input A dựa trên ALUSrcA_ctrl từ Control Unit (Phân biệt giữa dịch bít và các lệnh khác)
    ------------------------------------------------------------------------
    Shamt_value <= Instruction(10 downto 6);
    Shamt_ext_32 <= (31 downto 5 => '0') & Shamt_value; -- Mở rộng shamt 5-bit thành 32-bit bằng cách điền '0'
    ALU_B <= ReadData2      WHEN ALUSrc = "00" ELSE   -- R-type (arithmetic/logic)
            SignImm        WHEN ALUSrc = "01" ELSE   -- I-type (addi, lw, sw)
            Shamt_ext_32   WHEN ALUSrc = "10" ELSE   -- R-type (shifts)
            (others => '0'); -- Trường hợp mặc định
    
    ALU_A_Input <= ReadData1 WHEN ALUSrcA_ctrl = '0' ELSE ReadData2;
    ------------------------------------------------------------------------
    -- 6. ALU
    ------------------------------------------------------------------------
    ALU_inst: ENTITY work.ALU
        PORT MAP (
            A           => ALU_A_Input, -- từ MUX ALUSrcA (ReadData1 hoặc ReadData2) (in)
            B           => ALU_B,   -- từ MUX ALUSrc (ReadData2 hoặc Immediate hoặc ) (in)
            ALUControl  => ALUControlSig, -- từ ALU Control (in)
            Result      => ALUResult, -- kết quả ALU (out)
            Zero        => Zero -- tín hiệu Zero (out)
        );

    ------------------------------------------------------------------------
    -- 7. Data Memory
    ------------------------------------------------------------------------
    DM_inst: ENTITY work.DataMemory
        PORT MAP (
            clk        => clk, -- xung nhịp cho Data Memory (in)
            MemRead    => MemRead, -- Cho phép đọc từ Data Memory (in)
            MemWrite   => MemWrite, -- Cho phép ghi vào Data Memory (in)
            Address    => ALUResult, -- địa chỉ ô nhớ cần đọc/ghi từ ALU (in)
            WriteData  => ReadData2, -- dữ liệu cần ghi vào Data Memory từ Register File (in)
            ReadData   => MemReadData -- dữ liệu đọc từ Data Memory (out)
        );

    ------------------------------------------------------------------------
    -- 8. MUX WriteBack
    -- Chức năng: Chọn dữ liệu ghi vào Register File (ALUResult hoặc MemReadData)
    ------------------------------------------------------------------------
    WB_mux: ENTITY work.MUX_WriteBack
        PORT MAP (
            ALUResult  => ALUResult, -- kết quả từ ALU (in)
            ReadData   => MemReadData, -- dữ liệu từ Data Memory (in)
            PC_plus_4  => PC_plus_4,   -- Kết nối tín hiệu PC+4 vào đây
            MemToReg   => MemToReg,    -- Tín hiệu điều khiển 2 bit từ Control Unit (in)
            WriteData  => WriteDataReg -- dữ liệu ghi vào Register File (out)
        );

    ------------------------------------------------------------------------
    -- 9. Branch Logic, Jump Logic và PC Update
    ------------------------------------------------------------------------
    -- Tính PC + 4
    PC_plus_4 <= STD_LOGIC_VECTOR(unsigned(PC_out) + 4);
    
    -- Tính Branch Target Address: PC + 4 + (SignImm << 2)
    BranchTarget <= STD_LOGIC_VECTOR(unsigned(PC_plus_4) + unsigned(SignImm(29 DOWNTO 0) & "00"));
    
    -- Tính Jump Address: { (PC+4)[31:28], Instruction[25:0], "00" }
    JumpAddress <= PC_plus_4(31 DOWNTO 28) & Instruction(25 DOWNTO 0) & "00";

    -- Quyết định Branch hay không 
    PCSrc <= '1' WHEN (Branch = '1' AND 
                      ((BranchType = "00" AND Zero = '1') OR    -- beq
                       (BranchType = "01" AND Zero = '0')))     -- bne
             ELSE '0';
    
    -- MUX 1: Chọn giữa (PC+4) và (BranchTarget)
    PC_Branch_Decision <= BranchTarget WHEN PCSrc = '1' ELSE PC_plus_4;

    -- MUX 2: Chọn giữa kết quả MUX 1 và JumpAddress
    -- Nếu Jump = '1' thì ưu tiên nhảy, ngược lại lấy kết quả của Branch/Next
    PC_in <= JumpAddress WHEN Jump = '1' ELSE PC_Branch_Decision;

END ARCHITECTURE;
