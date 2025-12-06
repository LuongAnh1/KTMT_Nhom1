LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MUX_WriteBack IS
    PORT (
        ALUResult  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        ReadData   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_plus_4  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- MỚI: Thêm cổng này
        MemToReg   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);  -- SỬA: 2 bit
        WriteData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END MUX_WriteBack;

ARCHITECTURE Behavioral OF MUX_WriteBack IS
BEGIN
    -- 00: ALU, 01: RAM, 10: PC+4 (cho jal)
    WriteData <= ALUResult WHEN MemToReg = "00" ELSE
                 ReadData  WHEN MemToReg = "01" ELSE
                 PC_plus_4 WHEN MemToReg = "10" ELSE
                 (OTHERS => '0');
END Behavioral;