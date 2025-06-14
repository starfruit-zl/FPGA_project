library IEEE;
 use IEEE.STD_LOGIC_1164.all;
 use STD.TEXTIO.all;
 use IEEE.NUMERIC_STD.all;
 entity dmem is
    port(clk, we, datatype, reset: in  STD_LOGIC := '0';
         a, wd:   in  STD_LOGIC_VECTOR(31 downto 0) := (others=>'0');
	 datasize : in STD_LOGIC_VECTOR(1 downto 0) := "00";
         rd:      out STD_LOGIC_VECTOR(31 downto 0) := (others=>'0'));
 end;
 architecture behave of dmem is
        type ramtype is  array (63 downto 0) of STD_LOGIC_VECTOR(31 downto 0);
        signal mem: ramtype;
	signal readValue : STD_LOGIC_VECTOR(31 downto 0);
 begin
    process(clk) is
    begin
--Memory access protocol: Data type signal to select.
--	Full word: Max available address.
--	Half word: use data address signal's first bit to determine region.
--	Byte access: use data address signal's two bits.

           if rising_edge(clk) then

	       if reset = '1' then
			for i in 63 downto 0 loop
			mem(i) <= x"00000000";
			end loop;
		end if;

               if (we = '1') then 
			case datasize is 

			when "00" => --word size
			mem(to_integer(unsigned(a(7 downto 2)))) <= wd;

			when "01" => --halfword size
				if (a(1 downto 0) = "00" or a(1 downto 0) = "01") then --why specify the two bits?
				mem(to_integer(unsigned(a(7 downto 2))))(15 downto 0) <= wd(15 downto 0);
				elsif (a(1 downto 0)) = "10" or a(1 downto 0) = "11" then
				mem(to_integer(unsigned(a(7 downto 2))))(31 downto 16) <= wd(15 downto 0);
				end if;
		
			when "10" => --byte size
				case (a(1 downto 0)) is
				when "00" =>
					mem(to_integer(unsigned(a(7 downto 2))))(7 downto 0) <= wd(7 downto 0);
				when "01" =>
					mem(to_integer(unsigned(a(7 downto 2))))(15 downto 8) <= wd(7 downto 0);
				when "10" =>
					mem(to_integer(unsigned(a(7 downto 2))))(23 downto 16) <= wd(7 downto 0);
				when "11" =>
					mem(to_integer(unsigned(a(7 downto 2))))(31 downto 24) <= wd(7 downto 0);
				when others =>
				end case;
			when others =>
			end case;
               end if;
            end if;
	end process;
        --asigning the value of muxes to rd

	with (datasize & datatype & a(1 downto 0)) select --5 bits
		--words
		 rd<=   mem(to_integer(unsigned(a(7 downto 2)))) when "00000"|"00001"|"00010"|"00011"|"00100"|"00101"|"00110"|"00111",
		--halfwords
			--datatype '0'
			(31 downto 16 => mem(to_integer(unsigned(a(7 downto 2))))(15)) & mem(to_integer(unsigned(a(7 downto 2))))(15 downto 0) when "01000"|"01001",
			(31 downto 16 => mem(to_integer(unsigned(a(7 downto 2))))(31)) & mem(to_integer(unsigned(a(7 downto 2))))(31 downto 16) when "01010"|"01011",
			--datatype '1'
			(31 downto 16 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(15 downto 0) when "01100"|"01101",
			(31 downto 16 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(31 downto 16) when "01110"|"01111",
		--bytes
			 --datatype '0'
			(31 downto 8 => mem(to_integer(unsigned(a(7 downto 2))))(7)) & mem(to_integer(unsigned(a(7 downto 2))))(7 downto 0) when "10000",
			(31 downto 8 => mem(to_integer(unsigned(a(7 downto 2))))(15)) & mem(to_integer(unsigned(a(7 downto 2))))(15 downto 8) when "10001",
			(31 downto 8 => mem(to_integer(unsigned(a(7 downto 2))))(23)) & mem(to_integer(unsigned(a(7 downto 2))))(23 downto 16)	when "10010",
			(31 downto 8 => mem(to_integer(unsigned(a(7 downto 2))))(31)) & mem(to_integer(unsigned(a(7 downto 2))))(31 downto 24)	when "10011",
			--datatype '1'
			(31 downto 8 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(7 downto 0) when "10100",
			(31 downto 8 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(15 downto 8) when "10101",
			(31 downto 8 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(23 downto 16) when "10110",	
			(31 downto 8 => '0') & mem(to_integer(unsigned(a(7 downto 2))))(31 downto 24) when "10111",

		(others => '0') when others;
 end; 
