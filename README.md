# Thermostat_project (Vivado)
VHDL project - Development of tests with aim to design a state machine for a simplified THERMOSTAT, including heating and cooling processes

![Captura de pantalla 2024-11-15 211000](https://github.com/user-attachments/assets/f0f3f1fe-7bea-4f31-a80a-b0fdde7aca16)

-------------------------------------------------------------------------------------------------------------------------------------------

##  State Machine development

There are SEVEN states in total for the thermostat simulation, but FOUR for each of the processes (heating and cooling). The TYPE defined for the different states listed is the following:

`type STATE_T is (IDLE,AC_ON,FUR_ON,AC_FAN,FUR_FAN,FUR_RST,AC_RST);`

The FOUR states for the heating process are the ones listed:

```
IDLE          --  State 0 : thermostat is deactivated
FUR_ON        --  State 1 : FURNACE is ON (warming up temperature)
FUR_FAN       --  State 2 : FURNACE and FAN are ON (FURNACE is HOT)
FUR_RST       --  State 3 : FURNACE is OFF - FAN is ON
```

Employing the same perspective, the FOUR other states for the cooling process are these:

```
IDLE          --  State 0 : thermostat is deactivated
AC_ON         --  State 1 : AC is ON (cooling down temperature)
AC_FAN        --  State 2 : AC and FAN are ON (AC is COLD)
AC_RST        --  State 3 : AC is OFF - FAN is ON
```
The temperature is adjusted using the air conditioning unit and the furnace. A fan then distributes the heat or cold throughout the environment, altering its state.
