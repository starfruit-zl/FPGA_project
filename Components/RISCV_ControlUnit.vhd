
library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity RISCV_ControlUnit is
port(
		--inputs
	signal zero   : in std_logic; --Wired to the zero signal of the ALU, Flag activates triggering output.
	signal op     : in std_logic_vector(6 downto 0);
	signal funct3 : in std_logic_vector(2 downto 0);
	signal funct7 : in std_logic_vector(6 downto 0);
		--outputs
	signal PCSrc     : out std_logic; -- whether PC is using PC+4 (0) or PC+offset (1).
	signal ResultSrc : out std_logic_vector(1 downto 0); --0 means ALU as src, 1 means Mem, "10"(2) means PC+4 is written into the regfile for JAL and JALR instruction
	signal MemWrite  : out std_logic; -- interfaces with register, write enable signal/
	signal ALUSrc    : out std_logic; --immediate or register value
	signal ImmSrc    : out std_logic_vector(2 downto 0); --specified as 2, but need 3.
	signal RegWrite  : out std_logic; --write enable signal
	signal ALUControl: out std_logic_vector(2 downto 0));

end entity;

architecture behave of RISCV_ControlUnit is

begin
	process(zero, op, funct3, funct7) is
	begin
	--defaults
	PCSrc      <= '0'; -- PC+4
	ResultSrc  <= "00"; --directly output ALU (as opposed to data from mem)
	MemWrite   <= '0'; --Don't ALU (or mem Data) write to memory
	ALUSrc     <= '0'; -- whether loading register 2 (default) or an immediate (if using funct7?)
	ImmSrc     <= "XXX"; -- Which immediate type, default as don't care.
	RegWrite   <= '0'; -- Don't write to Reg (1 enables).
        ALUControl <= "000"; -- Select ADD in ALU .


	case op is 
		when "0110011" => --mostly R/I-shift type.
		case funct3 is
			when "000" => --add or sub
				if funct7(5) = '1' then --sub
				RegWrite <= '1';
				ALUControl <= "001";
				else  -- add
				RegWrite <= '1';
				end if;
		
			when "111" => --and
				RegWrite <= '1';
				ALUControl <= "010";

			when "110" => --or
				RegWrite <= '1';
				ALUControl <= "011";

			when "100" => --xor
				RegWrite <= '1';
				ALUControl <= "100";

			when "001" => --SLL
				RegWrite <= '1';
				ALUControl <= "101";

			when "101" => --SRL
				RegWrite <= '1';
				ALUControl <= "110";

			when "010" => --SLT
				RegWrite <= '1';
				ALUControl <= "111";

			when others =>

		end case;

		when "0000011" => --only LW(Load Word), funct3=010. 
			ResultSrc <= "01";
			ALUSrc <= '1';
			ImmSrc <= "000"; --I-Type

		when "0100011" => --only SW(Store Word), funct3=010.
			MemWrite <= '1';
			ALUSrc <= '1';
			ImmSrc <= "001"; --S-Type
		
		when "1100011" => --regwrite stays off, memwrite stays off
			ImmSrc <= "010"; --B-Type.
			ALUControl <= "001";
			if funct3(0) = '1' then -- Branch if not Equal (BNQ)
				if zero = '0' then --if r1-r2 != 0, then branch.
				PCSrc <= '1';
				--else: default, PC + 4.
				end if;
			else -- Branch if Equal (BEQ)
				if zero = '1' then -- r1-r2 = 0 then branch.
				PCSRC <= '1';
				--else: default, PC + 4.	
				end if;
			end if;
		
		when "1101111" => --only JAL
			PCSrc <= '1';
			ResultSrc <= "10"; --output PC+4 as result.
			ImmSrc <= "100"; -- J-type
			RegWrite <= '1';
			--Loading PC+4 to reg? Maybe not drawn in processor diagram.

		when "1100111" => -- JALR, funct3 = 000
			PCSrc <= '1';
			ALUSrc <= '1';
			ResultSrc <= "10"; --output PC+4 as result.
			ImmSrc <= "000"; --I-Type
			RegWrite <= '1';
			--Loading PCNext <= PC+Imm+rd?		

		when "0010011" =>
		case funct3 is
			when "000" => --ADDI
				ImmSrc <= "000"; --I-Type
				--Add is default.
				ALUSrc <= '1';
				RegWrite <= '1';

			when "111" => --ANDI
				RegWrite <= '1';
				ALUControl <= "010";
				ImmSrc <= "000"; --I-Type
				ALUSrc <= '1';

			when "001" => --SLLI
				RegWrite <= '1';
				ALUControl <= "101";
				ImmSrc <= "000"; --I-Type
				ALUSrc <= '1';

			when "101" => --SRLI
				RegWrite <= '1';
				ALUControl <= "110";
				ImmSrc <= "000"; --I-Type
				ALUSrc <= '1';

			when "010" => --SLTI
				RegWrite <= '1';
				ALUControl <= "111";
				ImmSrc <= "000"; --I-Type
				ALUSrc <= '1';
			
			when others =>

		end case;

		when "0110111" => --LUI
			ImmSrc <= "011";
			ALUSrc <= '1';
			RegWrite <= '1';

		when others =>
			
	end case;

	
	end process;


end architecture;