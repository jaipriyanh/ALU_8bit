library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tt_um_vhdl_ALU_top is
    generic (
        N : integer := 6  -- set 1..6
    );
    port (
        ui_in   : in  std_logic_vector(7 downto 0);  -- [N-1:0] = A
        uo_out  : out std_logic_vector(7 downto 0);  -- [7:2]=result (MSBs), [1]=zero, [0]=carry
        uio_in  : in  std_logic_vector(7 downto 0);  -- [N+1:2] = B (N bits), [1:0] + ui_in[7:6] = opcode
        uio_out : out std_logic_vector(7 downto 0);  -- unused (0)
        uio_oe  : out std_logic_vector(7 downto 0);  -- unused (0)
        ena     : in  std_logic;
        clk     : in  std_logic;
        rst_n   : in  std_logic
    );
end tt_um_vhdl_ALU_top;

architecture Behavioral of tt_um_vhdl_ALU_top is
    -- sanity: this mapping assumes 1 <= N <= 6
    -- A  uses ui_in(N-1 downto 0)           -> fits in ui_in[5:0]
    -- B  uses uio_in(N+1 downto 2)          -> fits in uio_in[7:2]
    -- OP uses uio_in(1 downto 0) & ui_in(7 downto 6) (4 bits)

    component alu
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
    end component;

    signal op1_s     : signed(N-1 downto 0);
    signal op2_s     : signed(N-1 downto 0);
    signal opcode_s  : std_logic_vector(3 downto 0);
    signal result_s  : signed(N-1 downto 0);
    signal zero_s    : std_logic;
    signal carry_s   : std_logic;

    signal result_ext : signed(7 downto 0);
begin
    -- Operand A: lowest N bits of ui_in
    op1_s <= signed(ui_in(N-1 downto 0));

    -- Operand B: take N bits from uio_in(N+1 downto 2)
    -- (For N=6 -> [7:2], N=1 -> [2:2], always N bits)
    op2_s <= signed(uio_in(N+1 downto 2));

    -- Opcode: high 2 bits from uio_in(1 downto 0), low 2 bits from ui_in(7 downto 6)
    opcode_s(3 downto 2) <= uio_in(1 downto 0);
    opcode_s(1 downto 0) <= ui_in(7 downto 6);

    -- ALU instance
    u_alu: alu
        generic map (N => N)
        port map (
            clk_i    => clk,
            res_ni   => rst_n,
            op1_i    => op1_s,
            op2_i    => op2_s,
            opcode_i => opcode_s,
            result_o => result_s,
            zero_o   => zero_s,
            carry_o  => carry_s
        );

    -- Output mapping: sign-extend result to 8, export top 6 bits + flags
    result_ext <= resize(result_s, 8);
    uo_out(7 downto 2) <= std_logic_vector(result_ext(7 downto 2));
    uo_out(1)          <= zero_s;
    uo_out(0)          <= carry_s;

    -- keep UIO as inputs only
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');
end Behavioral;
