library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
port(
	--inputs
	clk : in std_logic; 
	nRst, we3   : in std_logic; --Write enable signal
	wd3         : in std_logic_vector(31 downto 0); --Data to be written to register. write bus is 31 to 0 size
	a1, a2, a3  : in std_logic_vector(4 downto 0); --selector value for registers, 4 to 0 size.

	rd1, rd2    : out std_logic_vector(31 downto 0)); --output databus. read bus is 31 to 0 size
	--isnt there supossed to be a reset here somewhere?
end entity;

architecture behave of regfile is --behave type?
	type ramtype is array (31 downto 0) of std_logic_vector (31 downto 0);

	signal mem : ramtype; --memory module stored in system, 2d array.
	
	function RegisterInstance(signal inputSel: std_logic_vector(4 downto 0)) return integer is
	--uses selection bit and typical case logic to discern specific register to be accessed.
	variable memInstance : integer := 0;
	begin
		if inputSel(4) = '1' then
		memInstance := memInstance + 16;
		end if;

		if inputSel(3) = '1' then
		memInstance := memInstance + 8;
		end if;
		
		if inputSel(2) = '1' then
		memInstance := memInstance + 4;
		end if;

		if inputSel(1) = '1' then
		memInstance := memInstance + 2;
		end if;

		if inputSel(0) = '1' then
		memInstance := memInstance + 1;
		end if;

		return memInstance;
	end function;

	--implementing safeties?
	procedure RegisterWrite(signal inputData :in std_logic_vector(31 downto 0);
				signal inputSel  :in std_logic_vector(4 downto 0);
				signal mem       :inout ramtype) is
	variable memInstance : integer;
	begin
		memInstance := RegisterInstance(inputSel);

		mem(memInstance) <= inputData;
	end procedure;	

	procedure RegisterRead( signal inputSel : in std_logic_vector(4 downto 0);
				signal mem    : inout ramtype;
				signal outputData : out std_logic_vector(31 downto 0)) is
	variable memInstance : integer;
	begin
		--we can add if statement into procedure if thats allowed.
		memInstance := RegisterInstance(inputSel);
		
		outputData <= mem(memInstance);

	end procedure;

begin

	process (clk) is
	begin

	if rising_edge(clk) then
		
	if nRst = '0' then
		for i in 0 to 31 loop
		mem(i) <= x"00000000"; --setting values of registers all to 0.
		end loop;
	else
		
		if we3 = '1' then
		
		RegisterWrite(wd3, a3, mem);
		
		else --replace with endif if not caring about reading and writing at the same time.
			if a1 = "00000" then
			rd1 <= (others => '0');
			else
			RegisterRead(a1, mem, rd1);
			end if;

			if a2 = "00000" then
			rd2 <= (others => '0');
			else
			RegisterRead(a2, mem, rd2);
			end if;

		end if;
	end if;

	end if;

	end process;

end architecture;
