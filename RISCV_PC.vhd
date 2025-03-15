library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity pc is
port (
            clk : in std_logic;
            reset : in std_logic;
            pc_in : in std_logic_vector(31 downto 0);
            pc_out : out std_logic_vector(31 downto 0)
        );
end entity;

architecture behave of pc is
	signal pcReg : std_logic_vector(31 downto 0); --maybe not needed.
begin

	process (clk) is

	begin
	
	if rising_edge(clk) then

		if reset = '1' then
		pc_out <= (others => '0');

		else
		pc_out <= pc_in;

		end if;
		
	end if;
	end process;


end architecture;
