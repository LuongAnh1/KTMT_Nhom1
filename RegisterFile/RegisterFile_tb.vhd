--------------------------------------------------------------------------------
-- Testbench: RegisterFile_tb
-- Description: Kiểm tra chức năng của Register File
--              Test 1: Ghi và đọc lại thanh ghi thường
--              Test 2: Kiểm tra bảo vệ thanh ghi $0
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFile_tb is
end entity;

architecture sim of RegisterFile_tb is
    signal clk       : std_logic := '0';
    signal RegWrite  : std_logic := '0';
    signal ReadReg1  : std_logic_vector(4 downto 0) := (others => '0');
    signal ReadReg2  : std_logic_vector(4 downto 0) := (others => '0');
    signal WriteReg  : std_logic_vector(4 downto 0) := (others => '0');
    signal WriteData : std_logic_vector(31 downto 0) := (others => '0');
    signal ReadData1 : std_logic_vector(31 downto 0);
    signal ReadData2 : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin
    UUT: entity work.RegisterFile(rtl)
        port map(
            clk => clk,
            RegWrite => RegWrite,
            ReadReg1 => ReadReg1,
            ReadReg2 => ReadReg2,
            WriteReg => WriteReg,
            WriteData => WriteData,
            ReadData1 => ReadData1,
            ReadData2 => ReadData2
        );

    clk_proc: process
    begin
        while true loop
            clk <= '0'; wait for clk_period/2;
            clk <= '1'; wait for clk_period/2;
        end loop;
    end process;

    stim: process
    begin
        ------------------------------------------------------------------------
        -- Test 1: Ghi vào thanh ghi reg5 và đọc lại
        ------------------------------------------------------------------------
        wait for 20 ns;
        WriteReg <= std_logic_vector(to_unsigned(5,5));  -- Chọn reg5
        WriteData <= x"DEADBEEF";                       -- Dữ liệu test
        RegWrite <= '1';                                 -- Cho phép ghi
        wait for clk_period;                             -- Chờ 1 clock cycle
        RegWrite <= '0';                                 -- Tắt ghi
        wait for 10 ns;

        -- Đọc lại reg5 và reg0
        ReadReg1 <= std_logic_vector(to_unsigned(5,5));  -- Đọc reg5
        ReadReg2 <= std_logic_vector(to_unsigned(0,5));  -- Đọc reg0 ($zero)
        wait for 10 ns;
        assert ReadData1 = x"DEADBEEF" report "RF: readback mismatch" severity failure;

        ------------------------------------------------------------------------
        -- Test 2: Thử ghi vào $0 (phải bị chặn)
        ------------------------------------------------------------------------
        WriteReg <= (others => '0');  -- Chọn reg0 ($zero)
        WriteData <= x"12345678";    -- Thử ghi dữ liệu
        RegWrite <= '1';              -- Cho phép ghi
        wait for clk_period;
        RegWrite <= '0';
        wait for 10 ns;
        -- Kiểm tra $0 vẫn = 0 (không bị ghi đè)
        assert ReadData2 = x"00000000" report "RF: $0 modified" severity failure;

        report "RegisterFile_tb finished" severity note;
        wait;
    end process;
end architecture sim;