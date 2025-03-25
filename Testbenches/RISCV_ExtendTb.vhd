library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL; --changed the library to the numeric standard.

entity extend_unit_tb is
end extend_unit_tb;

architecture testbench of extend_unit_tb is


	constant I_Type : std_logic_vector(2 downto 0) := "000";
	constant S_Type : std_logic_vector(2 downto 0) := "001";
	constant B_Type : std_logic_vector(2 downto 0) := "010";
	constant U_Type : std_logic_vector(2 downto 0) := "011";
	constant J_Type : std_logic_vector(2 downto 0) := "100";

    signal imm_in      : std_logic_vector(31 downto 7);
    signal extend_ctrl : std_logic_vector(2 downto 0);
    signal imm_out     : std_logic_vector(31 downto 0);

    -- Instantiate the Extend Unit module, !!may need to move to 
    component extend_unit
        port (
            imm_in      : in std_logic_vector(31 downto 7);
            extend_ctrl : in std_logic_vector(2 downto 0);
            imm_out     : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    dut: extend_unit port map (
        imm_in      => imm_in,
        extend_ctrl => extend_ctrl,
        imm_out     => imm_out
    );

	process
	begin
	
		--  Case 1: I_Type:  ADDI x5, x1, -10 --
		extend_ctrl <= I_Type;
		imm_in <= "111111110110" & "0000100000101";
		wait for 10 ns;
		
		assert to_integer(signed(imm_out)) = -10 report "Case 1: Failed";
		
		-- Case 2: S_Type:  SW x6, -52 --
		extend_ctrl<= S_Type;
		imm_in <= "1111110" & "00110" & "00010" & "010" &  "01100";
		wait for 10 ns;
		
		assert to_integer(signed(imm_out)) = -52 report "Case 2: Failed";
		
		-- Case 3: J_Type:  JAL x1, 1024 --
		extend_ctrl<= J_Type;
		imm_in <= '0' & "1000000000" & '0' & "00000000" & "00001";
		wait for 10 ns;
		
		assert to_integer(signed(imm_out)) = 1024 report "Case 3: Failed";
		
		-- Case 4: B_Type:  BEQ x3, x4, -16 --
		extend_ctrl <= B_Type;
		imm_in <= '1' & "111111" & "00100" &  "00011" & "000" & "1000" & '1';
		wait for 10 ns;
		
		assert to_integer(signed(imm_out)) = -16 report "Case 4: Failed";
		
		-- Case 5: U_Type:  LUI x7, 0x12345 --
		extend_ctrl <= U_Type;
		imm_in <= x"12345" & "00111";
		wait for 10 ns;
		
		assert imm_out = x"12345000" report "Case 5: Failed";
		
		
		report "Test Bench Complete";
		wait;
	
	end process;	
end testbench;
