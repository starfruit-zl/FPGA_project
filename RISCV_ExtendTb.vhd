library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL; --changed the library to the numeric standard.

entity extend_unit_tb is
end extend_unit_tb;

architecture testbench of extend_unit_tb is
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
        
        -- Test cases (imm_in is only bits [31:7] of the instruction)
        imm_in <= '0'&x"000FFF"; extend_ctrl <= "000"; wait for 10 ns;
        imm_in <= '0'&x"7FFFFF"; extend_ctrl <= "000"; wait for 10 ns; -- Negative case (MSB = 1)
        imm_in <= '0'&x"000FFF"; extend_ctrl <= "001"; wait for 10 ns;
        imm_in <= '0'&x"000FFF"; extend_ctrl <= "010"; wait for 10 ns;
        imm_in <= '0'&x"000FFF"; extend_ctrl <= "011"; wait for 10 ns;
        imm_in <= '0'&x"000FFF"; extend_ctrl <= "100"; wait for 10 ns;
        
        report "Test completed.";
        wait;
    end process;
end testbench;
