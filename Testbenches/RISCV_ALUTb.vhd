library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUTb is
end ALUTb;

architecture sim of ALUTb is
    signal A, B     : std_logic_vector(31 downto 0);
    signal ALU_ctrl : std_logic_vector(2 downto 0);
    signal result   : std_logic_vector(31 downto 0);
    signal overflow, negative, zero : std_logic;

begin
    -- Instantiate ALU
    i_riscvalu : entity work.RISCV_ALU(behave) 
    port map (A => A, 
	B => B, 
	ALU_ctrl => ALU_ctrl, 
	result => result, 
	overflow => overflow, 
	negative => negative, 
	zero => zero);

    process is
    begin
        -- Test ADD (No Overflow)
        A <= X"7FFFFFFE"; B <= X"00000001"; ALU_ctrl <= "000"; wait for 10 ns;
        -- ADD Test (Overflow)
        A <= X"7FFFFFFF"; B <= X"00000001"; ALU_ctrl <= "000"; wait for 10 ns;
        
        -- SUB Test (Negative)
        A <= X"00000002"; B <= X"00000003"; ALU_ctrl <= "001"; wait for 10 ns;
				-- Test Zero Flag
        A <= X"00000005"; B <= X"00000005"; ALU_ctrl <= "001"; wait for 10 ns;
        -- AND Test
        A <= X"0000000F"; B <= X"00000007"; ALU_ctrl <= "010"; wait for 10 ns;

        -- OR Test
        A <= X"0000000F"; B <= X"00000007"; ALU_ctrl <= "011"; wait for 10 ns;

        -- XOR Test
        A <= X"0000000F"; B <= X"00000007"; ALU_ctrl <= "100"; wait for 10 ns;

        -- Shift Left Test
        A <= X"00000001"; B <= X"00000002"; ALU_ctrl <= "101"; wait for 10 ns;
	
	--Shift Left Zero Test
	A <= X"00000001"; B <= X"00000000"; ALU_ctrl <= "101"; wait for 10 ns;

	--Shift Left Overflow Test
	A <= X"00000001"; B <= X"0000001F"; ALU_ctrl <= "101"; wait for 10 ns;

        -- Shift Right Test
        A <= X"00000008"; B <= X"00000002"; ALU_ctrl <= "110"; wait for 10 ns;

        -- SLT Test
        A <= X"00000005"; B <= X"00000007"; ALU_ctrl <= "111"; wait for 10 ns;

        -- Stop Simulation
        wait;
    end process;
end architecture;


