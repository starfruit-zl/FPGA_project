library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity extend_unit is
port(
		--inputs
	    imm_in      : in std_logic_vector(31 downto 7);
            extend_ctrl : in std_logic_vector(2 downto 0);
            imm_out     : out std_logic_vector(31 downto 0));
end entity;

architecture behave of extend_unit is
begin

	process (imm_in, extend_ctrl) is
	variable immWork : std_logic_vector(31 downto 0);
	begin

		case extend_ctrl is
		when "000" => --I-Type.
			for i in 0 to 11 loop
			immWork(i) := imm_in(20 + i);
			end loop;

			for i in 12 to 31 loop
			immWork(i) := imm_in(31);
			end loop;

		when "001" => --S-Type
			for i in 0 to 4 loop
			immWork(i) := imm_in(7+i);
			end loop;

			for i in 5 to 11 loop
			immWork(i) := imm_in(20+i); --grabs first value from 25.
			end loop;

			for i in 12 to 31 loop
			immWork(i) := imm_in(31);
			end loop;

		when "010" => --B-Type

			immWork(0) := '0';

			for i in 1 to 4 loop
			immWork(i) := imm_in(7+i);
			end loop;

			for i in 5 to 10 loop
			immWork(i) := imm_in(20+i);
			end loop;

			immWork(11) := imm_in(7);
			
			for i in 12 to 31 loop
			immWork(i) := imm_in(31);
			end loop;

		when "011" =>--U-Type
			
			for i in 0 to 11 loop
			immWork(i) := '0';
			end loop;

			for i in 12 to 31 loop
			immWork(i) := imm_in(i);
			end loop;

		when "100" =>--J-Type
			
			immWork(0) := '0';

			for i in 1 to 10 loop
			immWork(i) := imm_in(31-i);
			end loop;
	
			immWork(11) := imm_in(20);

			for i in 12 to 19 loop
			immWork(i) := imm_in(i);
			end loop;

			for i in 20 to 31 loop
			immWork(i) := imm_in(31);
			end loop;

		when others =>
			immWork := (others => 'X');
		end case;

			imm_out <= immWork; --take set immWork value and set it to output.
	end process;


end architecture;