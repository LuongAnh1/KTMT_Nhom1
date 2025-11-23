LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SingleCycleCPU_tb IS
END ENTITY;

ARCHITECTURE test OF SingleCycleCPU_tb IS

    SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';

BEGIN

    -- Instantiate CPU
    UUT: ENTITY work.SingleCycleCPU
        PORT MAP(
            clk   => clk,
            reset => reset
        );

    -- Clock: 10ns period
    clk <= NOT clk AFTER 5 ns;

    -- Reset sequence
    PROCESS
    BEGIN
        reset <= '1';
        WAIT FOR 20 ns;
        reset <= '0';
        WAIT;
    END PROCESS;

    -- Stop simulation
    PROCESS
    BEGIN
        WAIT FOR 200 ns;
        REPORT "Simulation finished";
        WAIT;
    END PROCESS;

END ARCHITECTURE;
