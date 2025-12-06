library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity BarrelShifter is
        port(
        DataIn : in std_logic_vector(31 downto 0);
        Shamt : in std_logic_vector(4 downto 0); -- số bit dịch
        Mode : in std_logic_vector(1 downto 0); -- 00=SLL, 01=SRL, 10=SRA
        DataOut : out std_logic_vector(31 downto 0)
        );
    end entity;

architecture Behavioral of BarrelShifter is

    signal stage0, stage1, stage2, stage3, stage4 : std_logic_vector(31 downto 0);
    signal fillbit : std_logic;

begin

    ------------------------------------------------------------
    -- bit điền khi dịch phải
    ------------------------------------------------------------
    fillbit <= '0' when Mode = "01" else     -- SRL
            DataIn(31) when Mode = "10" else  -- SRA
            '0';

    ------------------------------------------------------------
    -- Stage 0: dịch 1 bit
    ------------------------------------------------------------
    stage0 <= 
        DataIn(30 downto 0) & '0' when (Mode="00" and Shamt(0)='1') else  -- SLL
        fillbit & DataIn(31 downto 1) when (Shamt(0)='1') else
        DataIn;

    -- Stage 1: dịch 2 bit
    stage1 <=
        stage0(29 downto 0) & (1 downto 0 => '0') when (Mode="00" and Shamt(1)='1') else
        ( (1 downto 0 => fillbit) & stage0(31 downto 2) ) when (Shamt(1)='1') else
        stage0;

    -- Stage 2: dịch 4 bit
    stage2 <=
        stage1(27 downto 0) & (3 downto 0 => '0') when (Mode="00" and Shamt(2)='1') else
        ( (3 downto 0 => fillbit) & stage1(31 downto 4) ) when (Shamt(2)='1') else
        stage1;

    -- Stage 3: dịch 8 bit
    stage3 <=
        stage2(23 downto 0) & (7 downto 0 => '0') when (Mode="00" and Shamt(3)='1') else
        ( (7 downto 0 => fillbit) & stage2(31 downto 8) ) when (Shamt(3)='1') else
        stage2;

    -- Stage 4: dịch 16 bit
    stage4 <=
        stage3(15 downto 0) & (15 downto 0 => '0') when (Mode="00" and Shamt(4)='1') else
        ( (15 downto 0 => fillbit) & stage3(31 downto 16) ) when (Shamt(4)='1') else
        stage3;


    ------------------------------------------------------------
    -- Output
    ------------------------------------------------------------
    DataOut <= stage4;

end architecture;