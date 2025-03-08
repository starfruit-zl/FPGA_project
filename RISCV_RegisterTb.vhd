library ieee;
use ieee.std_logic_1164.all; 
use ieee.numeric_std.all;


entity RISCv_RegisterTb is
end entity;

architecture sim of RISCv_RegisterTb is
	--slowing down the clock speed to speed up simulation time
	constant ClockFrequency : integer := 100e6; -- 100 MHz
	constant clk_period    : time    := 1000 ms / ClockFrequency;

	signal clk : std_logic := '1';
	signal clr : std_logic := '1';
	signal we3 : std_logic := '0';
	signal wd3 : std_logic_vector(31 downto 0); --Data to be written to register. write bus is 31 to 0 size
	signal a1  : std_logic_vector(4 downto 0); --selector value for registers, 4 to 0 size.
	signal a2  : std_logic_vector(4 downto 0); --selector value for registers, 4 to 0 size.
	signal a3  : std_logic_vector(4 downto 0); --selector value for registers, 4 to 0 size.

	signal rd1 : std_logic_vector(31 downto 0); --output databus. read bus is 31 to 0 size
	signal rd2 : std_logic_vector(31 downto 0); --output databus. read bus is 31 to 0 size
	
begin
	i_regfile : entity work.regfile(behave)
	port map(
		clk => clk,
		clr => clr,
		we3 => we3,
		wd3 => wd3,
		a1 => a1,
		a2 => a2,
		a3 => a3,
		rd1 => rd1,
		rd2 => rd2);

	clk <= not clk after clk_Period / 2;

process is
begin
    -- Case 1: Initialize clock, reset, and control signals
    CLR  <= '1';
    WE3  <= '0';
    WD3  <= (others => '0');
    A1   <= (others => '0');
    A2   <= (others => '0');
    A3   <= (others => '0');
    WAIT FOR clk_period;
    WAIT FOR clk_period;

    ASSERT RD1 = x"00000000" AND RD2 = x"00000000" REPORT "Case 1: FAIL" SEVERITY ERROR;

    -- Disable clear
    CLR  <= '0';
    WAIT FOR clk_period;

    -- Case 2: Write disabled, attempt write
    WE3  <= '0';
    A3   <= "00100";  -- Register 4
    WD3  <= x"0ABCDEF0";
    A2   <= "00100";
    WAIT FOR clk_period;
    ASSERT RD2 /= x"0ABCDEF0" REPORT "Case 2: FAIL" SEVERITY ERROR;

    -- Case 3: Write enabled, write to register 4
    WE3  <= '1';
    WAIT FOR clk_period;
    WAIT FOR clk_period;
    ASSERT RD2 = x"0ABCDEF0" REPORT "Case 3: FAIL" SEVERITY ERROR;

    -- Case 4: Read back register 4
    A1   <= "00100";
    WAIT FOR clk_period;
    WE3 <= '1';
    WAIT FOR clk_period;
    ASSERT RD1 = x"0ABCDEF0" REPORT "Case 4: FAIL" SEVERITY ERROR;

    -- Case 5: Write to register 1 and read back
    A3   <= "00001";
    WD3  <= x"DEADBEEF";
    WAIT FOR clk_period;
    A1   <= "00001";
    WAIT FOR clk_period;
    ASSERT RD1 = x"DEADBEEF" REPORT "Case 5: FAIL" SEVERITY ERROR;

    -- Case 6: Attempt write to register 0
    A3   <= "00000";
    WD3  <= x"FFFFFFFF";
    WAIT FOR clk_period;
    A1   <= "00000";
    WAIT FOR clk_period;
    ASSERT RD1 /= x"FFFFFFFF" REPORT "Case 6: FAIL" SEVERITY ERROR;

    -- Case 7: Read multiple registers while writing another
    A1   <= "00001";
    A2   <= "00100";
    A3   <= "01010";
    WD3  <= x"12345678";
    WAIT FOR clk_period;
    WAIT FOR clk_period;
    ASSERT RD1 = x"DEADBEEF" AND RD2 = x"0ABCDEF0" REPORT "Case 7: FAIL" SEVERITY ERROR;

    -- Case 8: Write to the same register twice
    A3   <= "00010";
    WD3  <= x"AAAA5555";
    WAIT FOR clk_period;
    WD3  <= x"5555AAAA";
    WAIT FOR clk_period;
    A1   <= "00010";
    WAIT FOR clk_period;
    ASSERT RD1 = x"5555AAAA" REPORT "Case 8: FAIL" SEVERITY ERROR;

    -- Case 9: Immediate read after write
    A3   <= "00011";
    WD3  <= x"CAFEBABE";
    WAIT FOR clk_period;
    A1   <= "00011";
    WAIT FOR clk_period;
    ASSERT RD1 = x"CAFEBABE" REPORT "Case 9: FAIL (No write-through or delay)" SEVERITY ERROR;

    -- Case 10: Read two different registers
    A1   <= "00001";
    A2   <= "00011";
    WAIT FOR clk_period;
    ASSERT RD1 = x"DEADBEEF" AND RD2 = x"CAFEBABE" REPORT "Case 10: FAIL" SEVERITY ERROR;

    -- Case 11: Disable write, attempt write, verify no change
    WE3  <= '0';
    A3   <= "00101";
    WD3  <= x"BEEFBEEF";
    WAIT FOR clk_period;
    A1   <= "00101";
    WAIT FOR clk_period;
    ASSERT RD1 /= x"BEEFBEEF" REPORT "Case 11: FAIL" SEVERITY ERROR;

    -- Case 12: Reset after writing
    WE3  <= '1';
    A3   <= "00110";
    WD3  <= x"11223344";
    WAIT FOR clk_period;
    CLR  <= '1';
    WAIT FOR clk_period;
    WE3 <= '0';
    CLR  <= '0';
    A1   <= "00110";
    WAIT FOR clk_period;
    ASSERT RD1 = x"00000000" REPORT "Case 12: FAIL" SEVERITY ERROR;

    REPORT "Testbench completed successfully." SEVERITY NOTE;
    WAIT;
END PROCESS;

end architecture;
