library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    generic (
        BUS_WIDTH : integer := 8 
    );
    port (
        op_code        : in  std_logic_vector(1 downto 0);
        imm_payload    : in  std_logic_vector(3 downto 0);
        reg_val_a      : in  std_logic_vector(BUS_WIDTH-1 downto 0);
        reg_val_b      : in  std_logic_vector(BUS_WIDTH-1 downto 0);
        btn_write      : in  std_logic;
        alu_output_val : out std_logic_vector(BUS_WIDTH-1 downto 0);
        write_en_out   : out std_logic;
        overflow_flag  : out std_logic
    );
end entity alu;

architecture rtl of alu is
    -- Sygna?y pomocnicze szersze o 1 bit, aby przechwyci? przeniesienie/po?yczk?
    signal temp_add : unsigned(BUS_WIDTH downto 0);
    signal temp_sub : unsigned(BUS_WIDTH downto 0);
begin
    -- Matematyka w tle - rozszerzamy 8-bitowe wej?cia do 9 bitów
    temp_add <= resize(unsigned(reg_val_a), BUS_WIDTH+1) + resize(unsigned(reg_val_b), BUS_WIDTH+1);
    temp_sub <= resize(unsigned(reg_val_a), BUS_WIDTH+1) - resize(unsigned(reg_val_b), BUS_WIDTH+1);

    -- Proces g?ówny ALU - multiplekser wyniku
    process(op_code, reg_val_a, reg_val_b, imm_payload, btn_write, temp_add, temp_sub)
    begin
        -- Warto?ci domy?lne 
        write_en_out   <= '0';
        alu_output_val <= (others => '0');
        overflow_flag  <= '0';

        case op_code is
            when "00" => 
                -- INST: LOAD (Zapisz warto?? natychmiastow? do rejestru)
                alu_output_val <= "0000" & imm_payload;
                write_en_out   <= btn_write;

            when "01" => 
                -- INST: COPY/WRITE (Skopiuj rejestr B do rejestru docelowego)
                alu_output_val <= reg_val_b;
                write_en_out   <= btn_write;
                
            when "10" => 
                -- INST: ADD (Dodaj rejestr A i rejestr B)
                alu_output_val <= std_logic_vector(temp_add(BUS_WIDTH-1 downto 0));
                overflow_flag  <= std_logic(temp_add(BUS_WIDTH)); 
                write_en_out   <= btn_write;
                
            when others => 
                -- INST: SUB (Odejmij rejestr B od rejestru A)
                alu_output_val <= std_logic_vector(temp_sub(BUS_WIDTH-1 downto 0));
                overflow_flag  <= std_logic(temp_sub(BUS_WIDTH)); 
                write_en_out   <= btn_write;
        end case;
    end process;
end architecture rtl;