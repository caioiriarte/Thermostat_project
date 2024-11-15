library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

--  Package header (declaration)
package counter_package is
    constant fur_end : std_logic_vector(10 downto 0) := "00111111111";
    constant ac_end : std_logic_vector(10 downto 0) := "11100000000";
    
    --  Johnson Counter function
    function johnson_cnt(in_vec: std_logic_vector(10 downto 0)) return std_logic_vector;
end package;

--  Package body definition - Johnson Counter
package body counter_package is
    --  Johnson Counter function (11 bits)
    function johnson_cnt(in_vec: std_logic_vector(10 downto 0)) return std_logic_vector is
    variable ret_vec : std_logic_vector(10 downto 0);
    begin    
        ret_vec := in_vec(9 downto 0) & not(in_vec(10));
        return ret_vec;
    end function;
    
end package body;