LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MUX_WriteBack IS
    PORT (
        ALUResult  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Kết quả ALU
        ReadData   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); -- Dữ liệu đọc từ bộ nhớ
        MemToReg   : IN  STD_LOGIC; -- Tín hiệu điều khiển chọn nguồn dữ liệu ghi vào thanh ghi
        WriteData  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0) -- Dữ liệu ghi vào thanh ghi
    );
END ENTITY;

ARCHITECTURE behavior OF MUX_WriteBack IS
BEGIN
    PROCESS(ALUResult, ReadData, MemToReg)
    BEGIN
        IF MemToReg = '1' THEN
            WriteData <= ReadData;     -- load word
        ELSE
            WriteData <= ALUResult;    -- R-type
        END IF;
    END PROCESS;
END ARCHITECTURE;
