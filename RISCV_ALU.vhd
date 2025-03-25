
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RISCV_ALU is
port(
		--inputs
	    A      : in std_logic_vector(31 downto 0);
	    B      : in std_logic_vector(31 downto 0);
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
	variable shiftNum : integer;
	variable output : signed(31 downto 0);
	variable OV : boolean;

	begin
		inputA := signed(A);
		inputB := signed(B);	
		output := (others => '0');
		shiftNum := to_integer(unsigned(B));
		overflow <= '0';
		negative <= '0';
		zero <= '0';		


		case ALU_ctrl is
			when "000" => 
				output := inputA + inputB;
				result <= std_logic_vector(inputA + inputB);
				
				if (((A(31) and B(31) and not output(31))) or (not A(31) and not B(31) and output(31)))= '1' then --overflow, with override, as in can be triggered earlier, won't overwrite. Most general: inputA and B are one sign, output another.
				overflow <= '1';
				end if;
			when "001" =>  --sub
				output := inputA - inputB;
				result <= std_logic_vector(inputA - inputB);

				if ((not A(31) and B(31) and not output(31)) or (A(31) and not B(31) and not output(31))) = '1' then --overflow, with override, as in can be triggered earlier, won't overwrite. Most general: inputA and B are one sign, output another.
				overflow <= '1';
				end if;

			when "010" =>  --and (if it turns out that flags are logical, stop setting output will disallow check).
				output := inputA and inputB;
				result <= A and B;

			when "011" =>  --or
				output := inputA or inputB;
				result <= A or B;

			when "100" =>  --xor
				output := inputA xor inputB;
				result <= A xor B;

			when "101" =>  --sll --add #B 0's to left of A (I am aware of built-in function, was just curious).
				if shiftNum = 0 then
				result <= A;

				else
				for i in 31 downto shiftNum loop
				inputA(i) := inputA(i-shiftNum);
				end loop;

				for i in shiftNum-1 downto 0 loop
				inputA(i) := '0';
				end loop;
			
				result <= std_logic_vector(inputA);
				end if;
				output := inputA;
				
				if output(31) /= A(31) then --assumed overflow: change of sign from shift.
				overflow <= '1';
				end if;

			when "110" => --srl --add 0 to right

				if shiftNum = 0 then
				result <= A;

				else
				for i in 0 to 31-shiftNum loop --opposite direction as to not attempt to grab undefined values.
				inputA(i) := inputA(i+shiftNum);
				end loop;

				for i in 32-shiftNum to 31 loop
				inputA(i) := '0';
				end loop;

				result <= std_logic_vector(inputA);
				end if;
				output := inputA;

				if output(31) /= A(31) then --assumed overflow: change of sign from shift.
				overflow <= '1';
				end if;

			when "111" =>  --slt
				output := inputA - inputB;

				if output(31) = '1' then
				result <= x"00000001";
				output := x"00000001";			

				else
				result <= (others => '0');
				output := (others => '0');	
				
				end if;
				

			when others =>
				result <= (others => '0');
		end case;
		--updating flags

		if output(31) = '1' then --negative
		negative <= '1';
		end if;

		if output = "0" then
		zero <= '1';
		end if;
	end process;


end architecture;
