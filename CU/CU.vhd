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
        RegDst    : OUT STD_LOGIC;
        ALUSrc    : OUT STD_LOGIC;
        MemToReg  : OUT STD_LOGIC;
        RegWrite  : OUT STD_LOGIC;
        MemRead   : OUT STD_LOGIC;
        MemWrite  : OUT STD_LOGIC;
        Branch    : OUT STD_LOGIC;
        ALUOp     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END ControlUnit;

ARCHITECTURE Behavioral OF ControlUnit IS
BEGIN
    process(opcode)
    BEGIN
        -- Mac dinh tat ca tín hieu bang 0
        RegDst   <= '0';
        ALUSrc   <= '0';
        MemToReg <= '0';
        RegWrite <= '0';
        MemRead  <= '0';
        MemWrite <= '0';
        Branch   <= '0';
        ALUOp    <= "00";

        CASE opcode IS
            WHEN "000000" =>  -- R-type
                RegDst   <= '1';
                ALUSrc   <= '0';
                MemToReg <= '0';
                RegWrite <= '1';
                ALUOp    <= "10";

            WHEN "100011" =>  -- lw
                RegDst   <= '0';
                ALUSrc   <= '1';
                MemToReg <= '1';
                RegWrite <= '1';
                MemRead  <= '1';
                ALUOp    <= "00";

            WHEN "101011" =>  -- sw
                ALUSrc   <= '1';
                MemWrite <= '1';
                ALUOp    <= "00";

            WHEN "000100" =>  -- beq
                Branch   <= '1';
                ALUOp    <= "01";

            WHEN OTHERS =>
                NULL;
        END CASE;
    END PROCESS;
END Behavioral;
