----------------------------------------------------------------------------------
-- COMPANY: TECHNICAL UNIVERSITY OF CRETE
-- ENGINEER: NICK KYPARISSAS
-- 
-- CREATE DATE: 9 April 2015 
-- DESIGN NAME: 
-- MODULE NAME: CGA_2_WXGA - BEHAVIORAL
-- TARGET DEVICES: Tested on Nexys4
--
-- DESCRIPTION: This module loads a CGA image (320x200, 8-bit colors) from memory
-- and scales it up to WXGA (1280x800). Every image pixel equals to a 4x4 pixels 
-- area on the WXGA screen.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY CGA_2_WXGA IS
    PORT ( 
        RST         : IN STD_LOGIC;
        CLK         : IN STD_LOGIC;
        HCOUNT      : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        VCOUNT      : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        MEM_DATA    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        MEM_ADDRESS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        RED         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        GREEN       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        BLUE        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END CGA_2_WXGA;

ARCHITECTURE BEHAVIORAL OF CGA_2_WXGA IS

SIGNAL COUNTER4 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- 4 pixels of a screen row equal to 1 pixel of the 320x200 image
SIGNAL COUNTER320 : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0'); -- in which pixel of the image row we are
SIGNAL COUNTER4LINES : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- each pixel of the 320x200 image equals to a 4x4 pixel WXGA screen
SIGNAL COUNTERIMAGELINE : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0'); -- in which pixel row of the image we currently are

BEGIN
    
    PROCESS 
        BEGIN
            WAIT UNTIL CLK'EVENT AND CLK= '1';
                IF (RST = '1') THEN
                    COUNTER4 <= (OTHERS => '0');
                    COUNTER320 <= (OTHERS => '0');
                    COUNTER4LINES <= (OTHERS => '0');
                    COUNTERIMAGELINE <= (OTHERS => '0');
                    RED <= "0000";
                    GREEN <= "0000";
                    BLUE <= "0000";
                ELSE
                    IF (HCOUNT < 1280 AND VCOUNT < 800) THEN -- if within the display range, change the counters and display the image colors from the memory 
                        COUNTER4 <= COUNTER4 + 1;                            
                        IF (COUNTER4 = 3) THEN
                            COUNTER4 <= (OTHERS => '0');
                            IF (COUNTER320 = 319) THEN
                                COUNTER320 <= (OTHERS => '0');
                                IF (COUNTER4LINES = 3) THEN -- the same image line must be displayed 4 times
                                    COUNTER4LINES <= (OTHERS => '0');
                                    COUNTERIMAGELINE <= COUNTERIMAGELINE + 320; -- change image line
                                ELSE
                                    COUNTER4LINES <= COUNTER4LINES + 1; 
                                END IF;   
                            ELSE
                                COUNTER320 <= COUNTER320 + 1; -- every image line equals to 320 memory locations
                            END IF;
                        END IF;
                        RED <= MEM_DATA(7 DOWNTO 5)&'0';
                        GREEN <= MEM_DATA(4 DOWNTO 2)&'0';
                        BLUE <= MEM_DATA(1 DOWNTO 0)&'0'&'0';
                    ELSIF (HCOUNT = 1680 AND VCOUNT = 828) THEN -- about to change frame, resetting the counters  
                        COUNTER4 <= (OTHERS => '0');
                        COUNTER320 <= (OTHERS => '0');
                        COUNTER4LINES <= (OTHERS => '0');
                        COUNTERIMAGELINE <= (OTHERS => '0');
                        RED <= "0000";
                        GREEN <= "0000";
                        BLUE <= "0000";
                    ELSE -- not within the display range
                        COUNTER4 <= (OTHERS => '0');
                        COUNTER320 <= (OTHERS => '0');
                        RED <= "0000";
                        GREEN <= "0000";
                        BLUE <= "0000";
                    END IF;    
                END IF;
    END PROCESS;
    
    MEM_ADDRESS <= COUNTERIMAGELINE + COUNTER320;

END BEHAVIORAL;