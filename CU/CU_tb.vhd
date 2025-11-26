library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit_tb is
end entity;

architecture tb of ControlUnit_tb is

    -- Signals
    signal opcode    : std_logic_vector(5 downto 0);
    signal RegDst    : std_logic;
    signal ALUSrc    : std_logic;
    signal MemToReg  : std_logic;
    signal RegWrite  : std_logic;
    signal MemRead   : std_logic;
    signal MemWrite  : std_logic;
    signal Branch    : std_logic;
    signal Jump      : std_logic;
    signal ALUOp     : std_logic_vector(1 downto 0);

    -- Opcode array for testing
    type opcode_array is array (natural range <>) of std_logic_vector(5 downto 0);
    type name_array   is array (natural range <>) of string(1 to 10);

    constant opcodes : opcode_array := (
        "000000", -- R-type
        "100011", -- lw
        "101011", -- sw
        "000100", -- beq
        "000101", -- bne
        "001000", -- addi
        "001100", -- andi
        "001101", -- ori
        "001010", -- slti
        "000010", -- j
        "000011", -- jal
        "111111"  -- invalid
    );

    constant names : name_array := (
        "R-type",
        "lw",
        "sw",
        "beq",
        "bne",
        "addi",
        "andi",
        "ori",
        "slti",
        "j",
        "jal",
        "invalid"
    );

    -- Function to convert std_logic_vector to string
    function slv2string(slv : std_logic_vector) return string is
        variable str : string(1 to slv'length);
    begin
        for i in slv'range loop
            str(i - slv'low + 1) := character'VALUE(std_ulogic'image(slv(i)));
        end loop;
        return str;
    end function;

begin

    -- DUT
    uut: entity work.ControlUnit
        port map (
            opcode    => opcode,
            RegDst    => RegDst,
            ALUSrc    => ALUSrc,
            MemToReg  => MemToReg,
            RegWrite  => RegWrite,
            MemRead   => MemRead,
            MemWrite  => MemWrite,
            Branch    => Branch,
            Jump      => Jump,
            ALUOp     => ALUOp
        );

    -- Test process
    stim: process
        variable i : integer;
    begin
        for i in opcodes'range loop
            opcode <= opcodes(i);
            wait for 10 ns;

            report "Testing " & names(i) &
                   " | opcode=" & slv2string(opcode) &
                   " | RegDst=" & std_logic'image(RegDst) &
                   ", ALUSrc=" & std_logic'image(ALUSrc) &
                   ", MemToReg=" & std_logic'image(MemToReg) &
                   ", RegWrite=" & std_logic'image(RegWrite) &
                   ", MemRead=" & std_logic'image(MemRead) &
                   ", MemWrite=" & std_logic'image(MemWrite) &
                   ", Branch=" & std_logic'image(Branch) &
                   ", Jump=" & std_logic'image(Jump) &
                   ", ALUOp=" & slv2string(ALUOp);
        end loop;

        report "TEST FINISHED";
        wait;
    end process;

end architecture;