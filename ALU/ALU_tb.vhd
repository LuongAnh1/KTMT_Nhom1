-- ghdl -a BrentKung_16.vhd BrentKung_32.vhd BarrelShifter.vhd ALU.vhd ALU_tb.vhd
-- ghdl -e ALU_tb
-- ghdl -r ALU_tb --vcd=alu.vcd
-- gtkwave alu.vcd

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_tb is
end entity;

architecture sim of ALU_tb is

    -- Component ALU
    component ALU
        port(
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            ALUControl : in  STD_LOGIC_VECTOR(3 downto 0);
            Result     : out STD_LOGIC_VECTOR(31 downto 0);
            Zero       : out STD_LOGIC
        );
    end component;

    signal A_s, B_s     : STD_LOGIC_VECTOR(31 downto 0);
    signal Control_s    : STD_LOGIC_VECTOR(3 downto 0);
    signal Result_s     : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero_s       : STD_LOGIC;

    constant delay_t : time := 20 ns;

begin

    -- Kết nối DUT
    DUT : ALU
        port map(
            A          => A_s,
            B          => B_s,
            ALUControl => Control_s,
            Result     => Result_s,
            Zero       => Zero_s
        );

    -----------------------------------------------------------
    -- Vùng kiểm tra mô phỏng
    -----------------------------------------------------------
    process
    begin

        ----------------------------------------------------------------
        report "=== Test 1: ADD ===";
        ----------------------------------------------------------------
        A_s <= x"00000005";      -- 5
        B_s <= x"00000008";      -- 8
        Control_s <= "0010";     -- ADD
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 2: SUB ===";
        ----------------------------------------------------------------
        A_s <= x"0000000C";      -- 12
        B_s <= x"00000005";      -- 5
        Control_s <= "0110";     -- SUB
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 3: AND ===";
        ----------------------------------------------------------------
        A_s <= x"00000005";      -- 0101
        B_s <= x"00000008";      -- 1000
        Control_s <= "0000";     -- AND
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 4: OR ===";
        ----------------------------------------------------------------
        Control_s <= "0001";     -- OR
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 5: XOR ===";
        ----------------------------------------------------------------
        Control_s <= "0100";     -- XOR
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 6: NOR ===";
        ----------------------------------------------------------------
        Control_s <= "1100";     -- NOR
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 7: SLT (A < B) ===";
        ----------------------------------------------------------------
        A_s <= x"00000005";
        B_s <= x"00000008";
        Control_s <= "0111";     -- SLT
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 8: SLL (5 << 2 = 20) ===";
        ----------------------------------------------------------------
        A_s <= x"00000005";      -- value
        B_s <= x"00000002";      -- shift amount
        Control_s <= "1000";     -- SLL
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 9: SRL (12 >> 1 = 6) ===";
        ----------------------------------------------------------------
        A_s <= x"0000000C";      
        B_s <= x"00000001";
        Control_s <= "1001";     -- SRL
        wait for delay_t;

        ----------------------------------------------------------------
        report "=== Test 10: SRA (signed shift) ===";
        ----------------------------------------------------------------
        A_s <= x"FFFFFFF0";      -- -16
        B_s <= x"00000002";      -- >> 2
        Control_s <= "1010";     -- SRA
        wait for delay_t;

        ----------------------------------------------------------------
        report "*** TEST DONE ***";
        ----------------------------------------------------------------
        wait;
    end process;

end architecture;
