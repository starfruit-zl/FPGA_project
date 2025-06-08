
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RISCV_ALU is
port(
		--inputs
	    A      : in std_logic_vector(31 downto 0);
	    B      : in std_logic_vector(31 downto 0);
            ALU_ctrl  : in std_logic_vector(3 downto 0);
		--outputs
            result    : out std_logic_vector(31 downto 0);
	--flags
            overflow  : out std_logic;
            negative  : out std_logic;
            zero      : out std_logic;
	    carry     : out std_logic);

end entity;

architecture behave of RISCV_ALU is
	signal temp_result : std_logic(32 downto 0);
	signal V : std_logic;
begin

	process (ALU_ctrl, A, B) is
	variable inputA : signed(31 downto 0);
	variable inputB : signed(31 downto 0);
	variable shiftNum : integer;
	variable output : signed(31 downto 0);

	begin
		inputA := signed(A);
		inputB := signed(B);	
		output := (others => '0');
		shiftNum := to_integer(unsigned(B));
		carry <= '0';
		overflow <= '0';
		negative <= '0';
		zero <= '0';		


		case ALU_ctrl is
			when "0000" => --add
				temp_result <= std_logic_vector(inputA + inputB);

			when "0001" | "0111" | "1000" =>  --sub, slt, sltu. Improvement, re-use the sub hardware.
				temp_result <= std_logic_vector(inputA - inputB);

			when "0010" =>  --and (if it turns out that flags are logical, stop setting output will disallow check).
				temp_result <= A and B;

			when "0011" =>  --or
				temp_result <= A or B;

			when "0100" =>  --xor
				temp_result <= A xor B;

			when "0101" =>  --sll --add #B 0's to left of A (I am aware of built-in function, was just curious).
				if shiftNum = 0 then
				temp_result <= A;

				else
				for i in 31 downto shiftNum loop
				inputA(i) := inputA(i-shiftNum);
				end loop;

				for i in shiftNum-1 downto 0 loop
				inputA(i) := '0';
				end loop;
			
				temp_result <= std_logic_vector(inputA);
				end if;

			when "0110" => --srl --add 0 to right

				if shiftNum = 0 then
				temp_result <= A;

				else
				for i in 0 to 31-shiftNum loop --opposite direction as to not attempt to grab undefined values.
				inputA(i) := inputA(i+shiftNum);
				end loop;

				for i in 32-shiftNum to 31 loop
				inputA(i) := '0';
				end loop;

				temp_result <= std_logic_vector(inputA);
				end if;

			when "1001" =>  --sra:


			when others =>
				temp_result <= (others => '0');
		end case;
	end process;

	process (A, B, Temp_Result, ALU_ctrl)
	begin
		if (ALU_ctrl = "0000") then
		V <= (A(31) and B(31) and not(temp_result(31))) or (not(A(31)) and not(B(31)) and temp_result(31));
		
		else
		
		V <= (A(31) and not(B(31)) and not(temp_result(31))) or (not(A(31)) and B(31) and temp_result(31));
		
		end if;
	end process;
	
	with ALU_ctrl select
	result <= (x"0000000" & "000" & (temp_result(31) xor V)) when "0111",
			  else (x"0000000" & "000" & not temp_result(32)) when "1001",
			  else temp_result(31 downto 0);
	
	overflow <= V when alu_ctrl = "0000" or alu_ctrl = "0001" else '0';
	
	zero <= '1' when to_integer(signed(temp_result(31 downto 0))) = 0 else '0';
	
	negative <= temp_result(31) when alu_ctrl = "0000" or ALU_ctrl = "0001" else '0';
	
	carry <= temp_result(32) when ALU_ctrl = "0000" or ALU_ctrl = "0001" else '0';

end architecture;
