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
        variable ctrl : STD_LOGIC_VECTOR(3 downto 0);
    begin
        case ALUOp is
            when "00" =>  -- lw/sw → ADD
                ctrl := "0010";
            when "01" =>  -- beq → SUB
                ctrl := "0110";
            when "10" =>  -- R-type → dựa vào funct
                case funct is
                    when "100000" => ctrl := "0010";  -- add
                    when "100010" => ctrl := "0110";  -- sub
                    when "100100" => ctrl := "0000";  -- and
                    when "100101" => ctrl := "0001";  -- or
                    when "101010" => ctrl := "0111";  -- slt

                    when "000000" => ctrl := "1000";  -- SLL
                    when "000010" => ctrl := "1001";  -- SRL
                    when "000011" => ctrl := "1010";  -- SRA
                    
                    when others   => ctrl := "0010";  -- default add
                end case;
            when others =>
                ctrl := "0010";
        end case;

        ALUControl <= ctrl;
    end process;

end Behavioral;
