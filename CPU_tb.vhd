library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SingleCycleCPU_tb is
end entity;

architecture sim of SingleCycleCPU_tb is
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    -- Debug signals
    signal dbg_we   : std_logic := '0';
    signal dbg_wreg : std_logic_vector(4 downto 0) := (others => '0');
    signal dbg_wdat : std_logic_vector(31 downto 0) := (others => '0');
    signal dbg_rreg : std_logic_vector(4 downto 0) := (others => '0');
    signal dbg_rdat : std_logic_vector(31 downto 0);

begin
    --------------------------------------------------------------------
    -- 1) Instantiate CPU under test
    --------------------------------------------------------------------
    DUT: entity work.SingleCycleCPU
        port map (
            clk => clk,
            reset => reset,
            dbg_write_enable => dbg_we,
            dbg_write_reg    => dbg_wreg,
            dbg_write_data   => dbg_wdat,
            dbg_read_reg     => dbg_rreg,
            dbg_read_data    => dbg_rdat
        );

    --------------------------------------------------------------------
    -- 2) Clock generator: period = 10 ns
    --------------------------------------------------------------------
    clk_process : process
    begin
        while now < 1 ms loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
        wait;
    end process clk_process;

    --------------------------------------------------------------------
    -- 3) Stimulus: reset, init registers, run CPU
    --------------------------------------------------------------------
    stim_proc : process
    begin
        -- Initial reset
        reset <= '1';
        dbg_we <= '0';
        wait for 20 ns;

        ----------------------------------------------------------------
        -- Initialize registers using debug interface
        ----------------------------------------------------------------
        dbg_we <= '1'; -- Enable debug write

        -- $at = 0
        dbg_wreg <= "00001";
        dbg_wdat <= x"00000000";
        wait until rising_edge(clk);

        -- $t0 = 0
        dbg_wreg <= "01000";
        dbg_wdat <= x"00000000";
        wait until rising_edge(clk);

        -- $t1 = 10
        dbg_wreg <= "01001";
        dbg_wdat <= x"0000000A";
        wait until rising_edge(clk);

        -- $t2 = 5
        dbg_wreg <= "01010";
        dbg_wdat <= x"00000005";
        wait until rising_edge(clk);

        -- $t3 = 3
        dbg_wreg <= "01011";
        dbg_wdat <= x"00000003";
        wait until rising_edge(clk);

        -- $t4 = 0
        dbg_wreg <= "01100";
        dbg_wdat <= x"00000000";
        wait until rising_edge(clk);

        dbg_we <= '0'; -- Disable debug write

        report "========================================";
        report "CPU Test Started";
        report "========================================";
        
        -- Read and display initial values
        dbg_rreg <= "01001"; wait for 1 ns;
        report "Initial: $t1 = " & integer'image(to_integer(unsigned(dbg_rdat)));
        
        dbg_rreg <= "01010"; wait for 1 ns;
        report "Initial: $t2 = " & integer'image(to_integer(unsigned(dbg_rdat)));
        
        dbg_rreg <= "01011"; wait for 1 ns;
        report "Initial: $t3 = " & integer'image(to_integer(unsigned(dbg_rdat)));
        report "----------------------------------------";

        ----------------------------------------------------------------
        -- Release reset and run CPU
        ----------------------------------------------------------------
        reset <= '0';
        
        ----------------------------------------------------------------
        -- Test R-type instructions
        ----------------------------------------------------------------
        wait for 10 ns; -- Cycle 1: ADD $t0, $t1, $t2
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 1 (ADD): $t0 = $t1 + $t2 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 2: SUB $t0, $t1, $t2
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 2 (SUB): $t0 = $t1 - $t2 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 3: AND $t0, $t1, $t2
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 3 (AND): $t0 = $t1 & $t2 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 4: OR $t0, $t1, $t2
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 4 (OR):  $t0 = $t1 | $t2 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 5: SLT $t0, $t3, $t2
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 5 (SLT): $t0 = ($t3 < $t2) = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        report "----------------------------------------";

        ----------------------------------------------------------------
        -- Test I-type instructions (Immediate arithmetic/logic)
        ----------------------------------------------------------------
        wait for 10 ns; -- Cycle 6: ADDI $t0, $t1, 5
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 6 (ADDI): $t0 = $t1 + 5 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 7: ANDI $t0, $t1, 0x000F
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 7 (ANDI): $t0 = $t1 & 0x000F = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 8: ORI $t0, $t2, 0x00F0
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 8 (ORI):  $t0 = $t2 | 0x00F0 = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- Cycle 9: SLTI $t0, $t1, 15
        dbg_rreg <= "01000"; wait for 1 ns;
        report "Cycle 9 (SLTI): $t0 = ($t1 < 15) = " & 
               integer'image(to_integer(signed(dbg_rdat)));

        report "----------------------------------------";

        ----------------------------------------------------------------
        -- Test Load/Store instructions
        ----------------------------------------------------------------
        wait for 10 ns; -- Cycle 10: LW $t4, 0($zero)
        dbg_rreg <= "01100"; wait for 1 ns;
        report "Cycle 10 (LW): $t4 = MEM[0]";

        wait for 10 ns; -- Cycle 11: SW $t1, 4($zero)
        report "Cycle 11 (SW): MEM[4] = $t1";

        report "----------------------------------------";

        ----------------------------------------------------------------
        -- Test Branch
        ----------------------------------------------------------------
        wait for 10 ns; -- Cycle 12: BEQ
        report "Cycle 12 (BEQ): Branch test";

        report "========================================";
        report "Testbench completed.";
        report "========================================";
        
        wait;
    end process stim_proc;

end architecture sim;