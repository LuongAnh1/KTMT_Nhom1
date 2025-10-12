-- Xây dựng dựa trên Brent-Kung 16 bit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BrentKung_32 IS
    PORT(
        A, B : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        Cin  : IN  STD_LOGIC;
        Sum  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Cout : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE Structural OF BrentKung_32 IS

    COMPONENT BrentKung_16
        PORT(
            A, B : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
            Cin  : IN  STD_LOGIC;
            Sum  : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            Cout : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL C16 : STD_LOGIC; -- Carry giữa hai nửa 16 bit

BEGIN
    -- Nửa thấp
    BK_LOW: BrentKung_16
        PORT MAP (
            A   => A(15 DOWNTO 0),
            B   => B(15 DOWNTO 0),
            Cin => Cin,
            Sum => Sum(15 DOWNTO 0),
            Cout => C16 -- Kết quả carry ra của nửa thấp (bit 15)
        );

    -- Nửa cao
    BK_HIGH: BrentKung_16
        PORT MAP (
            A   => A(31 DOWNTO 16),
            B   => B(31 DOWNTO 16),
            Cin => C16, -- Carry vào của nửa cao là carry ra của nửa thấp
            Sum => Sum(31 DOWNTO 16),
            Cout => Cout
        );

END ARCHITECTURE;
