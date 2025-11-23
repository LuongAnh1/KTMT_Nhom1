library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BrentKung_32 is
    port(
        A    : in  std_logic_vector(31 downto 0);
        B    : in  std_logic_vector(31 downto 0);
        Cin  : in  std_logic;
        Sum  : out std_logic_vector(31 downto 0);
        Cout : out std_logic
    );
end entity;

architecture Structural of BrentKung_32 is

    component BrentKung_16
        port(
            A    : in  std_logic_vector(15 downto 0);
            B    : in  std_logic_vector(15 downto 0);
            Cin  : in  std_logic;
            Sum  : out std_logic_vector(15 downto 0);
            Cout : out std_logic
        );
    end component;

    signal Sum_lo, Sum_hi : std_logic_vector(15 downto 0);
    signal Cmid            : std_logic;

begin

    BK_LOW: BrentKung_16
        port map (
            A    => A(15 downto 0),
            B    => B(15 downto 0),
            Cin  => Cin,
            Sum  => Sum_lo,
            Cout => Cmid
        );

    BK_HIGH: BrentKung_16
        port map (
            A    => A(31 downto 16),
            B    => B(31 downto 16),
            Cin  => Cmid,
            Sum  => Sum_hi,
            Cout => Cout
        );

    -- **Đúng thứ tự**: high half trước, low half sau
    Sum <= Sum_hi & Sum_lo;

end architecture;
