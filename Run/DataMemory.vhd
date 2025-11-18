-- Dữ liệu code sẽ nạp từ test bench
-- Hoặc từ data.mem (nếu có)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataMemory is
    generic (
        DEPTH_WORDS : integer := 1024  -- Số lượng words (1024 words = 4KB)
    );
    port (
        clk      : in  std_logic;                      -- Clock
        MemRead  : in  std_logic;                      -- Enable đọc (từ Control Unit)
        MemWrite : in  std_logic;                      -- Enable ghi (từ Control Unit)
        Address  : in  std_logic_vector(31 downto 0); -- Địa chỉ byte (từ ALU)
        WriteData: in  std_logic_vector(31 downto 0); -- Dữ liệu ghi (từ Register File)
        ReadData : out std_logic_vector(31 downto 0)  -- Dữ liệu đọc → WriteBack MUX
    );
end entity DataMemory;

architecture rtl of DataMemory is
    -- Mảng RAM: DEPTH_WORDS × 32-bit
    type ram_t is array (0 to DEPTH_WORDS-1) of std_logic_vector(31 downto 0);
    signal ram : ram_t := (others => (others => '0'));  -- Khởi tạo tất cả = 0
    
    -- Word index (0, 1, 2, ...) từ byte address
    signal addr_index : integer range 0 to DEPTH_WORDS-1;
begin
    ------------------------------------------------------------------------
    -- Chuyển đổi địa chỉ byte thành word index
    -- Địa chỉ byte: 0x...00, 0x...04, 0x...08, 0x...0C, ...
    -- Word index:   0,    1,    2,    3,    ...
    -- Sử dụng bit [11:2] của Address, bỏ qua bit [1:0] (luôn = 00)
    ------------------------------------------------------------------------
    addr_index <= to_integer(unsigned(Address(11 downto 2)));

    ------------------------------------------------------------------------
    -- Đọc kết hợp (Combinational Read)
    -- Dữ liệu xuất hiện ngay khi MemRead = 1
    ------------------------------------------------------------------------
    ReadData <= ram(addr_index) when MemRead = '1' else (others => '0');

    ------------------------------------------------------------------------
    -- Ghi đồng bộ (Synchronous Write)
    -- Chỉ ghi trên cạnh lên của clock khi MemWrite = 1
    ------------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if MemWrite = '1' then
                ram(addr_index) <= WriteData;
            end if;
        end if;
    end process;
end architecture rtl;
