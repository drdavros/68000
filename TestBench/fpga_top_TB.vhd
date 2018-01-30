library ieee;
use ieee.std_logic_1164.all;

-- Add your library and packages declaration here ...

entity fpga_top_tb is
end fpga_top_tb;

architecture TB_ARCHITECTURE of fpga_top_tb is
    -- Component declaration of the tested unit
    component fpga_top
        port(
            clk_in : in STD_LOGIC;
            reset_n : in STD_LOGIC;
            RXD0 : in STD_LOGIC;
            TXD0 : out STD_LOGIC;
            RXD1 : in STD_LOGIC;
            TXD1 : out STD_LOGIC );
    end component;
    
    -- Stimulus signals - signals mapped to the input and inout ports of tested entity
    signal clk_in : STD_LOGIC;
    signal reset_n : STD_LOGIC;
    signal RXD0 : STD_LOGIC;
    signal RXD1 : STD_LOGIC;
    -- Observed signals - signals mapped to the output ports of tested entity
    signal TXD0 : STD_LOGIC;
    signal TXD1 : STD_LOGIC;
    
    
    
begin
    
    -- Unit Under Test port map
    UUT : fpga_top
    port map (
        clk_in => clk_in,
        reset_n => reset_n,
        RXD0 => RXD0,
        TXD0 => TXD0,
        RXD1 => RXD1,
        TXD1 => TXD1
        );
    
    -- Add your stimulus here ...
    
    -- generate a clock
    process
    begin
        clk_in <= '0';
        wait for 5ns;
        clk_in <= '1';
        wait for 5ns;
    end process;
    
    -- generate a reset
    process
    begin
        reset_n <= '0';
        wait for 125ns;
        reset_n <= '1';
        wait;
    end process;
    
    -- wrap output back to input of second uart
    RXD1 <= TXD0;
    
    
end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_fpga_top of fpga_top_tb is
    for TB_ARCHITECTURE
        for UUT : fpga_top
            use entity work.fpga_top(rtl);
        end for;
    end for;
end TESTBENCH_FOR_fpga_top;

