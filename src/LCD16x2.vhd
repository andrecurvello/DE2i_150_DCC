----------------------------------------------------------------------------------
-- Copyright (c) 2014, Luis Ardila
-- E-mail: leardilap@unal.edu.co
--
-- Description:
--
-- Revisions: 
-- Date        	Version    	Author    		Description
-- 10/11/2014    	1.0    		Luis Ardila    File created
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

library altera; 
use altera.altera_primitives_components.all; 


ENTITY LCD16x2 IS 
GENERIC (
	CLK_PERIOD_NS : POSITIVE := 20);    -- 50MHz   --POSITIVE is INTEGER but from 1 to 2147483647
PORT (	
   CLK            : IN STD_LOGIC;
	RST            : IN STD_LOGIC;
	ADA_DATA_IN    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	ADA_DATA_EN    : IN STD_LOGIC;
	ADB_DATA_IN			 : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	ADB_DATA_EN    : IN STD_LOGIC;    
	--LCD INTERFACE
	LCD_DATA       : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	LCD_EN				     : OUT STD_LOGIC;
	LCD_ON				     : OUT STD_LOGIC;
	LCD_RS				     : OUT STD_LOGIC;
	LCD_RW				     : OUT STD_LOGIC
	);
END LCD16x2;

ARCHITECTURE LCD16x2_ARCH OF LCD16x2 IS
  
  COMPONENT HEX2LCD IS
  PORT(
		CLK				: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		ADA_DATA_IN    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ADA_DATA_EN    : IN STD_LOGIC;
		ADB_DATA_IN		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		ADB_DATA_EN    : IN STD_LOGIC;  
		ADA_H 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ADA_L 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ADB_H 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		ADB_L 			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END COMPONENT;
	
  TYPE State_Type IS (INIT, CONFIG, SETUP, ENABLE, HOLD, DELAY, IDLE);  
  SIGNAL sSTATE       : State_Type := IDLE;
  
  CONSTANT WT_INIT    : INTEGER := 20000000 / CLK_PERIOD_NS + 1;    -- 20 ms
  CONSTANT WT_HOME    : INTEGER := 2000000 / CLK_PERIOD_NS + 1;     -- 2 ms
  CONSTANT WT_DEFAULT : INTEGER := 50000 / CLK_PERIOD_NS +1;        -- 50 us
  CONSTANT WT_SETUP   : INTEGER := 140 / CLK_PERIOD_NS + 1;         -- 140 ns
  CONSTANT WT_ENABLE  : INTEGER := 300 / CLK_PERIOD_NS + 1;         -- 300 ns
  CONSTANT WT_HOLD    : INTEGER := 140 / CLK_PERIOD_NS + 1;         -- 140 ns
  
  SIGNAL sCnt         : INTEGER RANGE 0 TO WT_INIT := WT_INIT;
  SIGNAL sData_ptr    : INTEGER RANGE 0 TO 6 := 0;
  SIGNAL sConfig_ptr  : INTEGER RANGE 0 TO 15 := 0;
  SIGNAL sLCD_Cnt     : INTEGER RANGE 0 TO WT_INIT := 0;
  
  TYPE Op_type IS RECORD
    RS      : STD_LOGIC;
    DATA    : STD_LOGIC_VECTOR (7 DOWNTO 0);
    DELAY   : INTEGER RANGE 0 TO WT_INIT;
  END RECORD Op_type;
  
  TYPE Config_op_type IS ARRAY(0 TO 14) OF Op_type;
  CONSTANT sConfig_op : Config_op_type
    := (0 => (RS => '0', DATA => X"30", DELAY => WT_INIT), -- 8 bits
        1 => (RS => '0', DATA => X"30", DELAY => WT_INIT), -- 8 bits
        2 => (RS => '0', DATA => X"38", DELAY => WT_INIT), -- 8 bits, 2 lines, 8*5 
        3 => (RS => '0', DATA => X"38", DELAY => WT_DEFAULT), -- 8 bits, 2 lines, 8x5
        4 => (RS => '0', DATA => X"0E", DELAY => WT_DEFAULT), -- display on
        5 => (RS => '0', DATA => X"01", DELAY => WT_HOME),  -- display clear
        6 => (RS => '1', DATA => X"41", DELAY => WT_DEFAULT), -- A
        7 => (RS => '1', DATA => X"44", DELAY => WT_DEFAULT), -- D
        8 => (RS => '1', DATA => X"41", DELAY => WT_DEFAULT), -- A
        9 => (RS => '1', DATA => X"3A", DELAY => WT_DEFAULT), -- :
        10 => (RS => '0', DATA => X"C0", DELAY => WT_DEFAULT), -- go to ADD 40
        11 => (RS => '1', DATA => X"41", DELAY => WT_DEFAULT), -- A
        12 => (RS => '1', DATA => X"44", DELAY => WT_DEFAULT), -- D
        13 => (RS => '1', DATA => X"42", DELAY => WT_DEFAULT), -- B
        14 => (RS => '1', DATA => X"3A", DELAY => WT_DEFAULT) -- :  
    );
    
  TYPE Data_op_type IS ARRAY(0 TO 5) OF Op_type;
  SIGNAL sData_op : Data_op_type
    := (0 => (RS => '0', DATA => X"84", DELAY => WT_DEFAULT), -- Address 4
        1 => (RS => '1', DATA => X"30", DELAY => WT_DEFAULT), -- ADA HIGH
        2 => (RS => '1', DATA => X"38", DELAY => WT_DEFAULT), -- ADA LOW
        3 => (RS => '0', DATA => X"C4", DELAY => WT_DEFAULT), -- Address 44
        4 => (RS => '1', DATA => X"30", DELAY => WT_DEFAULT), -- ADB HIGH
        5 => (RS => '1', DATA => X"38", DELAY => WT_DEFAULT) -- ADB LOW
    );
  SIGNAL sLCD_DATA_OE : STD_LOGIC := '0';
  
  SIGNAL sLCD_DATA_I : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sLCD_DATA_O : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  
  SIGNAL sADA_H : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sADA_L : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sADB_H : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  SIGNAL sADB_L : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
  
  SIGNAL sCONFIG_FLAG : STD_LOGIC := '0';
  
BEGIN 
  
	LCD_DATA_GEN : FOR i IN 0 TO 7 GENERATE
		iobuff : alt_iobuf 
      PORT MAP( 
			i => sLCD_DATA_I(i), 
			oe => sLCD_DATA_OE, 
			io => LCD_DATA(i), 
			o => sLCD_DATA_O(i) 
			);  
	END GENERATE;   
  
	HEX2LCD_INST : HEX2LCD
	PORT MAP(
		CLK				=> CLK,
		RST				=> RST,
		ADA_DATA_IN    => ADA_DATA_IN,
		ADA_DATA_EN    => ADA_DATA_EN,
		ADB_DATA_IN		=> ADB_DATA_IN,	
		ADB_DATA_EN    => ADB_DATA_EN,  
		ADA_H 			=> sADA_H, 
		ADA_L 			=> sADA_L, 
		ADB_H 			=> sADB_H, 
		ADB_L 			=> sADB_L
		);
    
  
  STATE_MACHINE : PROCESS (CLK, RST) IS
  BEGIN 
  
    IF RST = '1' THEN                 		-- asynchronous global ST_RESET (active high) 
      LCD_EN <= '0';
      sLCD_DATA_I <= (OTHERS => '0');
      LCD_RS <= '0';
      sCONFIG_FLAG <= '0';
      sSTATE <= INIT;
      
          
    ELSIF RISING_EDGE(CLK) THEN  					-- rising clock edge 
      
      CASE sSTATE IS 
        
        WHEN INIT =>
          LCD_EN <= '0';
          IF (sCnt = 0) THEN 
            sSTATE <= CONFIG;
            sConfig_ptr <= 0;
          ELSE
            sCnt	<= sCnt - 1;     --waiting for initial delay of 20 ms
          END IF;
        
        WHEN CONFIG =>
          LCD_EN <= '0';
          IF sConfig_ptr < 15 then
            sConfig_ptr <= sConfig_ptr + 1;
            sLCD_DATA_I    <= sConfig_op(sConfig_ptr).DATA;
            LCD_RS      <= sConfig_op(sConfig_ptr).RS;
            sLCD_Cnt    <= sConfig_op(sConfig_ptr).DELAY;
            sSTATE      <= SETUP;
            sCnt        <= WT_SETUP;
          ELSE
            sCONFIG_FLAG <= '1';
            sData_ptr <= 0;
				    sSTATE <= IDLE;
          END IF;     
        
        WHEN SETUP =>
          LCD_EN <= '0';
          IF (sCnt = 0) THEN 
            sSTATE <= ENABLE;
            sCnt <= WT_ENABLE;
          ELSE
            sCnt	<= sCnt - 1;     --waiting for setup time of 140 ns
          END IF;
          
        WHEN ENABLE =>
          LCD_EN <= '1';
          IF (sCnt = 0) THEN 
            sSTATE <= HOLD;
            sCnt <= WT_HOLD;
          ELSE
            sCnt	<= sCnt - 1;     --waiting for enable time of 300 ns
          END IF;
        
        WHEN HOLD =>
          LCD_EN <= '0';
          IF (sCnt = 0) THEN 
            sSTATE <= DELAY;
            IF sCONFIG_FLAG = '0' THEN 
              sCnt <= sLCD_Cnt;
            ELSE 
              sCnt <= WT_DEFAULT; 
            END IF;
          ELSE
            sCnt	<= sCnt - 1;     --waiting for hold time of 140 ns           
          END IF;
          
        WHEN DELAY => 
          IF (sCnt = 0) THEN 
            sSTATE <= IDLE;
          ELSE
            sCnt	<= sCnt - 1;     --waiting for variable delay time
          END IF;
    
        WHEN IDLE =>
          IF sCONFIG_FLAG = '0' THEN 
            sSTATE <= CONFIG;
          ELSE 
            sData_op(1).DATA <= sADA_H;
            sData_op(2).DATA <= sADA_L;
            sData_op(4).DATA <= sADB_H;
            sData_op(5).DATA <= sADB_L;
				IF sData_ptr = 5 THEN
					sData_ptr <= 0;
				ELSE
					sData_ptr   <= sData_ptr + 1;
				END IF;
				sLCD_DATA_I <= sData_op(sData_ptr).DATA;
				LCD_RS      <= sData_op(sData_ptr).RS;
				sLCD_Cnt    <= sData_op(sData_ptr).DELAY;
				sSTATE      <= SETUP;
				sCnt        <= WT_SETUP;
          END IF;
          
        WHEN OTHERS =>
          sSTATE <= INIT;
          
      END CASE;
    END IF;
    
  END PROCESS STATE_MACHINE;
  LCD_RW <= '0';              --write always
   
  sLCD_DATA_OE <= '1';			--output always
  
  LCD_ON <= '1';
  
END LCD16x2_ARCH;