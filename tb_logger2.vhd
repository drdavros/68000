LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
use STD.textio.all;

ENTITY write_file IS
END write_file;

ARCHITECTURE beha OF write_file IS
    
BEGIN
    
    --Write process
    process
        file file_pointer : text;
        variable line_content : string(1 to 4);
        variable bin_value : std_logic_vector(3 downto 0);
        variable line_num : line;
        variable i,j : integer := 0;
        variable char : character:='0';
    begin
        --Open the file write.txt from the specified location for writing(WRITE_MODE).
        file_open(file_pointer,"C:\write.txt",WRITE_MODE);     
        --We want to store binary values from 0000 to 1111 in the file.
        for i in 0 to 15 loop
            bin_value := conv_std_logic_vector(i,4);
            --convert each bit value to character for writing to file.
            for j in 0 to 3 loop
                if(bin_value(j) = '0') then
                    line_content(4-j) := '0';
                else
                    line_content(4-j) := '1';
                end if;
            end loop;
            write(line_num,line_content); --write the line.
            writeline (file_pointer,line_num); --write the contents into the file.
            wait for 10 ns;  --wait for 10ns after writing the current line.
        end loop;
        file_close(file_pointer); --Close the file after writing.
        wait;
    end process;
    
end beha;