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
        -- R-type instructions
        0  => x"012A4020",  -- add $t0,$t1,$t2      (10 + 5 = 15)
        1  => x"012A4022",  -- sub $t0,$t1,$t2      (10 - 5 = 5)
        2  => x"012A4024",  -- and $t0,$t1,$t2      (10 & 5 = 0)
        3  => x"012A4025",  -- or  $t0,$t1,$t2      (10 | 5 = 15)
        4  => x"016A402A",  -- slt $t0,$t3,$t2      (3 < 5 = 1)
        
        -- I-type arithmetic/logic instructions
        5  => x"21280005",  -- addi $t0,$t1,5       (10 + 5 = 15)
        6  => x"3128000F",  -- andi $t0,$t1,0x000F  (10 & 15 = 10)
        7  => x"34A800F0",  -- ori  $t0,$t2,0x00F0  (5 | 240 = 245)
        8  => x"292A000F",  -- slti $t0,$t1,15      (10 < 15 = 1)
        
        -- I-type load/store instructions
        9  => x"8C0C0000",  -- lw   $t4,0($zero)    (load from addr 0)
        10 => x"AC090004",  -- sw   $t1,4($zero)    (store to addr 4)
        
        -- I-type branch instructions (offset = 2)
        11 => x"11290002",  -- beq  $t1,$t1,2       (branch if equal)
        12 => x"00000000",  -- nop
        13 => x"00000000",  -- nop
        14 => x"152A0002",  -- bne  $t1,$t2,2       (branch if not equal)
        
        others => x"00000000"  -- nop
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
