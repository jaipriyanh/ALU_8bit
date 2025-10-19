library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        clk_i     : in  std_logic;
        res_ni    : in  std_logic;                       -- active-low async reset
        op1_i     : in  signed(5 downto 0);
        op2_i     : in  signed(5 downto 0);
        opcode_i  : in  std_logic_vector(3 downto 0);
        result_o  : out signed(5 downto 0);
        zero_o    : out std_logic;
        carry_o   : out std_logic                        -- actually "overflow" for signed add/sub
    );
end alu;

architecture rtl of alu is
    signal result_s : signed(5 downto 0);
begin
    process(clk_i, res_ni)
        variable tmp_overflow : std_logic;
        variable result_v     : signed(5 downto 0);
        variable sum_v        : signed(5 downto 0);
        variable diff_v       : signed(5 downto 0);
    begin
        if res_ni = '0' then
            result_s <= (others => '0');
            zero_o   <= '1';                 -- result is zero on reset
            carry_o  <= '0';

        elsif rising_edge(clk_i) then
            tmp_overflow := '0';
            result_v     := (others => '0');

            case opcode_i is
                when "0001" =>  -- Addition (signed)
                    sum_v    := op1_i + op2_i;
                    result_v := sum_v;
                    -- signed overflow: same sign inputs, different sign result
                    if (op1_i(5) = op2_i(5)) and (sum_v(5) /= op1_i(5)) then
                        tmp_overflow := '1';
                    end if;

                when "0010" =>  -- Subtraction (signed)
                    diff_v   := op1_i - op2_i;
                    result_v := diff_v;
                    -- signed overflow on subtraction
                    if (op1_i(5) /= op2_i(5)) and (diff_v(5) /= op1_i(5)) then
                        tmp_overflow := '1';
                    end if;

                when "0011" =>  -- Multiplication (truncate to 6)
                    -- product is 12 bits; resize will sign-truncate to 6 bits
                    result_v := resize(op1_i * op2_i, 6);

                when "0100" =>  -- Division (guard divide by zero)
                    if op2_i /= 0 then
                        result_v := op1_i / op2_i;
                    else
                        result_v := (others => '0');  -- policy: return 0 (no flag set)
                    end if;

                when "0101" =>  -- AND
                    result_v := op1_i and op2_i;

                when "0110" =>  -- OR
                    result_v := op1_i or  op2_i;

                when "0111" =>  -- XOR
                    result_v := op1_i xor op2_i;

                when others =>
                    result_v := (others => '0');      -- default/NOP
            end case;

            -- Register result and flags
            result_s <= result_v;
            carry_o  <= tmp_overflow;                 -- consider renaming to overflow_o

            if result_v = 0 then                      -- check the freshly computed value
                zero_o <= '1';
            else
                zero_o <= '0';
            end if;
        end if;
    end process;

    result_o <= result_s;  -- registered output
end rtl;
