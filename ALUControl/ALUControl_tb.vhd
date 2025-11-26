library ieee;
use ieee.std_logic_1164.all;

entity ALUCO_tb is
end entity;

architecture tb of ALUCO_tb is

    -- Signals
    signal ALUOp      : std_logic_vector(1 downto 0);
    signal funct      : std_logic_vector(5 downto 0);
    signal ALUControl : std_logic_vector(3 downto 0);

    -- Function to convert std_logic_vector to string
    function slv2string(slv : std_logic_vector) return string is
        variable str : string(1 to slv'length);
    begin
        for i in slv'range loop
            str(i - slv'low + 1) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return str;
    end function;

begin

    -- DUT
    uut: entity work.ALUCO
        port map (
            ALUOp      => ALUOp,
            funct      => funct,
            ALUControl => ALUControl
        );

    -- Test process
    stim: process
    begin
        -- ALUOp = "00" (lw, sw, addi) -> ADD
        ALUOp <= "00"; funct <= "000000";  -- ADD
        wait for 10 ns;
        report "ALUOp=00 (ADD) | ALUControl=" & slv2string(ALUControl) & " (Expected: 0010)";

        -- ALUOp = "01" (beq, bne) -> SUB
        ALUOp <= "01"; funct <= "000000";  -- SUB
        wait for 10 ns;
        report "ALUOp=01 (SUB) | ALUControl=" & slv2string(ALUControl) & " (Expected: 0110)";

        -- ALUOp = "10" (R-type)
        ALUOp <= "10";

        funct <= "100000"; wait for 10 ns;  -- add
        report "R-type ADD (funct=100000) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0010)";

        funct <= "100010"; wait for 10 ns;  -- sub
        report "R-type SUB (funct=100010) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0110)";

        funct <= "100100"; wait for 10 ns;  -- and
        report "R-type AND (funct=100100) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0000)";

        funct <= "100101"; wait for 10 ns;  -- or
        report "R-type OR  (funct=100101) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0001)";

        funct <= "101010"; wait for 10 ns;  -- slt
        report "R-type SLT (funct=101010) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0111)";

        funct <= "111111"; wait for 10 ns;  -- invalid
        report "R-type INVALID (funct=111111) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 1111)";

        -- ALUOp = "11" (immediate logic)
        ALUOp <= "11";

        funct <= "001100"; wait for 10 ns;  -- andi
        report "Immediate ANDI (funct=001100) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0000)";

        funct <= "001101"; wait for 10 ns;  -- ori
        report "Immediate ORI  (funct=001101) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0001)";

        funct <= "001010"; wait for 10 ns;  -- slti
        report "Immediate SLTI (funct=001010) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 0111)";

        funct <= "111111"; wait for 10 ns;  -- invalid
        report "Immediate INVALID (funct=111111) -> ALUControl=" & slv2string(ALUControl) & " (Expected: 1111)";

        report "=== TEST FINISHED ===";
        wait;
    end process;

end architecture;