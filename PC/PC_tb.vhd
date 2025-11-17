library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_tb is
    -- Testbench không có cổng vào/ra
end entity;

architecture Behavioral of PC_tb is
    -- Tín hiệu mô phỏng
    signal clk    : STD_LOGIC := '0';
    signal reset  : STD_LOGIC := '0';
    signal PC_in  : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal PC_out : STD_LOGIC_VECTOR(31 downto 0);

    constant CLK_PERIOD : time := 10 ns;
begin

    ---------------------------------------------------------------------------
    -- Kết nối Unit Under Test (UUT) - khối PC
    ---------------------------------------------------------------------------
    uut: entity work.PC
        port map(
            clk     => clk,
            reset   => reset,
            PC_in   => PC_in,
            PC_out  => PC_out
        );

    ---------------------------------------------------------------------------
    -- Tạo xung clock: 50% duty cycle
    ---------------------------------------------------------------------------
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait; -- tránh bị lặp lại
    end process;

    ---------------------------------------------------------------------------
    -- Kịch bản mô phỏng
    ---------------------------------------------------------------------------
    stim_proc: process
    begin
        -- Đặt reset ban đầu
        reset <= '1';
        wait for CLK_PERIOD * 2;  -- giữ reset trong 2 chu kỳ

        -- Hủy reset, bắt đầu ghi dữ liệu
        reset <= '0';
        PC_in <= x"00000004"; -- Giá trị PC_in = 4
        wait for CLK_PERIOD;

        -- Cập nhật giá trị mới
        PC_in <= x"00000010"; -- Giá trị PC_in = 16
        wait for CLK_PERIOD;

        -- Tiếp tục mô phỏng thêm
        wait for CLK_PERIOD * 2;

        -- Kết thúc mô phỏng
        wait;
    end process;

end architecture;
