library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
port(
	--inputs
	clk : in std_logic; 
	clr, we3   : in std_logic; --Write enable signal
	wd3         : in std_logic_vector(31 downto 0); --Data to be written to register. write bus is 31 to 0 size
	a1, a2, a3  : in std_logic_vector(4 downto 0); --selector value for registers, 4 to 0 size.

	--outputs
	rd1, rd2    : out std_logic_vector(31 downto 0)); --output databus. read bus is 31 to 0 size
end entity;

architecture behave of regfile is
	type ramtype is array (31 downto 0) of std_logic_vector (31 downto 0);

	signal mem : ramtype; --memory module stored in system, 2d array.

begin

	process (a1, clk) is
	begin
		if a1 = "00000" then
			rd1 <= (others => '0');

		else
			rd1 <= mem(to_integer(unsigned(a1)));

		end if;
	end process;

	process (a2, clk) is
	begin
		if a2 = "00000" then
			rd2 <= (others => '0');

		else
			rd2 <= mem(to_integer(unsigned(a2)));

		end if;
	end process;

	process (clk) is
	begin

	if rising_edge(clk) then
		
		if clr = '1' then

			for i in 0 to 31 loop
			mem(i) <= (others => '0'); --setting values of registers all to 0.
			end loop;

		elsif we3 = '1' then

			mem(to_integer(unsigned(a3))) <= wd3;

		end if;

	end if;

	end process;


end architecture;
