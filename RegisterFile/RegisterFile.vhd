library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Khai báo tín hiệu vào ra của Register File
entity RegisterFile is
    port(
        clk      : in  std_logic;                      -- Clock
        RegWrite : in  std_logic;                      -- Cho phép ghi (từ Control Unit)
        ReadReg1 : in  std_logic_vector(4 downto 0);  -- Địa chỉ thanh ghi đọc 1 (rs)
        ReadReg2 : in  std_logic_vector(4 downto 0);  -- Địa chỉ thanh ghi đọc 2 (rt)
        WriteReg : in  std_logic_vector(4 downto 0);  -- Địa chỉ thanh ghi ghi (rd/rt)
        WriteData: in  std_logic_vector(31 downto 0); -- Dữ liệu ghi vào thanh ghi
        ReadData1: out std_logic_vector(31 downto 0); -- Dữ liệu đọc 1 → ALU input A
        ReadData2: out std_logic_vector(31 downto 0)  -- Dữ liệu đọc 2 → ALU input B / Data Memory
    );
end entity RegisterFile;

-- Kiến trúc của Register File
architecture rtl of RegisterFile is
    -- Định nghĩa mảng 32 thanh ghi, mỗi thanh ghi 32-bit
    type reg_file_t is array (31 downto 0) of std_logic_vector(31 downto 0);

    -- Tạo tín hiệu mảng thanh ghi
    signal regs : reg_file_t := (others => (others => '0'));  -- Khởi tạo tất cả = 0

begin
    ------------------------------------------------------------------------
    -- Đọc bất đồng bộ (Asynchronous Read)
    -- Dữ liệu xuất hiện ngay khi địa chỉ thay đổi, không cần chờ clock
    ------------------------------------------------------------------------
    ReadData1 <= regs(to_integer(unsigned(ReadReg1)));
    ReadData2 <= regs(to_integer(unsigned(ReadReg2)));

    ------------------------------------------------------------------------
    -- Ghi đồng bộ (Synchronous Write)
    -- Ghi chỉ xảy ra khi có cạnh lên của clock và RegWrite = 1
    ------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if RegWrite = '1' then -- Cho phép ghi hay không
                if WriteReg /= "00000" then -- Không ghi vào $zero
                    regs(to_integer(unsigned(WriteReg))) <= WriteData;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
