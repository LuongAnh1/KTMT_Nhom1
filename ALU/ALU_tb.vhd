library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_tb is
end entity;

architecture sim of ALU_tb is

    signal A_tb, B_tb       : STD_LOGIC_VECTOR(31 downto 0);
    signal ALUControl_tb    : STD_LOGIC_VECTOR(3 downto 0);
    signal Result_tb        : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero_tb          : STD_LOGIC;

begin

    U_ALU : entity work.ALU
        port map(
            A          => A_tb,
            B          => B_tb,
            ALUControl => ALUControl_tb,
            Result     => Result_tb,
            Zero       => Zero_tb
        );

    -- Test process
    stim_proc : process
    begin
        
        -- Test ADD
        A_tb          <= x"00000005";
        B_tb          <= x"00000003";
        ALUControl_tb <= "0010";   -- ADD
        wait for 10 ns;

        -- Test SUB
        A_tb          <= x"0000000A";
        B_tb          <= x"00000003";
        ALUControl_tb <= "0110";   -- SUB
        wait for 10 ns;

        -- Test AND
        A_tb          <= x"0000FFFF";
        B_tb          <= x"00FF00FF";
        ALUControl_tb <= "0000";   -- AND
        wait for 10 ns;

        -- Test OR
        A_tb          <= x"0000F0F0";
        B_tb          <= x"00FF00FF";
        ALUControl_tb <= "0001";   -- OR
        wait for 10 ns;

        -- Test SLT
        A_tb          <= x"FFFFFFFF"; -- -1
        B_tb          <= x"00000001";
        ALUControl_tb <= "0111";      -- SLT
        wait for 10 ns;

        wait;
    end process;

end architecture;
