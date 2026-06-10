library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    generic (
        BUS_WIDTH : integer := 8 
    );
    port (
        op_code     		   : in  std_logic_vector(1 downto 0);
        imm_payload 		   : in  std_logic_vector(3 downto 0);
        reg_val_a, reg_val_b       : in  std_logic_vector(BUS_WIDTH-1 downto 0);
        btn_write		   : in  std_logic;
        alu_output_val 		   : out std_logic_vector(BUS_WIDTH-1 downto 0);
        write_en_out  		   : out std_logic;
        overflow_flag 		   : out std_logic
    );
end entity alu;

architecture rtl of alu is
    -- U?ywamy signed dla arytmetyki U2
    signal a_signed, b_signed : signed(BUS_WIDTH-1 downto 0);
begin
    a_signed <= signed(reg_val_a);
    b_signed <= signed(reg_val_b);

    process(op_code, a_signed, b_signed, imm_payload, btn_write)
	variable res_var : signed(BUS_WIDTH downto 0);
    begin
        -- Domy?lne warto?ci
        write_en_out   <= btn_write;
        alu_output_val <= (others => '0');
        overflow_flag  <= '0';
        res_var        := (others => '0');

        case op_code is
            when "00" => -- LOAD
                alu_output_val <= "0000" & imm_payload;

            when "01" => -- COPY
                alu_output_val <= reg_val_b;

            when "10" => -- ADD (U2)
                res_var := resize(a_signed, BUS_WIDTH+1) + resize(b_signed, BUS_WIDTH+1);
                alu_output_val <= std_logic_vector(res_var(BUS_WIDTH-1 downto 0));
                overflow_flag <= (a_signed(7) XNOR b_signed(7)) AND (a_signed(7) XOR res_var(7));

            when others => -- SUB (U2)
                res_var := resize(a_signed, BUS_WIDTH+1) - resize(b_signed, BUS_WIDTH+1);
                alu_output_val <= std_logic_vector(res_var(BUS_WIDTH-1 downto 0));
                overflow_flag <= (a_signed(7) XOR b_signed(7)) AND (a_signed(7) XOR res_var(7));	end case;
    end process;
end architecture rtl;