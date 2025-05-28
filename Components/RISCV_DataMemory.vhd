library IEEE;
 use IEEE.STD_LOGIC_1164.all;
 use STD.TEXTIO.all;
 use IEEE.NUMERIC_STD_UNSIGNED.all;
 entity dmem is
    port(clk, we: in  STD_LOGIC;
         a, wd:   in  STD_LOGIC_VECTOR(31 downto 0);
         rd:      out STD_LOGIC_VECTOR(31 downto 0));
 end;
 architecture behave of dmem is
 begin
    process is
        type ramtype is  array (63 downto 0) of  
STD_LOGIC_VECTOR(31 downto 0);
        variable mem: ramtype;
    begin
         loop
           if rising_edge(clk) then
               if (we = '1') then mem(to_integer(a(7 downto 2))) := wd;
                 end if;
            end if;
            rd <= mem(to_integer(a(7 downto 2))); --address 100 is 1100100, ignore 2 last bits
            wait on clk, a; --take it out when uploading to fpga
         end loop;
     end process;
 end; 
