library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    generic(N: integer := 8);
    port (
        clk_i     : in  std_logic;
        res_ni    : in  std_logic;
        op1_i     : in  signed(N-1 downto 0);
        op2_i     : in  signed(N-1 downto 0);
        opcode_i  : in  std_logic_vector(3 downto 0);
        result_o  : out signed(N-1 downto 0);
        zero_o    : out std_logic;
        carry_o   : out std_logic
    );
end alu;

architecture behavioral of alu is
    signal result_s : signed(N-1 downto 0);
begin
    process(clk_i, res_ni)
        variable tmp_carry : std_logic;
        variable sum_v     : signed(N-1 downto 0);
        variable diff_v    : signed(N-1 downto 0);
    begin
        if res_ni = '0' then
            result_s <= (others => '0');
            zero_o   <= '0';
            carry_o  <= '0';

        elsif rising_edge(clk_i) then
            tmp_carry := '0';

            case opcode_i is
                when "0001" =>  -- Addition (signed)
                    sum_v    := op1_i + op2_i;
                    result_s <= sum_v;
                    -- signed overflow: same sign inputs, different sign result
                    if (op1_i(N-1) = op2_i(N-1)) and (sum_v(N-1) /= op1_i(N-1)) then
                        tmp_carry := '1';
                    end if;

                when "0010" =>  -- Subtraction (signed)used 2's complement menthod
                    diff_v   := op1_i - op2_i;
                    result_s <= diff_v;
                    -- signed overflow on subtraction
                    if (op1_i(N-1) /= op2_i(N-1)) and (diff_v(N-1) /= op1_i(N-1)) then
                        tmp_carry := '1';
                    end if;

                when "0011" =>  -- Multiplication (truncate to N)
                    result_s <= resize(op1_i * op2_i, N);
                    tmp_carry := '0';

                when "0100" =>  -- Division
                    if op2_i /= 0 then
                        result_s <= op1_i / op2_i;
                    else
                        result_s <= (others => '0');
                    end if;
                    tmp_carry := '0';

                when "0101" =>  -- AND
                    result_s <= op1_i and op2_i;

                when "0110" =>  -- OR
                    result_s <= op1_i or op2_i;

                when "0111" =>  -- XOR
                    result_s <= op1_i xor op2_i;

                when others =>
                    result_s <= (others => '0');
                    tmp_carry := '0';
            end case;

            carry_o <= tmp_carry;

            if result_s = to_signed(0, N) then
                zero_o <= '1';
            else
                zero_o <= '0';
            end if;
        end if;
    end process;

    -- drive the output port from the internal register
    result_o <= result_s;
end behavioral;
