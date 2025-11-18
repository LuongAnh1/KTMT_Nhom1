library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SingleCycleCPU_tb is
end entity;

architecture sim of SingleCycleCPU_tb is

    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

begin
    --------------------------------------------------------------------
    -- 1) Instantiate CPU under test (name DUT)
    --------------------------------------------------------------------
    DUT: entity work.SingleCycleCPU
        port map (
            clk   => clk,
            reset => reset
        );

    --------------------------------------------------------------------
    -- 2) Clock generator: period = 10 ns (5 ns low, 5 ns high)
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
    -- 3) Stimulus: reset, init registers $t1($9) and $t2($10), run CPU
    --------------------------------------------------------------------
    stim_proc : process
        -- helper to show register value as signed integer
        function to_signed_int(v : std_logic_vector(31 downto 0)) return integer is
        begin
            return to_integer(signed(v));
        end function;

        -- helper to show register value as unsigned integer
        function to_unsigned_int(v : std_logic_vector(31 downto 0)) return integer is
        begin
            return to_integer(unsigned(v));
        end function;
    begin
        -- initial reset asserted
        reset <= '1';
        wait for 20 ns;

        -- release reset
        reset <= '0';

        -- Give a small time for elaboration and allow direct writes into regs
        wait for 2 ns;

        ----------------------------------------------------------------
        -- Initialize registers $t1 ($9) and $t2 ($10)
        -- $t1 = 5, $t2 = 3  (you can change values here)
        ----------------------------------------------------------------
        DUT.RF_inst.regs(9)  <= x"00000005"; -- $t1 = 5
        DUT.RF_inst.regs(10) <= x"00000003"; -- $t2 = 3

        report "Initialized: $t1 = " &
               integer'image(to_unsigned_int(DUT.RF_inst.regs(9))) &
               ", $t2 = " & integer'image(to_unsigned_int(DUT.RF_inst.regs(10)));

        -- Wait 1 clock cycle to let CPU fetch and execute 1st instruction (ADD)
        wait for 10 ns;
        report "After 1st cycle (ADD):  $t0 = " & integer'image(to_signed_int(DUT.RF_inst.regs(8)));

        -- 2nd instruction (SUB)
        wait for 10 ns;
        report "After 2nd cycle (SUB):  $t0 = " & integer'image(to_signed_int(DUT.RF_inst.regs(8)));

        -- 3rd instruction (AND)
        wait for 10 ns;
        report "After 3rd cycle (AND):  $t0 = " & integer'image(to_signed_int(DUT.RF_inst.regs(8)));

        -- 4th instruction (OR)
        wait for 10 ns;
        report "After 4th cycle (OR):   $t0 = " & integer'image(to_signed_int(DUT.RF_inst.regs(8)));

        -- 5th instruction (SLT)
        wait for 10 ns;
        report "After 5th cycle (SLT):  $t0 = " & integer'image(to_signed_int(DUT.RF_inst.regs(8)));

        ----------------------------------------------------------------
        -- Optionally dump all registers for inspection
        ----------------------------------------------------------------
        report "Registers ($0..$10):";
        for i in 0 to 10 loop
            report "  $" & integer'image(i) & " = " & integer'image(to_signed_int(DUT.RF_inst.regs(i)));
        end loop;

        -- End simulation
        report "Simulation completed." severity note;
        wait;
    end process stim_proc;

end architecture sim;
