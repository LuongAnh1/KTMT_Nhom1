-- ============================================================
-- ALUCO_tb.vhd ? Testbench cho ALUCO
-- ============================================================

library ieee;
use ieee.std_logic_1164.all;

entity ALUCO_tb is
end entity;

architecture tb of ALUCO_tb is

    -- Signals
    signal ALUOp      : std_logic_vector(1 downto 0);
    signal funct      : std_logic_vector(5 downto 0);
    signal ALUControl : std_logic_vector(3 downto 0);

    -- Hàm chuy?n std_logic_vector -> string ?? in
    function slv2string(slv : std_logic_vector) return string is
        variable str : string(1 to slv'length);
    begin
        for i in slv'range loop
            str(i - slv'low + 1) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return str;
    end function;

begin

    -- N?i DUT
    uut: entity work.ALUCO
        port map (
            ALUOp      => ALUOp,
            funct      => funct,
            ALUControl => ALUControl
        );

    -- Process test
    stim: process
    begin
        -------------------------------------------------------------------
        -- ALUOp = "00" (lw, sw, addi) -> ADD
        -------------------------------------------------------------------
        ALUOp <= "00"; funct <= "000000";
        wait for 10 ns;
        report "ALUOp=00 | funct=" & slv2string(funct) & " | ALUControl=" & slv2string(ALUControl);

        -------------------------------------------------------------------
        -- ALUOp = "01" (beq, bne) -> SUB
        -------------------------------------------------------------------
        ALUOp <= "01"; funct <= "000000";
        wait for 10 ns;
        report "ALUOp=01 | funct=" & slv2string(funct) & " | ALUControl=" & slv2string(ALUControl);

        -------------------------------------------------------------------
        -- ALUOp = "10" (R-type) -> check các funct
        -------------------------------------------------------------------
        ALUOp <= "10";

        funct <= "100000"; wait for 10 ns;  -- add
        report "R-type funct=100000 -> ALUControl=" & slv2string(ALUControl);

        funct <= "100010"; wait for 10 ns;  -- sub
        report "R-type funct=100010 -> ALUControl=" & slv2string(ALUControl);

        funct <= "100100"; wait for 10 ns;  -- and
        report "R-type funct=100100 -> ALUControl=" & slv2string(ALUControl);

        funct <= "100101"; wait for 10 ns;  -- or
        report "R-type funct=100101 -> ALUControl=" & slv2string(ALUControl);

        funct <= "101010"; wait for 10 ns;  -- slt
        report "R-type funct=101010 -> ALUControl=" & slv2string(ALUControl);

        funct <= "111111"; wait for 10 ns;  -- invalid
        report "R-type funct=111111 -> ALUControl=" & slv2string(ALUControl);

        -------------------------------------------------------------------
        -- ALUOp = "11" (immediate logic) ? check các funct
        -------------------------------------------------------------------
        ALUOp <= "11";

        funct <= "001100"; wait for 10 ns;  -- andi
        report "Immediate funct=001100 -> ALUControl=" & slv2string(ALUControl);

        funct <= "001101"; wait for 10 ns;  -- ori
        report "Immediate funct=001101 -> ALUControl=" & slv2string(ALUControl);

        funct <= "001010"; wait for 10 ns;  -- slti
        report "Immediate funct=001010 -> ALUControl=" & slv2string(ALUControl);

        funct <= "111111"; wait for 10 ns;  -- invalid
        report "Immediate funct=111111 -> ALUControl=" & slv2string(ALUControl);

        -------------------------------------------------------------------
        report "TEST FINISHED";
        wait;
    end process;

end architecture;
