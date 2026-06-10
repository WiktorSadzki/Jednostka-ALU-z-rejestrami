library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity reg_bank is
    generic (
        DATA_WIDTH : integer := 8; 
        REG_COUNT  : integer := 16  -- 16 rejestrów
    );
    port (
        clk        : in  std_logic;
        we         : in  std_logic; --Write Enable
        write_addr : in  std_logic_vector(3 downto 0); -- 4 bity = 16 opcji
        write_data : in  std_logic_vector(DATA_WIDTH-1 downto 0); -- Dane
        
        -- Porty odczytu dla ALU 
        read_addr_a: in  std_logic_vector(3 downto 0);
        read_addr_b: in  std_logic_vector(3 downto 0);
        out_a      : out std_logic_vector(DATA_WIDTH-1 downto 0);
        out_b      : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity reg_bank;

architecture rtl of reg_bank is

    component reg_n is
        generic ( N : integer );
        port (
            clk : in std_logic;
            en  : in std_logic;
            d   : in std_logic_vector(N-1 downto 0);
            q   : out std_logic_vector(N-1 downto 0)
        );
    end component;

    type reg_array_t is array (0 to REG_COUNT-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg_outs : reg_array_t;

    signal reg_we_array : std_logic_vector(REG_COUNT-1 downto 0);

begin
    -- dekoder zapisu
    process(we, write_addr)
    begin
        reg_we_array <= (others => '0'); 
        -- Sprawdzamy, czy wszystkie bity adresu s? ustalone
        if we = '1' then
            if write_addr(0) /= 'U' and write_addr(1) /= 'U' and 
               write_addr(2) /= 'U' and write_addr(3) /= 'U' then
                reg_we_array(to_integer(unsigned(write_addr))) <= '1';
            end if;
        end if;
    end process;

GEN_REGS: for i in 0 to REG_COUNT-1 generate
        REG_INST: reg_n
            generic map (
                N => DATA_WIDTH
            )
            port map (
                clk => clk,
                en  => reg_we_array(i), 
                d   => write_data,      
                q   => reg_outs(i)     
            );
    end generate GEN_REGS;

    out_a <= reg_outs(to_integer(unsigned(read_addr_a)));
    out_b <= reg_outs(to_integer(unsigned(read_addr_b)));

end architecture rtl;