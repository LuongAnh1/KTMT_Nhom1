LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SingleCycleCPU_tb IS
END ENTITY;

ARCHITECTURE sim OF SingleCycleCPU_tb IS

    -- Clock & Reset
    SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL reset : STD_LOGIC := '1';

    -- Clock period
    CONSTANT PERIOD : time := 10 ns;

BEGIN
    --------------------------------------------------------------------
    -- 1. Tạo xung clock 10ns
    --------------------------------------------------------------------
    clk_process : PROCESS
        BEGIN
            clk <= '0';
            WAIT FOR PERIOD/2;
            clk <= '1';
            WAIT FOR PERIOD/2;
        END PROCESS;


    --------------------------------------------------------------------
    -- 2. Reset CPU trong vài chu kỳ đầu
    --------------------------------------------------------------------
    reset_process : PROCESS
        BEGIN
            WAIT FOR 20 ns;
            reset <= '0';
            WAIT;
        END PROCESS;


    --------------------------------------------------------------------
    -- 3. DUT (CPU TOP)
    --------------------------------------------------------------------
    CPU_inst : ENTITY work.SingleCycleCPU
        PORT MAP (
            clk   => clk,
            reset => reset
        );

END ARCHITECTURE;