library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SingleCycleCPU_tb is
end entity;

architecture sim of SingleCycleCPU_tb is
    signal clk   : std_logic := '0';
    signal reset : std_logic := '1';

    signal dbg_we   : std_logic := '0';
    signal dbg_wreg : std_logic_vector(4 downto 0);
    signal dbg_wdat : std_logic_vector(31 downto 0);
    signal dbg_rreg : std_logic_vector(4 downto 0);
    signal dbg_rdat : std_logic_vector(31 downto 0);
begin
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

    clk <= not clk after 5 ns;

    process
    begin
        reset <= '1';
        

        ------------------------------------------------------------------
        -- INIT $t1 = 5, $t2 = 3
        -- Nạp dữ liệu cho thanh ghi trước khi chạy chương trình
        ------------------------------------------------------------------
        dbg_we   <= '1'; -- Kích hoạt debug write để nạp dữ liệu

        dbg_wreg <= "01001";  -- $t1 = 9
        dbg_wdat <= x"00000005";
        wait until rising_edge(clk);   -- bắt buộc! (do ghi vào RegisterFile chỉ xảy ra khi có cạnh lên của clk)

        dbg_wreg <= "01010";  -- $t2 = 10
        dbg_wdat <= x"00000003";
        wait until rising_edge(clk);   -- bắt buộc! (do ghi vào RegisterFile chỉ xảy ra khi có cạnh lên của clk)

        dbg_we <= '0'; -- Tắt debug write, chuyển sang chạy chương trình bình thường

        ------------------------------------------------------------------
        -- RUN 5 instructions, each takes 1 cycle
        ------------------------------------------------------------------
        reset <= '0';
        wait until rising_edge(clk);
        wait for 10 ns; -- ADD
        dbg_rreg <= "01000"; -- read $t0
        wait for 1 ns;
        report "After ADD: $t0 = " & integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- SUB
        dbg_rreg <= "01000";
        wait for 1 ns;
        report "After SUB: $t0 = " & integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- AND
        dbg_rreg <= "01000";
        wait for 1 ns;
        report "After AND: $t0 = " & integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- OR
        dbg_rreg <= "01000";
        wait for 1 ns;
        report "After OR:  $t0 = " & integer'image(to_integer(signed(dbg_rdat)));

        wait for 10 ns; -- SLT
        dbg_rreg <= "01000";
        wait for 1 ns;
        report "After SLT: $t0 = " & integer'image(to_integer(signed(dbg_rdat)));

        report "Testbench completed." severity note;
        wait for 10 ns;
    end process;

end architecture;
