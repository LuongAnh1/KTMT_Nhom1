-- ===========================================================
-- ghdl -a CU.vhd
-- ghdl -a CU_tb.vhd
-- ghdl -e ControlUnit_tb
-- ghdl -r ControlUnit_tb --wave=CU_tb.ghw
-- ===========================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ControlUnit IS
    PORT (
        opcode    : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
        funct_in  : IN  STD_LOGIC_VECTOR(5 DOWNTO 0); -- Thêm funct vào đây
        RegDst      : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        MemToReg    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); 
        -- ALUSrc    : OUT STD_LOGIC;
        ALUSrc_ctrl : OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- Mới: Điều khiển 2-bit
        RegWrite  : OUT STD_LOGIC;
        MemRead   : OUT STD_LOGIC;
        MemWrite  : OUT STD_LOGIC;
        Branch    : OUT STD_LOGIC;
        BranchType: OUT STD_LOGIC_VECTOR(1 DOWNTO 0); -- 00=beq, 01=bne
        Jump      : OUT STD_LOGIC;  -- cho J-type
        ALUSrcA   : OUT STD_LOGIC; -- Mới: Chọn đầu vào A cho ALU (0=ReadData1, 1=ReadData2)
        ALUOp     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ControlUnit;

ARCHITECTURE Behavioral OF ControlUnit IS
BEGIN
    process(opcode, funct_in)
    BEGIN
        -- ==== MẶC ĐỊNH (Tránh Latch) ====
        RegDst      <= "00";   -- 00: rt, 01: rd, 10: $ra
        ALUSrc_ctrl <= "00";  -- 00: ReadData2, 01: Imm, 10: Shamt
        MemToReg    <= "00";   -- 00: ALU, 01: Mem, 10: PC+4
        RegWrite    <= '0';
        MemRead     <= '0';
        MemWrite    <= '0';
        Branch      <= '0';
        BranchType  <= "00";
        Jump        <= '0';
        ALUSrcA     <= '0';   -- 0: ReadData1 (rs), 1: ReadData2 (rt - cho Shift)
        ALUOp       <= "00";  -- 00: Add/Load/Store, 01: Branch, 10: R-type, 11: I-type Logic


        CASE opcode IS
            -----------------------------------------
            -- R?TYPE
            -----------------------------------------
            WHEN "000000" =>  -- R-TYPE
                RegDst   <= "01";  -- Chọn rd
                RegWrite <= '1';
                ALUOp    <= "10";
                CASE funct_in IS
                    WHEN "000000" | "000010" | "000011" => -- sll, srl, sra
                        ALUSrcA     <= '1';   -- Chọn ReadData2 cho ALU A
                        ALUSrc_ctrl <= "10";  -- Chọn Shamt_ext_32
                    WHEN OTHERS =>
                        ALUSrcA     <= '0';   -- Chọn ReadData1 cho ALU A (mặc định R-type)
                        ALUSrc_ctrl <= "00";  -- Chọn ReadData2 (cho R-type arith/logic)
                END CASE;

            -----------------------------------------
            -- I?TYPE LOAD
            -----------------------------------------
            WHEN "100011" =>  -- lw
                ALUSrc_ctrl   <= "01"; -- Chọn Imm_ext_32
                MemToReg <= "01"; -- Chọn dữ liệu từ Memory
                RegWrite <= '1';
                MemRead  <= '1';
                ALUOp    <= "00";

            -----------------------------------------
            -- I?TYPE STORE
            -----------------------------------------
            WHEN "101011" =>  -- sw
                ALUSrc_ctrl   <= "01";
                MemWrite <= '1'; -- Chọn ghi dữ liệu vào Memory
                ALUOp    <= "00";

            -----------------------------------------
            -- I?TYPE BRANCH
            -----------------------------------------
            WHEN "000100" =>  -- beq
                Branch   <= '1';
                BranchType <= "00"; -- beq
                ALUOp    <= "01";

            WHEN "000101" =>  -- bne
                Branch   <= '1';
                BranchType <= "01"; -- bne
                ALUOp    <= "01"; 

            ---------------------------------------------------------
            -- I-TYPE IMMEDIATE ARITH/LOGIC
            ---------------------------------------------------------
            WHEN "001000" => -- addi
                ALUSrc_ctrl   <= "01";
                RegWrite <= '1';
                ALUOp    <= "00";  

            WHEN "001100" => -- andi
                ALUSrc_ctrl   <= "01";
                RegWrite <= '1';
                ALUOp    <= "11";     -- AND

            WHEN "001101" => -- ori
                ALUSrc_ctrl   <= "01";
                RegWrite <= '1';
                ALUOp    <= "11";     -- OR

            WHEN "001010" => -- slti
                ALUSrc_ctrl   <= "01";
                RegWrite <= '1';
                ALUOp    <= "11";   


            -----------------------------------------
            -- J?TYPE
            -----------------------------------------
            WHEN "000010" =>  -- j
                Jump <= '1';

            WHEN "000011" => -- jal
                Jump     <= '1';
                RegWrite <= '1';      -- Cho phép ghi
                RegDst   <= "10";     -- Chọn thanh ghi 31 ($ra)
                MemToReg <= "10";     -- Chọn dữ liệu là PC+4  

            WHEN OTHERS =>
                NULL;
        END CASE;
    END PROCESS;
END Behavioral;
