
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RISCV_ALU is --NO CLOCK
port(
		--inputs
	    A, B      : in std_logic_vector(31 downto 0);
            ALU_ctrl  : in std_logic_vector(2 downto 0);
		--outputs
            result    : out std_logic_vector(31 downto 0);
	--flags
            overflow  : out std_logic;
            negative  : out std_logic;
            zero      : out std_logic);

end entity;

architecture behave of RISCV_ALU is

begin

	process (ALU_ctrl, A, B) is
	variable inputA : signed(31 downto 0);
	variable inputB : signed(31 downto 0);

	begin
		inputA := signed(A);
		inputB := signed(B);	
		
		case ALU_ctrl is
			when "000" => 
			result <= std_logic_vector(inputA + inputB);
			
			when "001" =>  --sub
			result <= std_logic_vector(inputA - inputB);

			when "010" =>  --and
			result <= A and B;

			when "011" =>  --or
			result <= A or B;

			when "100" =>  --xor
			result <= A xor B;

			when "101" =>  --sll
			

			when "110" => --srl


			when "111" =>  --slt
			

			when others =>


		end case;

	end process;


end architecture;