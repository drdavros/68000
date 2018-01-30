--
-- ROMs Using Block RAM Resources.
-- VHDL code for a ROM with registered output (template 1)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity rom is
    port (clk : in std_logic;
        en : in std_logic;
        addr : in std_logic_vector(7 downto 0);
        data : out std_logic_vector(15 downto 0));
end rom;

architecture syn of rom is
    type rom_type is array (0 to 255) of std_logic_vector (15 downto 0);
    signal ROM : rom_type:= 
        (
        X"0001", X"FFFF", X"0000", X"0020", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"163C", X"0041", X"267C", X"0008", X"0000", X"287C",X"0008", X"0002",
        X"1683", X"1814", X"0804", X"0010", X"67F8", X"4E71",X"4E71", X"4E71",
        X"4E71", X"4EF8", X"0020", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA",
        X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA", X"EAEA",X"EAEA", X"EAEA"
    );
    
begin
    process (clk)
    begin
        if (clk'event and clk = '1') then
            if (en = '1') then
                data <= ROM(conv_integer(addr));
            end if;
        end if;
    end process;
end syn; 