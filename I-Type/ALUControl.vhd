library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUCO is
    Port (
        ALUOp      : in  STD_LOGIC_VECTOR(1 downto 0);
        funct      : in  STD_LOGIC_VECTOR(5 downto 0);
        ALUControl : out STD_LOGIC_VECTOR(3 downto 0)   -- 4-bit
    );
end ALUCO;

architecture Behavioral of ALUCO is
begin
    process(ALUOp, funct)
    begin
        case ALUOp is
            
            -------------------------------------------------
            -- 00 ⇒ ADD (lw, sw, addi)
            -------------------------------------------------
            when "00" =>
                ALUControl <= "0010";  -- ADD

            -------------------------------------------------
            -- 01 ⇒ SUB (beq, bne)
            -------------------------------------------------
            when "01" =>
                ALUControl <= "0110";  -- SUB

            -------------------------------------------------
            -- 10 ⇒ R-type
            -------------------------------------------------
            when "10" =>
                case funct is
                    when "100000" => ALUControl <= "0010"; -- ADD
                    when "100010" => ALUControl <= "0110"; -- SUB
                    when "100100" => ALUControl <= "0000"; -- AND
                    when "100101" => ALUControl <= "0001"; -- OR
                    when "101010" => ALUControl <= "0111"; -- SLT
                    when others   => ALUControl <= "1111"; -- UNKNOWN
                end case;

            -------------------------------------------------
            -- 11 ⇒ immediate logic
            -------------------------------------------------
            when "11" =>
                -- cần phân loại thêm nếu muốn hỗ trợ ori/slti riêng
                ALUControl <= "0000"; -- ví dụ: AND

            when others =>
                ALUControl <= "1111";

        end case;
    end process;
end Behavioral;

