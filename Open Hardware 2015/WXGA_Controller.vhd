----------------------------------------------------------------------------------
-- COMPANY: TECHNICAL UNIVERSITY OF CRETE
-- ENGINEER: NICK KYPARISSAS
-- 
-- CREATE DATE: 03/09/2015
-- MODULE NAME: WXGA_CONTROLLER - BEHAVIORAL
-- DESIGN: based on Ulrich Zoltan's VGA Controller, Copyright 2006 Digilent, Inc.
-- REVISION 0.01 - FILE CREATED
-- DESCRIPTION: This module generates the video synch pulses for the monitor to
-- enter 1280x800@60Hz resolution state. It also provides horizontal
-- and vertical counters for the currently displayed pixel and a blank
-- signal that is active when the pixel is not inside the visible screen
-- and the color outputs should be reset to 0. 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- SIMULATION LIBRARY
LIBRARY UNISIM;
USE UNISIM.VCOMPONENTS.ALL;

ENTITY WXGA_CONTROLLER IS
    PORT(
        RST         : IN STD_LOGIC;
        CLK         : IN STD_LOGIC; -- MUST BE @ 83.46 MHz
        HS          : OUT STD_LOGIC;
        VS          : OUT STD_LOGIC;
        HCOUNT      : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        VCOUNT      : OUT STD_LOGIC_VECTOR(10 DOWNTO 0)
    );
END WXGA_CONTROLLER;

ARCHITECTURE BEHAVIORAL OF WXGA_CONTROLLER IS

------------------------------------------------------------------------
-- CONSTANTS
------------------------------------------------------------------------
    
    -- MAXIMUM VALUE FOR THE HORIZONTAL PIXEL COUNTER
    CONSTANT HMAX  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "11010010000"; -- 1680 TOTAL PIXELS PER LINE
    -- MAXIMUM VALUE FOR THE VERTICAL PIXEL COUNTER
    CONSTANT VMAX  : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01100111100"; -- 828 TOTAL LINES
    -- TOTAL NUMBER OF VISIBLE COLUMNS
    CONSTANT HLINES: STD_LOGIC_VECTOR(10 DOWNTO 0) := "10100000000"; -- 1280 RESOLUTION WIDTH
    -- VALUE FOR THE HORIZONTAL COUNTER WHERE FRONT PORCH ENDS
    CONSTANT HFP   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "10101000000"; -- 1344 = FRONT PORCH 64 PIXELS + 1280 
    -- VALUE FOR THE HORIZONTAL COUNTER WHERE THE SYNCH PULSE ENDS
    CONSTANT HSP   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "10111001000"; -- 1480 = HORIZONTAL SYNC 136 PIXELS + 1344
    -- TOTAL NUMBER OF VISIBLE LINES
    CONSTANT VLINES: STD_LOGIC_VECTOR(10 DOWNTO 0) := "01100100000"; -- 800 RESOLUTION HEIGHT
    -- VALUE FOR THE VERTICAL COUNTER WHERE THE FRONT PORCH ENDS
    CONSTANT VFP   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01100100001"; -- 801 = FRONT PORCH 1 LINES + 800
    -- VALUE FOR THE VERTICAL COUNTER WHERE THE SYNCH PULSE ENDS
    CONSTANT VSP   : STD_LOGIC_VECTOR(10 DOWNTO 0) := "01100111000"; -- 824 = VERTICAL SYNC 3 LINES + 821
    -- POLARITY OF THE HORIZONTAL AND VERTICAL SYNCH PULSE
    CONSTANT HSP_P   : STD_LOGIC := '0';
    CONSTANT VSP_P   : STD_LOGIC := '1';
------------------------------------------------------------------------
-- SIGNALS
------------------------------------------------------------------------
    
    -- HORIZONTAL AND VERTICAL COUNTERS
    SIGNAL HCOUNTER : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');
    SIGNAL VCOUNTER : STD_LOGIC_VECTOR(10 DOWNTO 0) := (OTHERS => '0');

------------------------------------------------------------------------

BEGIN

    -- OUTPUT HORIZONTAL AND VERTICAL COUNTERS.
    HCOUNT <= HCOUNTER;
    VCOUNT <= VCOUNTER;

    -- INCREMENT HORIZONTAL COUNTER AT CLK RATE
    -- UNTIL HMAX IS REACHED, THEN RESET AND KEEP COUNTING.
    H_COUNT: PROCESS
    BEGIN
        WAIT UNTIL CLK'EVENT AND CLK = '1' ;
            IF(RST = '1') THEN
                HCOUNTER <= (OTHERS => '0');
            ELSIF(HCOUNTER = HMAX) THEN
                HCOUNTER <= (OTHERS => '0');
            ELSE
                HCOUNTER <= HCOUNTER + 1;
            END IF;
    END PROCESS H_COUNT;

    -- INCREMENT VERTICAL COUNTER WHEN ONE LINE IS FINISHED
    -- (HORIZONTAL COUNTER REACHED HMAX)
    -- UNTIL VMAX IS REACHED, THEN RESET AND KEEP COUNTING.
    V_COUNT: PROCESS
    BEGIN
		WAIT UNTIL CLK'EVENT AND CLK= '1';
            IF(RST = '1') THEN
                VCOUNTER <= (OTHERS => '0');
            ELSIF(HCOUNTER = HMAX) THEN
                IF(VCOUNTER = VMAX) THEN
                    VCOUNTER <= (OTHERS => '0');
                ELSE
                    VCOUNTER <= VCOUNTER + 1;
                END IF;
            END IF;
    END PROCESS V_COUNT;

    -- GENERATE HORIZONTAL SYNCH PULSE
    -- WHEN HORIZONTAL COUNTER IS BETWEEN WHERE THE
    -- FRONT PORCH ENDS AND THE SYNCH PULSE ENDS.
    -- THE HS IS ACTIVE (WITH POLARITY HSP_P) FOR A TOTAL OF 136 PIXELS.
    DO_HS: PROCESS
    BEGIN
        WAIT UNTIL CLK'EVENT AND CLK='1';
            IF(HCOUNTER >= HFP AND HCOUNTER < HSP) THEN
                HS <= HSP_P;
            ELSE
                HS <= NOT HSP_P;
            END IF; 
    END PROCESS DO_HS;

    -- GENERATE VERTICAL SYNCH PULSE
    -- WHEN VERTICAL COUNTER IS BETWEEN WHERE THE
    -- FRONT PORCH ENDS AND THE SYNCH PULSE ENDS.
    -- THE VS IS ACTIVE (WITH POLARITY VSP_P) FOR A TOTAL OF 3 LINES.
    DO_VS: PROCESS
    BEGIN
        WAIT UNTIL CLK'EVENT AND CLK='1';
            IF(VCOUNTER >= VFP AND VCOUNTER < VSP) THEN
                VS <= VSP_P;
            ELSE
                VS <= NOT VSP_P;
            END IF;
    END PROCESS DO_VS;
   
END BEHAVIORAL;