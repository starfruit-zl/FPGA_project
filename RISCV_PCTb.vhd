library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity pc_tb is
end pc_tb;

architecture testbench of pc_tb is
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal pc_in : std_logic_vector(31 downto 0);
    signal pc_out : std_logic_vector(31 downto 0);
    
    -- Instantiate the PC module
    component pc
        port (
            clk : in std_logic;
            reset : in std_logic;
            pc_in : in std_logic_vector(31 downto 0);
            pc_out : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    dut: pc port map (
        clk => clk,
        reset => reset,
        pc_in => pc_in,
        pc_out => pc_out
    );
    
    -- Clock process
    process
    begin
        while true loop
            clk <= '0'; wait for 5 ns;
            clk <= '1'; wait for 5 ns;
        end loop;
    end process;
    
    -- Test process
    process
    begin
        reset <= '1'; wait for 10 ns;
        reset <= '0'; wait for 10 ns;
        
        pc_in <= x"00000004"; wait for 10 ns;
        pc_in <= x"00000008"; wait for 10 ns;
        pc_in <= x"0000000C"; wait for 10 ns;
        
        assert false report "Simulation finished" severity note;
        wait;
    end process;

end testbench;

