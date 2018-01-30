-- file_io.vhdl   write and read disk files in VHDL
--                typically used to load RAM or ROM, supply test input data, 
--                record test output (possibly for further analysis)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity file_io is  -- test bench
    port (
        clock   : in std_logic;
        reset_n : in std_logic;
        addr    : in std_logic_vector(31 downto 0);
        rw      : in std_logic;
        addr_strobe : in std_logic
        );
end file_io;


architecture test of file_io is
    signal ready : std_logic;
begin
    
    
    --    read_file:
    --        process    -- read file_io.in (one time at start of simulation)
    --        file my_input : TEXT open READ_MODE is "file_io.in";
    --        variable my_line : LINE;
    --        variable my_input_line : LINE;
    --    begin
    --        write(my_line, string'("reading file"));
    --        writeline(output, my_line);
    --        loop
    --            exit when endfile(my_input);
    --            readline(my_input, my_input_line);
    --            -- process input, possibly set up signals or arrays
    --            writeline(output, my_input_line);  -- optional, write to std out
    --        end loop;
    --        wait; -- one shot at time zero,
    --    end process read_file;
    
    process (addr_strobe, reset_n, clock, ready)
        file my_output : TEXT open WRITE_MODE is "log_file.txt";
        -- above declaration should be in architecture declarations for multiple
        variable my_line : LINE;
        variable my_output_line : LINE;
    begin
        
        if rising_edge(reset_n) then
            -- do this one time (hopefully)
            write(my_output_line, string'("output from tb_logger.vhdl"));
            writeline(my_output, my_output_line);
        end if;
        
        if reset_n = '0' then
            ready <= '0';
        elsif rising_edge(clock) then
            ready <= '0';
        end if;
        
        
        if falling_edge(addr_strobe) then
            ready <= '1';
            -- prints to console
            --                write(my_line, string'("writing file"));
            --                writeline(output, my_line);
            
            -- prints to file
            
            --                write(my_output_line, done);    -- or any other stuff
            --                writeline(my_output, my_output_line);
            
            hwrite(my_output_line, addr, left, 16);
            --                hwrite(my_output_line, addr, left, 16);
            --writeline(my_output, my_output_line);
            
            --hwrite(my_output_line, addr, left, 16);
            --            writeline(my_output, my_output_line);
            
        end if;
        
        if falling_edge(ready) then
            if rw = '1' then
                write(my_output_line, string'("Read"));
            else
                write(my_output_line, string'("Write"));
            end if;
            
            --write(my_output_line, rw, left, 16);
            
        end if;
        
        if rising_edge(addr_strobe) then
            writeline(my_output, my_output_line);
        end if;
        
        
    end process;
end architecture test; -- of file_io
