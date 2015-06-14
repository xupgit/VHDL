----------------------------------------------------------------------------------
-- COMPANY: TECHNICAL UNIVERSITY OF CRETE
-- ENGINEER: NICK KYPARISSAS
-- 
-- CREATE DATE: 1 May 2015 
-- DESIGN NAME: 
-- MODULE NAME: VGA_2_WXGA - BEHAVIORAL
-- TARGET DEVICES: Tested on Nexys4
--
-- DESCRIPTION: This module loads a VGA image (640x400 mode, 8-bit colors) from memory
-- and scales it up to WXGA (1280x800 12-bit colors). Every image pixel equals to a 2x2 pixels 
-- area on the WXGA screen.
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- UNCOMMENT THE FOLLOWING LIBRARY DECLARATION IF USING
-- ARITHMETIC FUNCTIONS WITH SIGNED OR UNSIGNED VALUES
--USE IEEE.NUMERIC_STD.ALL;

-- UNCOMMENT THE FOLLOWING LIBRARY DECLARATION IF INSTANTIATING
-- ANY XILINX LEAF CELLS IN THIS CODE.
--LIBRARY UNISIM;
--USE UNISIM.VCOMPONENTS.ALL;

ENTITY VGA_2_WXGA IS
    PORT ( 
        RST         : IN STD_LOGIC;
        CLK         : IN STD_LOGIC;
        HCOUNT      : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        VCOUNT      : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        MEM_DATA    : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        MEM_ADDRESS : OUT STD_LOGIC_VECTOR(17 DOWNTO 0);
        RED         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        GREEN       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        BLUE        : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END VGA_2_WXGA;

ARCHITECTURE BEHAVIORAL OF VGA_2_WXGA IS

SIGNAL COUNTER2 : STD_LOGIC;--_VECTOR(0 DOWNTO 0) := (OTHERS => '0'); -- pixels of a screen row equal to 1 pixel of the 320x200 image
SIGNAL COUNTER640 : STD_LOGIC_VECTOR(9 DOWNTO 0) := (OTHERS => '0'); -- in which pixel of the image row we are
SIGNAL COUNTER2LINES : STD_LOGIC;--_VECTOR(1 DOWNTO 0) := (OTHERS => '0'); -- each pixel of the 320x200 image equals to a 4x4 pixel WXGA screen
SIGNAL COUNTERIMAGELINE : STD_LOGIC_VECTOR(17 DOWNTO 0) := (OTHERS => '0'); -- in which pixel row of the image we are

BEGIN
    
    PROCESS 
        BEGIN
            WAIT UNTIL CLK'EVENT AND CLK= '1';
                IF (RST = '1') THEN
                    COUNTER2 <= '0';
                    COUNTER640 <= (OTHERS => '0');
                    COUNTER2LINES <= '0';
                    COUNTERIMAGELINE <= (OTHERS => '0');
                    RED <= "0000";
                    GREEN <= "0000";
                    BLUE <= "0000";
                ELSE
                    IF (HCOUNT < 1280 AND VCOUNT < 800) THEN --  
                        COUNTER2 <= NOT COUNTER2;                            
                        IF (COUNTER2 = '1') THEN
                            IF (COUNTER640 = 639) THEN
                                COUNTER640 <= (OTHERS => '0');
                                COUNTER2LINES <= NOT COUNTER2LINES;
                                IF (COUNTER2LINES = '1') THEN
                                    COUNTERIMAGELINE <= COUNTERIMAGELINE + 640; --change image line
                                END IF;   
                            ELSE
                                COUNTER640 <= COUNTER640 + 1;
                            END IF;
                        END IF;
                        RED <= MEM_DATA(7 DOWNTO 5)&'0';
                        GREEN <= MEM_DATA(4 DOWNTO 2)&'0';
                        BLUE <= MEM_DATA(1 DOWNTO 0)&'0'&'0';
                    ELSIF (HCOUNT = 1680 AND VCOUNT = 828) THEN   
                        COUNTER2 <= '0';
                        COUNTER640 <= (OTHERS => '0');
                        COUNTER2LINES <= '0';
                        COUNTERIMAGELINE <= (OTHERS => '0');
                        RED <= "0000";
                        GREEN <= "0000";
                        BLUE <= "0000";
                    ELSE
                        COUNTER2 <= '0';
                        COUNTER640 <= (OTHERS => '0');
                        RED <= "0000";
                        GREEN <= "0000";
                        BLUE <= "0000";
                    END IF;    
                END IF;
    END PROCESS;
    
    MEM_ADDRESS <= COUNTERIMAGELINE + COUNTER640;

END BEHAVIORAL;