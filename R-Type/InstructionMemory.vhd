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
        ------------------------------------------------------------------
        -- Khởi tạo giá trị cho các thanh ghi bằng addi
        ------------------------------------------------------------------
        0 => x"20080005",   -- addi $t0, $zero, 5     ($t0 = 5)
        1 => x"20090008",   -- addi $t1, $zero, 8     ($t1 = 8)
        2 => x"200A000C",   -- addi $t2, $zero, 12    ($t2 = 12)

        3 => x"01095820",   -- add  $t3, $t0, $t1
        4 => x"01486022",   -- sub  $t4, $t2, $t0
        5 => x"01096824",   -- and  $t5, $t0, $t1
        6 => x"01097025",   -- or   $t6, $t0, $t1
        7 => x"01097826",   -- xor  $t7, $t0, $t1
        8 => x"01098027",   -- nor  $t8, $t0, $t1
        9 => x"0109882A",   -- slt  $t9, $t0, $t1
        10 => x"00088080",  -- sll  $s0, $t0, 2
        11 => x"000A8842",  -- srl  $s1, $t2, 1
        OTHERS => x"00000000"
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
