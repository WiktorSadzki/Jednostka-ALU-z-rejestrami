library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity alu_top is
    port (
        MAX10_CLK1_50 	: in  std_logic;
        KEY         	: in  std_logic_vector(1 downto 0);
        SW           	: in  std_logic_vector(9 downto 0);
        LEDR          	: out std_logic_vector(9 downto 0);
        HEX0, HEX1, HEX2: out std_logic_vector(6 downto 0)
    );
end entity alu_top;

architecture rtl of alu_top is

    -- Sygna?y wewn?trzne
    signal op_code                    	: std_logic_vector(1 downto 0);
    signal addr_target, addr_source   	: std_logic_vector(3 downto 0);
    signal reg_val_a, reg_val_b       	: std_logic_vector(7 downto 0);
    signal alu_out                    	: std_logic_vector(7 downto 0);
    signal write_en, overflow		: std_logic;

    -- Sygna?y do detektora zbocza
    signal btn_reg_1, btn_reg_2        : std_logic := '1';
    signal pulse_we                    : std_logic := '0';

    -- Warto?? absoultna dla wy?wietlacza
    signal alu_out_abs                : std_logic_vector(7 downto 0);
begin

    -- Dekodowanie wej??
    op_code     <= SW(9 downto 8);
    addr_target <= SW(7 downto 4);
    addr_source <= SW(3 downto 0);
    
    -- Detekcja zbocza (Synchronizacja przycisku)
    process(MAX10_CLK1_50)
    begin
        if rising_edge(MAX10_CLK1_50) then
            btn_reg_1 <= KEY(0);
            btn_reg_2 <= btn_reg_1;
            
            if (btn_reg_2 = '1' and btn_reg_1 = '0') then
                pulse_we <= '1';
            else
                pulse_we <= '0';
            end if;
        end if;
    end process;

    -- Bank Rejestrów - ??czy addr_target/source z wej?ciami ALU
    REG_BANK_INST: entity work.reg_bank
        generic map (
            DATA_WIDTH => 8,
            REG_COUNT  => 16
        )
        port map (
            clk         => MAX10_CLK1_50,
            we          => write_en,
            write_addr  => addr_target,
            write_data  => alu_out,
            read_addr_a => addr_target,
            read_addr_b => addr_source,
            out_a       => reg_val_a,
            out_b       => reg_val_b
        );

    -- Rdze? ALU - wykonuje obliczenia na podstawie sygna?ów z banku
    ALU_CORE: entity work.alu
        generic map (
            BUS_WIDTH => 8
        )
        port map (
            op_code        => op_code,
            imm_payload    => SW(3 downto 0),
            reg_val_a      => reg_val_a,
            reg_val_b      => reg_val_b,
            btn_write      => pulse_we,
            alu_output_val => alu_out,
            write_en_out   => write_en,
            overflow_flag  => overflow
        );

    process(alu_out)
    begin
        if alu_out(7) = '1' then
            -- Je?li bit znaku (MSB) to '1', liczba jest ujemna.
            -- Obliczamy warto?? bezwzgl?dn?: odwrócenie bitów (not) + 1
            alu_out_abs <= std_logic_vector(unsigned(not alu_out) + 1);
        else
            -- Je?li dodatnia, przekazujemy bezpo?rednio
            alu_out_abs <= alu_out;
        end if;
    end process;

    -- Wyj?cia na diody i wy?wietlacze
    LEDR(7 downto 0) <= alu_out;
    LEDR(8)          <= '0';
    LEDR(9)          <= overflow;    

    HEX1_INST: entity work.dec7seg port map (alu_out(7 downto 4), HEX1);
    HEX0_INST: entity work.dec7seg port map (alu_out(3 downto 0), HEX0);
    HEX2 <= not "1000000" when alu_out(7) = '1' else not "0000000";
end architecture rtl;