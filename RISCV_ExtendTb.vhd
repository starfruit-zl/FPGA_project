library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is

end tb;


architecture test of tb is

	constant I_Type : std_logic_vector(2 downto 0) := "000";
	constant S_Type : std_logic_vector(2 downto 0) := "001";
	constant B_Type : std_logic_vector(2 downto 0) := "010";
	constant U_Type : std_logic_vector(2 downto 0) := "011";
	constant J_Type : std_logic_vector(2 downto 0) := "100";

	signal imm : std_logic_vector(31 downto 7) := (others => '0');
	signal immSrc : std_logic_vector(2 downto 0) := (others => '0');
	signal immExt : std_logic_vector(31 downto 0) := (others => '0');
	

begin 

	Extend : entity work.Extend(behave)
		port map
		(
			imm => imm,
			immSrc => immSrc,
			immExt => immExt
		);
		
	process
	begin
	
		--  Case 1: I_Type:  ADDI x5, x1, -10 --
		immSrc <= I_Type;
		imm <= "111111110110" & "0000100000101";
		wait for 10 ns;
		
		assert to_integer(signed(immExt)) = -10 report "Case 1: Failed";
		
		-- Case 2: S_Type:  SW x6, -52 --
		immSrc <= S_Type;
		imm <= "1111110" & "00110" & "00010" & "010" &  "01100";
		wait for 10 ns;
		
		assert to_integer(signed(immExt)) = -52 report "Case 2: Failed";
		
		-- Case 3: J_Type:  JAL x1, 1024 --
		immSrc <= J_Type;
		imm <= '0' & "1000000000" & '0' & "00000000" & "00001";
		wait for 10 ns;
		
		assert to_integer(signed(immExt)) = 1024 report "Case 3: Failed";
		
		-- Case 4: B_Type:  BEQ x3, x4, -16 --
		immSrc <= B_Type;
		imm <= '1' & "111111" & "00100" &  "00011" & "000" & "1000" & '1';
		wait for 10 ns;
		
		assert to_integer(signed(immExt)) = -16 report "Case 4: Failed";
		
		-- Case 5: U_Type:  LUI x7, 0x12345 --
		immSrc <= U_Type;
		imm <= x"12345" & "00111";
		wait for 10 ns;
		
		assert immExt = x"12345000" report "Case 5: Failed";
		
		
		report "Test Bench Complete";
		wait;
	
	end process;	
end test;
