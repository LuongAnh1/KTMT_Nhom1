library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity InstructionMemory_tb is
end entity;

architecture Behavioral of InstructionMemory_tb is

    -- Tín hiệu mô phỏng
    signal addr        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instruction : STD_LOGIC_VECTOR(31 downto 0);

begin

    ---------------------------------------------------------------------------
    -- Kết nối Unit Under Test (UUT) - khối InstructionMemory
    ---------------------------------------------------------------------------
    uut: entity work.InstructionMemory
        port map(
            Address     => addr,
            Instruction => instruction
        );

    ---------------------------------------------------------------------------
    -- Kịch bản mô phỏng:
    -- Đưa vào các địa chỉ lệnh khác nhau và xem nội dung Instruction tương ứng
    ---------------------------------------------------------------------------
    stim_proc: process
    begin
        -- Địa chỉ 0 (PC = 0) -> ROM[0] = lw $2, 4($1)
        addr <= x"00000000";
        wait for 10 ns;

        -- Địa chỉ 4 (PC = 4) -> ROM[1] = add $4, $2, $3
        addr <= x"00000004";
        wait for 10 ns;

        -- Địa chỉ 8 (PC = 8) -> ROM[2] = sub $5, $3, $4
        addr <= x"00000008";
        wait for 10 ns;

        -- Địa chỉ 12 (PC = 12) -> ROM[3] = sw $5, 8($1)
        addr <= x"0000000C";
        wait for 10 ns;

        -- Địa chỉ chưa khởi tạo (ví dụ 16) -> ROM[4] = nop
        addr <= x"00000010";
        wait for 10 ns;

        -- Kết thúc mô phỏng
        wait;
    end process;

end architecture;
