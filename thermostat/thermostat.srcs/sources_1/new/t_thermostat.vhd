library IEEE;
use IEEE.std_logic_1164.all;

-- Entity definition (testbench)
entity T_THERMOSTAT is
    end T_THERMOSTAT;
    
    -- Architecture definition
    architecture TEST of T_THERMOSTAT is
    
    -- Component definition
    component THERMOSTAT is
        port(   --  Inputs
                CURRENT_TEMP: in std_logic_vector(6 downto 0);
                DESIRED_TEMP: in std_logic_vector(6 downto 0);
                DISPLAY_SEL: in std_logic;
                COOL: in std_logic;
                HEAT: in std_logic;
                CLK: in std_logic;
                RESET: in std_logic;
                FURNACE_HOT: in std_logic;
                AC_COLD: in std_logic;
                
                --  Outputs
                TEMP_DISPLAY: out std_logic_vector(6 downto 0);
                FURNACE_ON: out std_logic;
                A_C_ON: out std_logic;
                FAN_ON: out std_logic;
                STATE_I: out integer
            );
    end component;
    
    signal DISPLAY_SEL,COOL,HEAT,FURNACE_ON,A_C_ON,RESET : std_logic;
    signal CLK : std_logic := '0';
    
    --  Convert time from ps (simulation resolution) to ns
    --  **  To use time in ps: change integer'image(...) to time'image(...)
    --      and declare STATE_TIME as a 'time' type. assign NOW to it.
    --  **  To another unit measure, state 'integer' type for STATE_TIME and
    --      assign NOW / time_constant(value_conversion ps/Xs)
    signal STATE_TIME : integer;
    constant TIME_C : time := 1000 ps;
    
    signal FAN_ON,FURNACE_HOT,AC_COLD : std_logic;
    signal CURRENT_TEMP,DESIRED_TEMP,TEMP_DISPLAY : std_logic_vector(6 downto 0);
    signal STATE_I : integer range 0 to 3;
    begin
    
        UUT:THERMOSTAT
        port map(	CURRENT_TEMP => CURRENT_TEMP,
                    DESIRED_TEMP => DESIRED_TEMP,
                    DISPLAY_SEL => DISPLAY_SEL,
                    COOL => COOL,
                    HEAT => HEAT,
                    FURNACE_HOT => FURNACE_HOT,
                    AC_COLD => AC_COLD,
                    
                    FURNACE_ON => FURNACE_ON,
                    TEMP_DISPLAY => TEMP_DISPLAY,
                    A_C_ON => A_C_ON,
                    FAN_ON => FAN_ON,
                    
                    CLK => CLK,
                    RESET => RESET,
                    STATE_I => STATE_I
                );
    
    -- Initialize CLK and RESET
    CLK <= not CLK after 5 ns;
    RESET <= '1','0' after 20 ns;
    
    --  Event process: time recover
    process(STATE_I)
    begin
        STATE_TIME <= NOW / TIME_C;
    end process;
    
    -- Main process definition
    test: process
    begin
        -- Apply stimulus to inputs
        CURRENT_TEMP <= "0001010";  -- Example value for CURRENT_TEMP (10 in decimal)
        DESIRED_TEMP <= "0010101";  -- Example value for DESIRED_TEMP (21 in decimal)
        COOL <= '1';
        HEAT <= '1';
        
        -- Define simulation
        DISPLAY_SEL <= '0';
        wait for 50 ns;
        assert TEMP_DISPLAY = DESIRED_TEMP report "Error in temperature display." severity error;
        
        DISPLAY_SEL <= '1';
        HEAT <= '0';
        wait for 50 ns;
        assert TEMP_DISPLAY = CURRENT_TEMP report "Error in temperature display." severity error;
        
        DISPLAY_SEL <= '0';
        HEAT <= '1';
        wait for 50 ns;
        assert STATE_I /= 1 report "CUR_T < DES_T and HEAT = 1, STATE_I = from 0 to 1. Time: " & integer'image(STATE_TIME) & " ns" severity note;
        
        FURNACE_HOT <= '1';
        wait for 50 ns;
        assert STATE_I /= 2 report "FURNACE is HOT, STATE_I = from 1 to 2. Time: " & integer'image(STATE_TIME) & " ns" severity note;
        
        CURRENT_TEMP <= "0011000";  --  Temperature rises
        wait for 50 ns;
        assert STATE_I /= 3 report "CUR_T > DES_T, STATE_I = from 2 to 3. Time: " & integer'image(STATE_TIME) & " ns" severity note;
        
        FURNACE_HOT <= '0';
        COOL <= '0';
        wait for 250 ns;
        
        assert STATE_I /= 0 report "FURNACE is not HOT, STATE_I = from 3 to 0. Time: " & integer'image(STATE_TIME) & " ns" severity note;
        
        COOL <= '1';
    
        -- End of simulation
        wait;
    end process;
    
    end architecture;