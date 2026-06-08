library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg_n is
    generic (
        N : integer := 8 -- szerokość rejestru
    );
    port (
        clk : in std_logic;
        en  : in std_logic; -- Write Enable
        d   : in std_logic_vector(N-1 downto 0);
        q   : out std_logic_vector(N-1 downto 0)
    );
end entity reg_n;

architecture rtl of reg_n is
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                q <= d;
            end if;
        end if;
    end process;
end architecture rtl;