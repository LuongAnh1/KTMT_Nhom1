-- Cấu trúc Brent–Kung 16-bit
-- Cây gồm 4 tầng reduce + 3 tầng distribute, tổng 7 tầng logic
-- Stage 1: Pairwise combine   (G1,G0), (G3,G2), (G5,G4), (G7,G6), (G9,G8), (G11,G10), (G13,G12), (G15,G14)
-- Stage 2: Combine every 4 bits
-- Stage 3: Combine every 8 bits
-- Stage 4: Combine every 16 bits
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BrentKung_16 IS
    PORT (
        A, B  : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
        Cin   : IN  STD_LOGIC;
        Sum   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        Cout  : OUT STD_LOGIC
    );
END BrentKung_16;

ARCHITECTURE PrefixTree OF BrentKung_16 IS

    TYPE GPArray IS ARRAY (15 DOWNTO 0) OF STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL GP : GPArray;         -- G_i, P_i for each bit
    SIGNAL C  : STD_LOGIC_VECTOR(16 DOWNTO 0);  -- Carry signals

    -- Hàm gộp (prefix)
    FUNCTION Combine(X, Y : STD_LOGIC_VECTOR(1 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE R : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN
        R(1) := X(1) AND Y(1);                 -- P_out = P_i * P_j
        R(0) := X(0) OR (X(1) AND Y(0));       -- G_out = G_i + P_i * G_j
        RETURN R;
    END FUNCTION;

    SIGNAL G, P : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
    -- Tính G và P cơ bản
    GEN_GP: FOR i IN 0 TO 15 GENERATE
        G(i) <= A(i) AND B(i);
        P(i) <= A(i) XOR B(i);
    END GENERATE;

    -- Carry vào đầu tiên
    C(0) <= Cin;

    ------------------------------------------------------------------------------
    -- Reduction tree (prefix gộp)
    ------------------------------------------------------------------------------

    -- Level 1 (distance 1)
    SIGNAL G1, P1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    GEN_L1: FOR i IN 0 TO 15 GENERATE
        IF i MOD 2 = 1 THEN
            G1(i) <= G(i) OR (P(i) AND G(i-1));
            P1(i) <= P(i) AND P(i-1);
        ELSE
            G1(i) <= G(i);
            P1(i) <= P(i);
        END IF;
    END GENERATE;

    -- Level 2 (distance 2)
    SIGNAL G2, P2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    GEN_L2: FOR i IN 0 TO 15 GENERATE
        IF i MOD 4 >= 2 THEN
            G2(i) <= G1(i) OR (P1(i) AND G1(i-2));
            P2(i) <= P1(i) AND P1(i-2);
        ELSE
            G2(i) <= G1(i);
            P2(i) <= P1(i);
        END IF;
    END GENERATE;

    -- Level 3 (distance 4)
    SIGNAL G3, P3 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    GEN_L3: FOR i IN 0 TO 15 GENERATE
        IF i MOD 8 >= 4 THEN
            G3(i) <= G2(i) OR (P2(i) AND G2(i-4));
            P3(i) <= P2(i) AND P2(i-4);
        ELSE
            G3(i) <= G2(i);
            P3(i) <= P2(i);
        END IF;
    END GENERATE;

    -- Level 4 (distance 8)
    SIGNAL G4, P4 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    GEN_L4: FOR i IN 0 TO 15 GENERATE
        IF i >= 8 THEN
            G4(i) <= G3(i) OR (P3(i) AND G3(i-8));
            P4(i) <= P3(i) AND P3(i-8);
        ELSE
            G4(i) <= G3(i);
            P4(i) <= P3(i);
        END IF;
    END GENERATE;

    ------------------------------------------------------------------------------
    -- Distribution phase: truyền carry xuống
    ------------------------------------------------------------------------------
    C(1)  <= G(0) OR (P(0) AND C(0));
    C(2)  <= G1(1) OR (P1(1) AND C(0));
    C(3)  <= G2(2) OR (P2(2) AND C(0));
    C(4)  <= G2(3) OR (P2(3) AND C(0));
    C(5)  <= G3(4) OR (P3(4) AND C(0));
    C(6)  <= G3(5) OR (P3(5) AND C(0));
    C(7)  <= G3(6) OR (P3(6) AND C(0));
    C(8)  <= G4(7) OR (P4(7) AND C(0));
    C(9)  <= G4(8) OR (P4(8) AND C(0));
    C(10) <= G4(9) OR (P4(9) AND C(0));
    C(11) <= G4(10) OR (P4(10) AND C(0));
    C(12) <= G4(11) OR (P4(11) AND C(0));
    C(13) <= G4(12) OR (P4(12) AND C(0));
    C(14) <= G4(13) OR (P4(13) AND C(0));
    C(15) <= G4(14) OR (P4(14) AND C(0));
    C(16) <= G4(15) OR (P4(15) AND C(0));

    ------------------------------------------------------------------------------
    -- Kết quả tổng
    ------------------------------------------------------------------------------
    GEN_SUM: FOR i IN 0 TO 15 GENERATE
        Sum(i) <= P(i) XOR C(i);
    END GENERATE;

    Cout <= C(16);

END PrefixTree;
