library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALUControl_tb is
end ALUControl_tb;

architecture sim of ALUControl_tb is
    signal ALUOp     : STD_LOGIC_VECTOR(1 downto 0);
    signal funct     : STD_LOGIC_VECTOR(5 downto 0);
    signal ALUControl: STD_LOGIC_VECTOR(2 downto 0);
begin

    uut: entity work.ALUCO
        port map (ALUOp => ALUOp, funct => funct, ALUControl => ALUControl);

    stim_proc: process
    begin
        ALUOp <= "00"; funct <= "000000"; wait for 10 ns;
        assert ALUControl = "010";

        ALUOp <= "01"; funct <= "000000"; wait for 10 ns;
        assert ALUControl = "110";

        ALUOp <= "10"; funct <= "100000"; wait for 10 ns;
        assert ALUControl = "010";

        ALUOp <= "10"; funct <= "100010"; wait for 10 ns;
        assert ALUControl = "110";

        ALUOp <= "10"; funct <= "100100"; wait for 10 ns;
        assert ALUControl = "000";

        ALUOp <= "10"; funct <= "100101"; wait for 10 ns;
        assert ALUControl = "001";

        ALUOp <= "10"; funct <= "101010"; wait for 10 ns;
        assert ALUControl = "111";

        ALUOp <= "10"; funct <= "111111"; wait for 10 ns;
        assert ALUControl = "010";

        ALUOp <= "11"; funct <= "000000"; wait for 10 ns;
        assert ALUControl = "010";

        report "ALUControl simulation completed";
        wait;
    end process;

end sim;