library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- SW[9:8] - Kod operacji (OpCode)
-- SW[7:4] - Adres rejestru docelowego / ?ród?o A
-- SW[3:0] - Adres rejestru ?ród?owego B / Warto?? dla LOAD
entity alu_top is
    port (
        clk           : in  std_logic;
        btn_key0      : in  std_logic;
        switch_inputs : in  std_logic_vector(9 downto 0);
        led_outputs   : out std_logic_vector(9 downto 0);
        hex_out_lower : out std_logic_vector(6 downto 0);
        hex_out_upper : out std_logic_vector(6 downto 0)
    );
end entity alu_top;

architecture rtl of alu_top is
    
    -- Sygna?y wewn?trzne - zdekodowana ramka
    signal op_code      : std_logic_vector(1 downto 0);
    signal addr_target  : std_logic_vector(3 downto 0);
    signal addr_source  : std_logic_vector(3 downto 0);
    signal imm_val      : std_logic_vector(3 downto 0);
    
    -- Magistrale ??cz?ce modu?y
    signal active_write_en : std_logic;
    signal wire_reg_a_val  : std_logic_vector(7 downto 0);
    signal wire_reg_b_val  : std_logic_vector(7 downto 0);
    signal wire_alu_out    : std_logic_vector(7 downto 0);
    signal wire_we         : std_logic;
    signal wire_overflow   : std_logic;

begin
    -- Dekodowanie wej??
    active_write_en <= not btn_key0;

    op_code     <= switch_inputs(9 downto 8);
    addr_target <= switch_inputs(7 downto 4);
    addr_source <= switch_inputs(3 downto 0);
    imm_val     <= switch_inputs(3 downto 0);

    -- Instancja Banku Rejestrów
    REG_BANK_INST: entity work.reg_bank
        generic map (
            DATA_WIDTH => 8,
            REG_COUNT  => 16
        )
        port map (
            clk         => clk,
            we          => wire_we,
            write_addr  => addr_target,
            write_data  => wire_alu_out,
            read_addr_a => addr_target,
            read_addr_b => addr_source,
            out_a       => wire_reg_a_val,
            out_b       => wire_reg_b_val
        );

    -- Instancja ALU
    ALU_CORE: entity work.alu
        generic map (
            BUS_WIDTH => 8
        )
        port map (
            op_code        => op_code,
            imm_payload    => imm_val,
            reg_val_a      => wire_reg_a_val,
            reg_val_b      => wire_reg_b_val,
            btn_write      => active_write_en,
            alu_output_val => wire_alu_out,
            write_en_out   => wire_we,
            overflow_flag  => wire_overflow
        );

    -- Mapowanie wyj??
    led_outputs(7 downto 0) <= wire_alu_out;
    led_outputs(8)          <= '0';
    led_outputs(9)          <= wire_overflow; 

    HEX1_INST: entity work.dec7seg
        port map (
            hex => wire_alu_out(7 downto 4),
            seg => hex_out_upper
        );

    HEX0_INST: entity work.dec7seg
        port map (
            hex => wire_alu_out(3 downto 0),
            seg => hex_out_lower
        );

end architecture rtl;