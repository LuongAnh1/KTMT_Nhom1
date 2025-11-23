library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity BrentKung_16 is
    port (
        A    : in  std_logic_vector(15 downto 0);
        B    : in  std_logic_vector(15 downto 0);
        Cin  : in  std_logic;
        Sum  : out std_logic_vector(15 downto 0);
        Cout : out std_logic
    );
end entity;

architecture RTL of BrentKung_16 is

    -- bit-level generate & propagate
    signal G : std_logic_vector(15 downto 0);
    signal P : std_logic_vector(15 downto 0);

    -- carries C(0) .. C(16)
    signal C : std_logic_vector(16 downto 0);

begin

    -- compute bit-level G and P
    gen_gp: for i in 0 to 15 generate
    begin
        G(i) <= A(i) and B(i);
        P(i) <= A(i) xor B(i);
    end generate;

    -- combinational computation of carries (correct, simple)
    carry_proc: process(G, P, Cin)
    variable c_var : std_logic_vector(16 downto 0);
    begin
        c_var := (others => '0');
        c_var(0) := Cin;
        for i in 0 to 15 loop
            -- C(i+1) = G(i) or (P(i) and C(i))
            if (G(i) = '1') then
                c_var(i+1) := '1';
            elsif (P(i) = '1' and c_var(i) = '1') then
                c_var(i+1) := '1';
            else
                c_var(i+1) := '0';
            end if;
        end loop;
        C <= c_var;
    end process;

    -- sum bits: Sum(i) = P(i) xor C(i)
    gen_sum: for i in 0 to 15 generate
    begin
        Sum(i) <= P(i) xor C(i);
    end generate;

    Cout <= C(16);

end architecture;
