-- Biên dịch chương trình và testbench:
--   ghdl -a InstructionMemory.vhd
--   ghdl -a InstructionMemory_tb.vhd
--
-- Chạy mô phỏng:
--   ghdl -e InstructionMemory_tb
--   ghdl -r InstructionMemory_tb --vcd=imem_wave.vcd
--   gtkwave imem_wave.vcd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;   

entity InstructionMemory is
    port(
        Address     : in  STD_LOGIC_VECTOR(31 downto 0); -- Địa chỉ byte từ PC
        Instruction : out STD_LOGIC_VECTOR(31 downto 0)  -- Lệnh 32 bit
    );
end entity;

architecture Behavioral of InstructionMemory is

    -----------------------------------------------------------
    -- ROM: Mảng hằng các lệnh MIPS (32-bit)
    -----------------------------------------------------------
    type ROM_ARRAY is array (0 to 255) of STD_LOGIC_VECTOR(31 downto 0);
    -- Vị trí nhập lệnh vào ROM
    constant ROM : ROM_ARRAY := (
        0 => x"012A4020",  -- add $t0,$t1,$t2
        1 => x"012A4022",  -- sub $t0,$t1,$t2
        2 => x"012A4024",  -- and $t0,$t1,$t2
        3 => x"012A4025",  -- or  $t0,$t1,$t2
        4 => x"012A402A",  -- slt $t0,$t1,$t2
        others => x"00000000"
    );

begin

    -----------------------------------------------------------
    -- Xuất lệnh tương ứng với Address(31 downto 2) 
    -- Bỏ 2 bít cuối vì 2 bít cuối là chỉ tới vị trí thứ mấy trong từ 4 byte
    -- Quy trình: hex => nhị phân => lấy 31 đến 2 => chuyển sang số nguyên 
    -- Thực hiện dịch phải 2 bit (tương ứng với việc nhân 4 byte) để chuyển địa chỉ byte thành chỉ số word trong ROM
    -----------------------------------------------------------
    Instruction <= ROM(to_integer(unsigned(Address(31 downto 2))));

end architecture;
