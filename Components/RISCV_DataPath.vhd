library IEEE;
 use IEEE.STD_LOGIC_1164.all;
 use IEEE.NUMERIC_STD.all;

entity top is
port(
	--inputs
	signal clk   : in std_logic;
	signal reset : in std_logic;
	--outputs
	signal WriteData : out std_logic_vector(31 downto 0);
	signal DataAdr	 : out std_logic_vector(31 downto 0);
	signal MemWrite	 : out std_logic);

end entity;

architecture behave of top is
--internal signals:
signal B : std_logic_vector(31 downto 0);
signal A : std_logic_vector(31 downto 0);
signal result :  std_logic_vector (31 downto 0);
signal pcnext : std_logic_vector (31 downto 0);
signal address_input : std_logic_vector (31 downto 0);
signal data_output : std_logic_vector (31 downto 0);
signal alu_zero : std_logic;
signal PCSrc : std_logic;
signal ResultSrc : std_logic_vector (1 downto 0);
signal ALUSrc : std_logic;
signal extend_ctrl : std_logic_vector (2 downto 0);
signal RegWrite: std_logic;
signal ALU_ctrl : std_logic_vector (2 downto 0);
signal ALU_result : std_logic_vector (31 downto 0);
signal overflow : std_logic;
signal negative : std_logic; 
signal imm_out : std_logic_vector (31 downto 0);
signal rd2 : std_logic_vector (31 downto 0);
signal d_cache_result : std_logic_vector (31 downto 0);
signal MemWriteEnable : std_logic;

begin
	--!!port map: signal on left, local on right.
pc_riscv: entity work.pc(behave) port map (
	--inputs
	clk => clk, 
	reset => reset, 
	pc_in => pcnext, 
	--outputs
	pc_out => address_input); --Re-assign direct connections as needed.

i_cache_riscv: entity work.i_cache(behave) port map (
	address_input => address_input, 
	data_output => data_output);

controlunit_riscv: entity work.RISCV_ControlUnit(behave) port map (
	--inputs
	zero => alu_zero,
	op => data_output(6 downto 0), 
	funct3 => data_output(14 downto 12), 
	funct7 => data_output(31 downto 25),
	--outputs
	PCSrc => PCSrc, --need to implement switch.
	ResultSrc => ResultSrc, --need to implement switch.
	MemWrite => MemWriteEnable, 
	ALUSrc => ALUSrc, --need to implement switch.
	ImmSrc => extend_ctrl,
	RegWrite => RegWrite, 
	ALUControl => ALU_ctrl);
--inputs
--	signal zero   : in std_logic; --Wired to the zero signal of the ALU, Flag activates triggering output.
	--signal op     : in std_logic_vector(6 downto 0);
	--signal funct3 : in std_logic_vector(2 downto 0);
	--signal funct7 : in std_logic_vector(6 downto 0);
		--outputs
	--signal PCSrc     : out std_logic; -- whether PC is using PC+4 (0) or PC+offset (1).
	--signal ResultSrc : out std_logic_vector(1 downto 0); --0 means ALU as src, 1 means Mem, "10"(2) means PC+4 is written into the regfile for JAL and JALR instruction
	--signal MemWrite  : out std_logic; -- interfaces with register, write enable signal/
	--signal ALUSrc    : out std_logic; --immediate or register value
	--signal ImmSrc    : out std_logic_vector(2 downto 0); --specified as 2, but need 3.
	--signal RegWrite  : out std_logic; --write enable signal
	--signal ALUControl: out std_logic_vector(2 downto 0));
alu_riscv: entity work.RISCV_ALU(behave) port map(
	--inputs
	A => A, 
	B => B, 
	ALU_ctrl => ALU_ctrl, 
	--outputs
	result => alu_result,
	--flags
	overflow => overflow,
	negative => negative,
	zero => alu_zero);

extend_riscv: entity work.extend_unit(behave) port map(
	--inputs
	imm_in => data_output(31 downto 7),
	extend_ctrl => extend_ctrl,
	--outputs
	imm_out => imm_out);

register_riscv: entity work.regfile(behave) port map(
	--inputs
	clk => clk,
	clr => reset,
	we3 => RegWrite,
	wd3 => result,
	a1 => data_output(19 downto 15),--read register 1
	a2 => data_output(24 downto 20),--read register 2
	a3 => data_output(11 downto 7),--write register 1
	--outputs
	rd1 => A,--output reg1
	rd2 => rd2);--output reg2

d_cache_riscv: entity work.dmem(behave) port map(
	clk => clk,
	we => MemWriteEnable, --write enable
	a => alu_result,--access address
	wd => rd2,--write data
	--outputs
	rd => d_cache_result); --read data
	
	B <= rd2 when ALUSrc = '0' else
		 imm_out when ALUSrc = '1' else (others => '0');
	
	with ResultSrc select
	result <= alu_result when "00",
		  d_cache_result when "01",
		  std_logic_vector(to_unsigned(to_integer(unsigned(address_input))+4, 32)) when "10",
		  (others => '0') when others;
	
	with PCSrc select
	pcnext <= std_logic_vector(to_unsigned(to_integer(unsigned(address_input))+4,32)) when '0',
				std_logic_vector(unsigned(address_input) + unsigned(imm_out)) when '1',
				std_logic_vector(to_unsigned(to_integer(unsigned(address_input))+4,32)) when others;
	
		WriteData <= rd2;
		DataAdr <= alu_result;
		MemWrite <= MemWriteEnable;

end architecture;