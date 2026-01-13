-- Biên dịch 
-- ghdl -a BarrelShifter.vhd BrentKung_16.vhd BrentKung_32.vhd
-- ghdl -a ALU.vhd
-- ghdl -a ALU_tb.vhd

-- Xây Test_Bench + chạy mô phỏng
-- ghdl -e ALU_tb
-- ghdl -r ALU_tb --vcd=alu.vcd
-- gtkwave alu.vcd
---------------------------------------------------------------------------------------
-- Các phép toán số học 32-bit: add, sub, slt
-- Các phép toán logic 32-bit: and, or, (xor), nor
-- Các phép dịch 32-bit: sll (dịch trái), srl (dịch phải), sra (dịch số học)
-- Các phép toán cho Branch: beq, bne
---------------------------------------------------------------------------------------
-- Bảng mã ALUControl 
-- 0000	AND	A AND B
-- 0001	OR	A OR B
-- 0010	ADD	A + B
-- 0110	SUB	A – B
-- 0111	SLT	1 nếu A < B
-- 1100	NOR	NOT(A OR B)
--------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    port(
        A          : in  STD_LOGIC_VECTOR(31 downto 0);
        B          : in  STD_LOGIC_VECTOR(31 downto 0);
        ALUControl : in  STD_LOGIC_VECTOR(3 downto 0);
        Result     : out STD_LOGIC_VECTOR(31 downto 0);
        Zero       : out STD_LOGIC
    );
end entity;

architecture Behavioral of ALU is

    -- Component bộ cộng 32 bit Brent-Kung
    component BrentKung_32
        port(
            A, B : in  STD_LOGIC_VECTOR(31 downto 0);
            Cin  : in  STD_LOGIC;
            Sum  : out STD_LOGIC_VECTOR(31 downto 0);
            Cout : out STD_LOGIC
        );
    end component;
    -- Component bộ dịch BarrelShifter 32 bit
    component BarrelShifter
        port(
            DataIn  : in  std_logic_vector(31 downto 0);
            Shamt   : in  std_logic_vector(4 downto 0); -- số bit dịch
            Mode    : in  std_logic_vector(1 downto 0); -- 00=SLL, 01=SRL, 10=SRA
            DataOut : out std_logic_vector(31 downto 0)
        );
    end component;
    

    signal B_invert     : STD_LOGIC_VECTOR(31 downto 0); 
    signal adder_result : STD_LOGIC_VECTOR(31 downto 0);
    signal Cin_sig      : STD_LOGIC := '0';
    signal Result_i : STD_LOGIC_VECTOR(31 downto 0);
    signal shiftOut : STD_LOGIC_VECTOR(31 downto 0);
begin

    -----------------------------------------------------------
    -- Chọn B hoặc NOT B và xác định Cin
    -----------------------------------------------------------
    process(A, B, ALUControl)
    begin
        case ALUControl is
        
            when "0010" =>  -- ADD
                B_invert <= B;
                Cin_sig  <= '0';

            when "0110" =>  -- SUB
                B_invert <= NOT B;
                Cin_sig  <= '1';  -- để thực hiện A + (~B) + 1

            when "0111" =>  -- SLT (dùng phép trừ phía trong)
                B_invert <= NOT B;
                Cin_sig  <= '1';

            when others =>
                B_invert <= B;
                Cin_sig  <= '0';
        end case;
    end process;


    -----------------------------------------------------------
    -- Gọi bộ cộng Brent-Kung 32 bit
    -----------------------------------------------------------
    Adder32: BrentKung_32
        port map(
            A    => A,
            B    => B_invert,
            Cin  => Cin_sig,
            Sum  => adder_result,
            Cout => open
        );
    -----------------------------------------------------------
    -- Gọi bộ dịch BarrelShifter 32 bit
    -----------------------------------------------------------
    U_SHIFTER : entity work.BarrelShifter
        port map(
            DataIn  => A,
            Shamt   => B(4 downto 0), -- 5 bit dịch
            Mode    => ALUControl(1 downto 0),
            DataOut => shiftOut -- kết quả dịch
        );

    -----------------------------------------------------------
    -- Cho ra kết quả ALU
    -----------------------------------------------------------
    process(A, B, ALUControl, adder_result, shiftOut)
    begin
        case ALUControl is

            when "0000" =>   -- AND
                Result_i <= A AND B;

            when "0001" =>   -- OR
                Result_i <= A OR B;

            when "0010" =>   -- ADD
                Result_i <= adder_result;

            when "0110" =>   -- SUB
                Result_i <= adder_result;

            when "0111" =>   -- SLT
                if adder_result(31) = '1' then
                    Result_i <= (others => '0');
                    Result_i(0) <= '1';
                else
                    Result_i <= (others => '0');
                end if;

            when "1100" =>  -- NOR
                Result_i <= NOT (A OR B);
                
            when "0100" =>  -- XOR
                Result_i <= A XOR B;

            when "1000"  =>  -- SLL
                Result_i <= shiftOut;
            when "1001"  =>  -- SRL
                Result_i <= shiftOut;
            when "1010" =>  -- SRA
                Result_i <= shiftOut;

            when others =>
                Result_i <= (others => '0');
        end case;
    end process;


    -----------------------------------------------------------
    -- Xuất kết quả ra port
    -----------------------------------------------------------
    Result <= Result_i;


    -----------------------------------------------------------
    -- Zero flag
    -----------------------------------------------------------
    Zero <= '1' when Result_i = x"00000000" else '0';

end architecture;
