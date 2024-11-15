library IEEE;
library count_lib;
use IEEE.std_logic_1164.all;
use count_lib.counter_package.all;


entity THERMOSTAT is
    port(   --  Inputs
            CURRENT_TEMP    : in std_logic_vector(6 downto 0);
            DESIRED_TEMP    : in std_logic_vector(6 downto 0);
            DISPLAY_SEL     : in std_logic;
            COOL: in std_logic;
            HEAT: in std_logic;
            CLK: in std_logic;
            RESET: in std_logic;
            FURNACE_HOT: in std_logic;
            AC_COLD: in std_logic;
            
            --  Outputs
            TEMP_DISPLAY    : out std_logic_vector(6 downto 0);
            FURNACE_ON: out std_logic;
            A_C_ON: out std_logic;
            FAN_ON: out std_logic;
            STATE_I: out integer
        );
end THERMOSTAT;


architecture BEHAVE of THERMOSTAT is
    type STATE_T is (IDLE,AC_ON,FUR_ON,AC_FAN,FUR_FAN,FUR_RST,AC_RST);
    
    signal DISPLAY_S : std_logic_vector(6 downto 0);
    signal AC_S,FURNACE_S,FAN_S : std_logic;
    signal STATE : STATE_T;
    signal COUNTER : std_logic_vector(10 downto 0);
    
    begin
    
    --  First process: syncronous process
    syncro: process(CLK,RESET)
    
    --  Next state variable used
    variable NEXT_STATE : STATE_T;
    variable COUNTER_T : std_logic_vector(10 downto 0);
    
    begin
        if RESET = '1' then
            DISPLAY_S <= DESIRED_TEMP;
            NEXT_STATE := IDLE;
        elsif CLK'event and CLK = '1' then
            --  First logical statement
            if DISPLAY_SEL = '1' then
                DISPLAY_S <= CURRENT_TEMP;
            else
                DISPLAY_S <= DESIRED_TEMP;
            end if;
            
            --  Second logical statement
            if CURRENT_TEMP > DESIRED_TEMP and COOL = '1' and STATE = IDLE then
                NEXT_STATE := AC_ON;
            elsif CURRENT_TEMP < DESIRED_TEMP and HEAT = '1' and STATE = IDLE then
                NEXT_STATE := FUR_ON;
            elsif FURNACE_HOT = '1' and STATE = FUR_ON then
                NEXT_STATE := FUR_FAN;
            elsif AC_COLD = '1' and STATE = AC_ON then
                NEXT_STATE := AC_FAN;
            elsif STATE = AC_ON or STATE =FUR_ON then
                NEXT_STATE := STATE;
            else
                if STATE = FUR_FAN then
                    if not(CURRENT_TEMP < DESIRED_TEMP and HEAT = '1') then
                        NEXT_STATE := FUR_RST;
                        COUNTER_T := "00000000000";
                    else
                        NEXT_STATE := STATE;
                    end if;
                elsif STATE = AC_FAN then
                    if not(CURRENT_TEMP > DESIRED_TEMP and COOL = '1') then
                        NEXT_STATE := AC_RST;
                        COUNTER_T := "00000000000";
                    else
                        NEXT_STATE := STATE;
                    end if;
                elsif STATE = AC_RST then
                    if AC_COLD = '0' and COUNTER = ac_end then
                        NEXT_STATE := IDLE;
                    else
                        NEXT_STATE := STATE;
                        COUNTER_T := johnson_cnt(COUNTER);
                    end if;
                elsif STATE = FUR_RST then
                    if FURNACE_HOT = '0' and COUNTER = fur_end then
                        NEXT_STATE := IDLE;
                    else
                        NEXT_STATE := STATE;
                        COUNTER_T := johnson_cnt(COUNTER);
                    end if;
                else
                    NEXT_STATE := IDLE;
                end if;
            end if;
        end if;
        
        --  Store state and counter value
        STATE <= NEXT_STATE;
        COUNTER <= COUNTER_T;
    end process;
    
    --  Second process: State Machine
    state_machine: process(STATE)
    begin
        case STATE is
            when AC_ON =>
                AC_S <= '1';
                FURNACE_S <= '0';
                FAN_S <= '0';
                STATE_I <= 1;
            when FUR_ON =>
                AC_S <= '0';
                FURNACE_S <= '1';
                FAN_S <= '0';
                STATE_I <= 1;
            when AC_FAN =>
                AC_S <= '1';
                FURNACE_S <= '0';
                FAN_S <= '1';
                STATE_I <= 2;
            when FUR_FAN =>
                AC_S <= '0';
                FURNACE_S <= '1';
                FAN_S <= '1';
                STATE_I <= 2;
            when FUR_RST =>
                AC_S <= '0';
                FURNACE_S <= '0';
                FAN_S <= '1';
                STATE_I <= 3;
            when AC_RST =>
                AC_S <= '0';
                FURNACE_S <= '0';
                FAN_S <= '1';
                STATE_I <= 3;
            when others =>  -------------  Idle state
                FAN_S <= '0';
                AC_S <= '0';
                FURNACE_S <= '0';
                STATE_I <= 0;
        end case;
    end process;
    
    --  Update variables
    TEMP_DISPLAY <= DISPLAY_S;
    A_C_ON <= AC_S;
    FURNACE_ON <= FURNACE_S;
    FAN_ON <= FAN_S;
end BEHAVE;
