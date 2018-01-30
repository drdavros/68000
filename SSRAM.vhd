--
-- SRAM module
--
-- 

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity SSRAM is
    generic(
        AddrWidth	: integer := 14
        );
    port(
        Clk			: in std_logic;
        CE_n		: in std_logic;
        WE_n		: in std_logic;
        A			: in std_logic_vector(AddrWidth - 1 downto 0);
        DIn			: in std_logic_vector(15 downto 0);
        Bite        : in std_logic_vector(1 downto 0);
        DOut		: out std_logic_vector(15 downto 0)
        );
end SSRAM;

architecture behaviour of SSRAM is
    
    -- memory is byte wide
    type Memory_Image is array (natural range <>) of std_logic_vector(7 downto 0);
    signal	RAM0		: Memory_Image(0 to 2 ** AddrWidth - 1);
    signal	RAM1		: Memory_Image(0 to 2 ** AddrWidth - 1);
    signal	A_r		: std_logic_vector(AddrWidth - 1 downto 0);
    
begin
    
    -- register address
    process (Clk)
    begin
        if rising_edge(Clk) then
            A_r <= A;
        end if;
    end process;
    
    
    
    -- ram memory
    process (Clk)
    begin
        if rising_edge(Clk) then
            if (CE_n = '0' and WE_n = '0' and Bite(0) = '0') then
                RAM0(to_integer(unsigned(A))) <= DIn(7 downto 0);
            end if;
            
            -- big endian
            DOut(7 downto 0) <= RAM0(to_integer(unsigned(A_r)));
            -- pragma translate_off
            -- when not is_x(A_r) else (others => '-')
            -- pragma translate_on
        end if;
    end process;
    
    -- ram memory
    process (Clk)
    begin
        if rising_edge(Clk) then
            if (CE_n = '0' and WE_n = '0' and Bite(1) = '0') then
                RAM1(to_integer(unsigned(A))) <= DIn(15 downto 8);
            end if;
            
            -- big endian
            DOut(15 downto 8) <= RAM1(to_integer(unsigned(A_r)));
            -- pragma translate_off
            -- when not is_x(A_r) else (others => '-')
            -- pragma translate_on
        end if;
    end process;
    
    
    
    
end;
