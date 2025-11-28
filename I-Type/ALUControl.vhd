library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUCO is
    Port (
        ALUOp      : in  STD_LOGIC_VECTOR(1 downto 0);
        funct      : in  STD_LOGIC_VECTOR(5 downto 0);
        opcode     : in  STD_LOGIC_VECTOR(5 downto 0);
        ALUControl : out STD_LOGIC_VECTOR(3 downto 0)   -- 4-bit
    );
end ALUCO;

architecture Behavioral of ALUCO is
begin
    process(ALUOp, funct)
    begin
        case ALUOp is
            -------------------------------------------------
            -- ALUOp = "00" ? ADD (lw, sw, addi)
            -------------------------------------------------
            when "00" =>
                ALUControl <= "0010";  -- ADD
            
            -------------------------------------------------
            -- ALUOp = "01" ? SUB (beq, bne)
            -------------------------------------------------
            when "01" =>
                ALUControl <= "0110";  -- SUB

            -------------------------------------------------
            -- ALUOp = "10" ? R-type, d?a v�o funct
            -------------------------------------------------
            when  "10" =>
                case funct is
                    when "100000" => ALUControl <= "0010";  -- add
                    when "100010" => ALUControl <= "0110";  -- sub
                    when "100100" => ALUControl <= "0000";  -- and
                    when "100101" => ALUControl <= "0001";  -- or
                    when "100110" => ALUControl <= "0100";  -- xor
                    when "100111" => ALUControl <= "1100";  -- NOR
                    when "000000" => ALUControl <= "1000";  -- sll
                    when "000010" => ALUControl <= "1001";  -- srl
                    when "000011" => ALUControl <= "1010";  -- sra
                    when "101010" => ALUControl <= "0111";  -- slt
                    when others   => ALUControl <= "1111";  -- kh�ng x�c ??nh
                end case;

            -------------------------------------------------
            -- ALUOp = "11" ? nh�m immediate logic (andi/ori/slti)
            -------------------------------------------------
            when "11" =>
                case opcode is
                    when "001100" => ALUControl <= "0000";  -- andi ? AND
                    when "001101" => ALUControl <= "0001";  -- ori  ? OR
                    when "001010" => ALUControl <= "0111";  -- slti ? SLT
                    when others   => ALUControl <= "1111";
                end case;

            when others =>
                ALUControl <= "1111";
                
        end case;
    end process;
end Behavioral;
