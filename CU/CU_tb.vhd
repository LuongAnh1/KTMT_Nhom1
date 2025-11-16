-- ===========================================================
-- Testbench cho khối Control Unit (CU)
-- File: ControlUnit_tb.vhd
-- Mục đích: Mô phỏng CU, kiểm tra tín hiệu xuất ra theo opcode
-- ===========================================================

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ControlUnit_tb IS
END ControlUnit_tb;

ARCHITECTURE Behavioral OF ControlUnit_tb IS
    SIGNAL opcode    : STD_LOGIC_VECTOR(5 DOWNTO 0);
    SIGNAL RegDst    : STD_LOGIC;
    SIGNAL ALUSrc    : STD_LOGIC;
    SIGNAL MemToReg  : STD_LOGIC;
    SIGNAL RegWrite  : STD_LOGIC;
    SIGNAL MemRead   : STD_LOGIC;
    SIGNAL MemWrite  : STD_LOGIC;
    SIGNAL Branch    : STD_LOGIC;
    SIGNAL ALUOp     : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN
    CU_inst: ENTITY work.ControlUnit
        PORT MAP (
            opcode    => opcode,
            RegDst    => RegDst,
            ALUSrc    => ALUSrc,
            MemToReg  => MemToReg,
            RegWrite  => RegWrite,
            MemRead   => MemRead,
            MemWrite  => MemWrite,
            Branch    => Branch,
            ALUOp     => ALUOp
        );

    process
    begin
        opcode <= "000000"; wait for 50 ns;  -- R-type
        opcode <= "100011"; wait for 50 ns;  -- lw
        opcode <= "101011"; wait for 50 ns;  -- sw
        opcode <= "000100"; wait for 50 ns;  -- beq
        opcode <= "111111"; wait for 50 ns;  -- Others
        wait;
    end process;
END Behavioral;
