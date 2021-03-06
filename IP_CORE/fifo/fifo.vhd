--------------------------------------------------------------------------------
--
-- Design unit generated by Aldec IP Core Generator, version 8.1.
-- Copyright (c) 1997 - 2008 by Aldec, Inc. All rights reserved.
--
--------------------------------------------------------------------------------
--
-- Created on Saturday 2013-12-14, 8:31:28
--
--------------------------------------------------------------------------------
-- Details:
--		Type: First In - First Out (FIFO) Memory 
--		Data width: 8
--		Depth: 16
--		Clock input CLK active high
--		Clock enable input CE active high
--		Synchronous Clear input CLR active high
--		Read input RD active high
--		Write input WR active high
--		Empty flag output EMPTY active high
--		Full flag output FULL active high
--------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {fifo} architecture {fifo_arch}}

library IEEE;
use IEEE.std_logic_1164.all;

entity fifo is
	port(
		CE : in std_logic;
		CLR : in std_logic;
		CLK : in std_logic;
		RD : in std_logic;
		WR : in std_logic;
		DATA : in std_logic_vector(7 downto 0);
		EMPTY : out std_logic;
		FULL : out std_logic;
		Q : out std_logic_vector(7 downto 0)
	);
end entity;

--}} End of automatically maintained section

library IEEE;
use IEEE.std_logic_unsigned.all;

architecture fifo_arch of fifo is

	type fifo_array_type is array (15 downto 0) of std_logic_vector(7 downto 0);

	signal fifo_array : fifo_array_type;
	signal WR_PTR : INTEGER range 0 to 15;
	signal RD_PTR : INTEGER range 0 to 15;

begin

	process (CLK)
	begin

		if rising_edge(CLK) then
			if CE = '1' then
				if CLR = '1' then
					for INDEX in 15 downto 0 loop
						fifo_array(INDEX) <= (others => '0');
					end loop;
				elsif WR = '1' then
					fifo_array(WR_PTR) <= DATA;
				end if;
			end if;
		end if;

	end process;

	process (CLK)
		variable PTR : INTEGER range 0 to 16;
	begin

		if rising_edge(CLK) then
			if CE = '1' then
				if CLR = '1' then
					WR_PTR <= 0;
					RD_PTR <= 0;
					EMPTY <= '1';
					FULL <= '0';
					PTR := 0;
				elsif WR = '1' and PTR < 16 then
					if WR_PTR < 15 then
						WR_PTR <= WR_PTR + 1;
					elsif WR_PTR = 15 then
						WR_PTR <= 0;
					end if;
					PTR := PTR + 1;
				elsif RD = '1' and PTR > 0 then
					if RD_PTR<15 then
						RD_PTR <= RD_PTR + 1;
					elsif RD_PTR = 15 then
						RD_PTR <= 0;
					end if;
					PTR := PTR - 1;
				end if;

				if PTR = 0 then
					EMPTY <= '1';
				else
					EMPTY <= '0';
				end if;

				if PTR = 16 then
					FULL<= '1';
				else
					FULL <= '0';
				end if;
			end if;
		end if;

	end process;

	Q <= fifo_array(RD_PTR) when RD = '1' else (others => 'Z');

end architecture;
