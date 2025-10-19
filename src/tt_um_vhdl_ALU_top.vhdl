library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Fixed 6-bit top wrapper that matches the 6-bit ALU ports
entity tt_um_vhdl_ALU_top is
    port (
        -- Inputs
        ui_in   : in  std_logic_vector(7 downto 0);  -- [5:0]=A(6b), [7:6]=opcode[1:0]
        uio_in  : in  std_logic_vector(7 downto 0);  -- [7:2]=B(6b), [1:0]=opcode[3:2]
        ena     : in  std_logic;                     -- unused
        clk     : in  std_logic;
        rst_n   : in  std_logic;                     -- active-low reset

        -- Outputs
        uo_out  : out std_logic_vector(7 downto 0);  -- [7:2]=result(6b), [1]=zero, [0]=carry/ovf
        uio_out : out std_logic_vector(7 downto 0);  -- unused (0)
        uio_oe  : out std_logic_vector(7 downto 0)   -- unused (0)
    );
end tt_um_vhdl_ALU_top;

architecture Behavioral of tt_um_vhdl_ALU_top is

    -- Match the fixed 6-bit ALU (no generic)
    component alu
        port (
            clk_i     : in  std_logic;
            res_ni    : in  std_logic;
            op1_i     : in  signed(5 downto 0);
            op2_i     : in  signed(5 downto 0);
            opcode_i  : in  std_logic_vector(3 downto 0);
            result_o  : out signed(5 downto 0);
            zero_o    : out std_logic;
            carry_o   : out std_logic
        );
    end component;

    -- Internal signals (fixed 6-bit)
    signal op1_s      : signed(5 downto 0);
    signal op2_s      : signed(5 downto 0);
    signal opcode_s   : std_logic_vector(3 downto 0);
    signal result_s   : signed(5 downto 0);
    signal zero_s     : std_logic;
    signal carry_s    : std_logic;
    signal result_ext : signed(7 downto 0);

begin
    -- Input mapping
    op1_s <= signed(ui_in(5 downto 0));        -- A = ui_in[5:0]
    op2_s <= signed(uio_in(7 downto 2));       -- B = uio_in[7:2]
    opcode_s(3 downto 2) <= uio_in(1 downto 0);-- opcode[3:2]
    opcode_s(1 downto 0) <= ui_in(7 downto 6); -- opcode[1:0]

    -- ALU instance (fixed 6-bit)
    u_alu: alu
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

    -- Output mapping: sign-extend result to 8 bits, place flags
    result_ext <= resize(result_s, 8);
    uo_out(7 downto 2) <= std_logic_vector(result_ext(7 downto 2));
    uo_out(1)          <= zero_s;
    uo_out(0)          <= carry_s;  -- (overflow for signed add/sub in your ALU)

    -- Keep UIO as inputs only
    uio_out <= (others => '0');
    uio_oe  <= (others => '0');

    -- 'ena' is unused by design
end Behavioral;
