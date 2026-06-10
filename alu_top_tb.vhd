library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_top_tb is
end entity alu_top_tb;

architecture simulation_suite of alu_top_tb is
    signal clk          : std_logic := '0';
    signal button_key   : std_logic_vector(1 downto 0) := "11";
    signal switch_array : std_logic_vector(9 downto 0) := (others => '0');
    signal led_output   : std_logic_vector(9 downto 0);
    signal hex_display_0, hex_display_1, hex_display_2 : std_logic_vector(6 downto 0);

    constant clk_cycle : time := 20 ns;

    procedure log_operation(operation_name : string; value_hex : std_logic_vector(7 downto 0); overflow_bit : std_logic) is
    begin
        report "TEST: " & operation_name & 
               " | WYNIK_ALU: " & integer'image(to_integer(signed(value_hex))) & 
               " | OVF: " & std_logic'image(overflow_bit) severity note;
    end procedure;

begin

    UUT: entity work.alu_top 
        port map (
            MAX10_CLK1_50 => clk,
            KEY           => button_key,
            SW            => switch_array,
            LEDR          => led_output,
            HEX0          => hex_display_0,
            HEX1          => hex_display_1,
            HEX2          => hex_display_2
        );

    clock_generator: process
    begin
        clk <= '0'; wait for clk_cycle/2;
        clk <= '1'; wait for clk_cycle/2;
    end process;

    main_sequencer: process
    begin
        wait for 100 ns;

        switch_array <= "00" & "0000" & "1010"; 
        wait for 40 ns; log_operation("LOAD R0 = 10", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "00" & "0001" & "0011"; 
        wait for 40 ns; log_operation("LOAD R1 = 3", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "00" & "0111" & "1111"; 
        wait for 40 ns; log_operation("LOAD R7 = 15", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "00" & "1000" & "1111"; 
        wait for 40 ns; log_operation("LOAD R8 = 15", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;


        switch_array <= "01" & "0010" & "0000";
        wait for 40 ns; log_operation("COPY R2 = R0(10)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;


        switch_array <= "11" & "0000" & "0001";
        wait for 40 ns; log_operation("SUB R0(10) - R1(3)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "11" & "0001" & "0000"; 
        wait for 40 ns; log_operation("SUB R1(3) - R0(7)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;


        switch_array <= "10" & "0111" & "1000";
        wait for 40 ns; log_operation("ADD R7(15) + R8(15)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "10" & "0111" & "0111"; 
        wait for 40 ns; log_operation("ADD R7(30) + R7(30)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "10" & "0111" & "0111"; 
        wait for 40 ns; log_operation("ADD R7(60) + R7(60)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        switch_array <= "10" & "0111" & "1000"; 
        wait for 40 ns; log_operation("ADD R7(120) + R8(15)", led_output(7 downto 0), led_output(9)); button_key(0) <= '0'; wait for 40 ns; button_key(0) <= '1'; wait for 40 ns;

        wait;
    end process;

end architecture simulation_suite;