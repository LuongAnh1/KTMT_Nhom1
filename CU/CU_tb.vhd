-- ===========================================================
-- Testbench for ControlUnit
-- ghdl -a CU.vhd
-- ghdl -a CU_tb.vhd
-- ghdl -e ControlUnit_tb
-- ghdl -r ControlUnit_tb --wave=CU_tb.ghw
-- ===========================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ControlUnit_tb is
end ControlUnit_tb;

architecture tb of ControlUnit_tb is

    -- DUT signals
    signal opcode    : std_logic_vector(5 downto 0);
    signal funct_in  : std_logic_vector(5 downto 0);

    signal RegDst      : std_logic_vector(1 downto 0);
    signal MemToReg    : std_logic_vector(1 downto 0);
    signal ALUSrc_ctrl : std_logic_vector(1 downto 0);
    signal RegWrite    : std_logic;
    signal MemRead     : std_logic;
    signal MemWrite    : std_logic;
    signal Branch      : std_logic;
    signal BranchType  : std_logic_vector(1 downto 0);
    signal Jump        : std_logic;
    signal ALUSrcA     : std_logic;
    signal ALUOp       : std_logic_vector(1 downto 0);

begin

    --------------------------------------------------------
    -- Instantiate DUT
    --------------------------------------------------------
    DUT: entity work.ControlUnit
        port map(
            opcode     => opcode,
            funct_in   => funct_in,
            RegDst     => RegDst,
            MemToReg   => MemToReg,
            ALUSrc_ctrl => ALUSrc_ctrl,
            RegWrite   => RegWrite,
            MemRead    => MemRead,
            MemWrite   => MemWrite,
            Branch     => Branch,
            BranchType => BranchType,
            Jump       => Jump,
            ALUSrcA    => ALUSrcA,
            ALUOp      => ALUOp
        );

    --------------------------------------------------------
    -- Procedure để tạo test cho 1 lệnh
    --------------------------------------------------------
    procedure test_instruction (
        constant name     : in string;
        constant op       : in std_logic_vector(5 downto 0);
        constant funct    : in std_logic_vector(5 downto 0)
    ) is
    begin
        opcode   <= op;
        funct_in <= funct;

        wait for 20 ns;

        report "=== TEST: " & name & " ===";
        report "opcode     = " & to_hstring(op);
        report "funct_in   = " & to_hstring(funct);
        report "RegDst     = " & to_hstring(RegDst);
        report "ALUSrc_ctrl= " & to_hstring(ALUSrc_ctrl);
        report "MemToReg   = " & to_hstring(MemToReg);
        report "RegWrite   = " & std_logic'image(RegWrite);
        report "MemRead    = " & std_logic'image(MemRead);
        report "MemWrite   = " & std_logic'image(MemWrite);
        report "Branch     = " & std_logic'image(Branch);
        report "BranchType = " & to_hstring(BranchType);
        report "Jump       = " & std_logic'image(Jump);
        report "ALUSrcA    = " & std_logic'image(ALUSrcA);
        report "ALUOp      = " & to_hstring(ALUOp);
        report "============================";
    end procedure;

    --------------------------------------------------------
    -- Main Stimulus
    --------------------------------------------------------
    stim: process
    begin
        ----------------------------------------------------
        -- R-TYPE (non-shift): add, sub, and, or...
        ----------------------------------------------------
        test_instruction("R-type normal (funct=20 add)", "000000", "100000");

        ----------------------------------------------------
        -- R-TYPE SHIFT
        ----------------------------------------------------
        test_instruction("sll", "000000", "000000");
        test_instruction("srl", "000000", "000010");
        test_instruction("sra", "000000", "000011");

        ----------------------------------------------------
        -- LW, SW
        ----------------------------------------------------
        test_instruction("lw", "100011", (others => '0'));
        test_instruction("sw", "101011", (others => '0'));

        ----------------------------------------------------
        -- Branch
        ----------------------------------------------------
        test_instruction("beq", "000100", (others => '0'));
        test_instruction("bne", "000101", (others => '0'));

        ----------------------------------------------------
        -- I-type arithmetic & logic
        ----------------------------------------------------
        test_instruction("addi", "001000", (others => '0'));
        test_instruction("andi", "001100", (others => '0'));
        test_instruction("ori",  "001101", (others => '0'));
        test_instruction("slti", "001010", (others => '0'));

        ----------------------------------------------------
        -- Jump
        ----------------------------------------------------
        test_instruction("j",   "000010", (others => '0'));
        test_instruction("jal", "000011", (others => '0'));

        ----------------------------------------------------
        report "All tests completed.";
        wait;
    end process;

end tb;
