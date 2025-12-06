-- Biên dịch chương trình và testbench:
--   ghdl -a PC.vhd
--   ghdl -a PC_tb.vhd
-- 
-- Chạy mô phỏng:
--   ghdl -e PC_tb
--   ghdl -r PC_tb --vcd=pc_wave.vcd
--   gtkwave pc_wave.vcd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    port(
        clk     : in  STD_LOGIC; -- Clock điều khiển cập nhật
        reset   : in  STD_LOGIC; -- Reset đồng bộ
        PC_in   : in  STD_LOGIC_VECTOR(31 downto 0); -- Địa chỉ mới
        PC_out  : out STD_LOGIC_VECTOR(31 downto 0)  -- Địa chỉ hiện tại của PC
    );
end entity;

architecture Behavioral of PC is
    signal PC_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin

    -----------------------------------------------------------
    -- Cập nhật PC tại cạnh lên của clk 
    -- Reset có ưu tiên cao hơn và được thiết kế đồng bộ
    -----------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then -- Thuật toán latching
            if reset = '1' then
                PC_reg <= (others => '0'); -- Reset về 0
            else
                PC_reg <= PC_in;           -- Cập nhật theo PC_in
            end if;
        end if;
    end process;

    -----------------------------------------------------------
    -- Output
    -----------------------------------------------------------
    PC_out <= PC_reg;

end architecture;
