library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i_cache is
    port (
        address_input : in std_logic_vector(31 downto 0);
        data_output : out std_logic_vector(31 downto 0)
    );
end i_cache;

architecture behave of i_cache is
begin
    process (address_input)
    begin
        case address_input is
            when x"00000000" => data_output <= x"00500113"; -- addi x2,x0,5
            when x"00000004" => data_output <= x"00C00193"; -- addi x3,x0,12
            when x"00000008" => data_output <= x"FF718393"; -- addi x7,x3,-9
            when x"0000000C" => data_output <= x"0023E233"; -- or x4,x7,x2
            when x"00000010" => data_output <= x"0041F2B3"; -- and x5,x3,x4
            when x"00000014" => data_output <= x"004282B3"; -- add x5,x5,x4
            when x"00000018" => data_output <= x"02728863"; -- beq x5,x7,end
            when x"0000001C" => data_output <= x"0041A233"; -- slt x4,x3,x4
            when x"00000020" => data_output <= x"00020463"; -- beq x4,x0,around
            when x"00000024" => data_output <= x"00000293"; -- addi x5,x0,0 (shouldn't execute)
            when x"00000028" => data_output <= x"0023A233"; -- around: slt x4,x7,x2
            when x"0000002C" => data_output <= x"005203B3"; -- add x7,x4,x5
            when x"00000030" => data_output <= x"402383B3"; -- sub x7,x7,x2
            when x"00000034" => data_output <= x"0471AA23"; -- sw x7,84(x3)
            when x"00000038" => data_output <= x"06002103"; -- lw x2,96(x0)
            when x"0000003C" => data_output <= x"005104B3"; -- add x9,x2,x5
            when x"00000040" => data_output <= x"008001EF"; -- jal x3,end
            when x"00000044" => data_output <= x"00100113"; -- addi x2,x0,1 (shouldn't execute)
            when x"00000048" => data_output <= x"00910133"; -- end: add x2,x2,x9
            when x"0000004C" => data_output <= x"0221A023"; -- sw x2,0x20(x3)
            when x"00000050" => data_output <= x"00210063"; -- done: beq x2,x2,done
            when others => data_output <= x"00000000"; -- don't care
        end case;
    end process;
end behave;

