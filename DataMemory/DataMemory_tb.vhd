--------------------------------------------------------------------------------
-- Testbench: DataMemory_tb
-- Description: Kiểm tra chức năng của Data Memory
--              Test: Ghi dữ liệu vào địa chỉ 0x10 và đọc lại
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataMemory_tb is
end entity;

architecture sim of DataMemory_tb is
    signal clk       : std_logic := '0';
    signal MemWrite  : std_logic := '0';
    signal MemRead   : std_logic := '0';
    signal Address   : std_logic_vector(31 downto 0) := (others => '0');
    signal WriteData : std_logic_vector(31 downto 0) := (others => '0');
    signal ReadData  : std_logic_vector(31 downto 0);

    constant clk_period : time := 10 ns;
begin
    UUT: entity work.DataMemory(rtl)
        generic map(
            DEPTH_WORDS => 256
        )
        port map(
            clk => clk,
            MemRead => MemRead,
            MemWrite => MemWrite,
            Address => Address,
            WriteData => WriteData,
            ReadData => ReadData
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
        -- Test: Ghi dữ liệu 0xCAFEBABE vào địa chỉ 0x10
        -- Địa chỉ byte 0x10 → word index = 4
        ------------------------------------------------------------------------
        Address <= x"00000010";   -- Địa chỉ byte = 16 (0x10)
        WriteData <= x"CAFEBABE"; -- Dữ liệu test
        MemWrite <= '1';          -- Cho phép ghi
        wait for clk_period;      -- Chờ 1 clock cycle
        MemWrite <= '0';          -- Tắt ghi
        wait for clk_period;

        ------------------------------------------------------------------------
        -- Đọc lại dữ liệu từ địa chỉ 0x10
        ------------------------------------------------------------------------
        MemRead <= '1';           -- Cho phép đọc
        wait for clk_period;
        -- Kiểm tra dữ liệu đọc được khớp với dữ liệu đã ghi
        assert ReadData = x"CAFEBABE" report "DM: read mismatch" severity failure;
        MemRead <= '0';           -- Tắt đọc

        report "DataMemory_tb finished" severity note;
        wait;
    end process;
end architecture sim;
