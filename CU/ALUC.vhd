--ghdl -a ALUC.vhd
--ghdl -a ALUControl_tb.vhd
--ghdl -e ALUControl_tb
--ghdl -r ALUControl_tb --stop-time=200ns
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUCO is
    Port (
        ALUOp      : in  STD_LOGIC_VECTOR(1 downto 0);  -- t? CU
        funct      : in  STD_LOGIC_VECTOR(5 downto 0);  -- Instruction(5 downto 0)
        ALUControl : out STD_LOGIC_VECTOR(2 downto 0)   -- 3-bit ?i?u khi?n ALU
    );
end ALUCO;

architecture Behavioral of ALUCO is
begin

    process(ALUOp, funct)
        variable ctrl : STD_LOGIC_VECTOR(2 downto 0);
    begin
        case ALUOp is
            when "00" =>  -- lw/sw ? ADD
                ctrl := "010";
            when "01" =>  -- beq ? SUB
                ctrl := "110";
            when "10" =>  -- R-type ? gi?i mã funct
                case funct is
                    when "100000" => ctrl := "010";  -- add
                    when "100010" => ctrl := "110";  -- sub
                    when "100100" => ctrl := "000";  -- and
                    when "100101" => ctrl := "001";  -- or
                    when "101010" => ctrl := "111";  -- slt
                    when others   => ctrl := "010";  -- default: add
                end case;
            when others =>
                ctrl := "010";  -- default: add
        end case;

        ALUControl <= ctrl;
    end process;

end Behavioral;