library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aluco is
    Port (
        ALUOp     : in  STD_LOGIC_VECTOR(1 downto 0);  -- tu Control Unit
        func      : in  STD_LOGIC_VECTOR(5 downto 0);  -- Instruction(5 downto 0)
        ALUControl: out STD_LOGIC_VECTOR(2 downto 0)   -- mã dieu khien ALU: 3-bit
    );
end aluco;

architecture Behavioral of aluco is
begin

    process(ALUOp, func)
    begin
        case ALUOp is
            when "00" =>               -- lw/sw: ALU làm add (A + B)
                ALUControl <= "010";   -- ADD

            when "01" =>               -- beq: ALU làm subtract (A - B)
                ALUControl <= "110";   -- SUB

            when "10" =>               -- R-type: dùng func ?? quy?t ??nh
                case func is
                    when "100000" => ALUControl <= "010"; -- ADD
                    when "100010" => ALUControl <= "110"; -- SUB
                    when "100100" => ALUControl <= "000"; -- AND
                    when "100101" => ALUControl <= "001"; -- OR
                    when "101010" => ALUControl <= "111"; -- SLT (set on less than)
                    when "100110" => ALUControl <= "011"; -- XOR
                    when others  => ALUControl <= "010";  -- default: ADD
                end case;

            when others =>             -- fallback
                ALUControl <= "010";   -- ADD

        end case;
    end process;

end Behavioral;