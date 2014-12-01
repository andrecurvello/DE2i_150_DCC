----------------------------------------------------------------------------------
-- Copyright (c) 2014, Luis Ardila
-- E-mail: leardilap@unal.edu.co
--
-- Description:
-- SPI Controller for the "DCC" AD/DA Data Conversion Card from TERASIC
--
-- Revisions: 
-- Date        	Version    	Author    		Description
-- 07/11/2014    	1.0    		Luis Ardila    File created
--	30/11/2014		1.0			Luis Ardila		Support for ADA and ADB, CODEC not supported,
----------------------------------------------------------------------------------

LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 

library altera;
use altera.altera_primitives_components.all;

ENTITY AD_SPI_CONTROLLER IS
GENERIC (
	CLK_PERIOD_NS : POSITIVE := 20);    -- 50MHz   --POSITIVE is INTEGER but from 1 to 2147483647
PORT(
	CLK					: IN STD_LOGIC;							
	RST					: IN STD_LOGIC;
	-- SPI CONTROL
	SPI_ADDRESS			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_IN			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_RW			: IN STD_LOGIC;								--1 READ - 0 WRITE
	SPI_ADA_IN_WE		: IN STD_LOGIC;
	SPI_ADB_IN_WE		: IN STD_LOGIC;
	SPI_AIC_IN_WE		: IN STD_LOGIC;
	SPI_DATA_OUT		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_ADA_OUT_WE		: OUT STD_LOGIC;
	SPI_ADB_OUT_WE		: OUT STD_LOGIC;
	SPI_AIC_OUT_WE		: OUT STD_LOGIC;
	SPI_BUSY				: OUT STD_LOGIC;
	-- HSMC_DCC SPI INTERFACE
	AD_SCLK				: OUT STD_LOGIC;
	AD_SDIO				: INOUT STD_LOGIC;
	ADA_SPI_CS			: OUT STD_LOGIC;					-- Chip Select = 0  (low active)
	ADB_SPI_CS			: OUT STD_LOGIC;					-- Chip Select = 0  (low active)
	AIC_SPI_CS			: OUT STD_LOGIC					-- Chip Select = 0  (low active)
	);
END AD_SPI_CONTROLLER;

ARCHITECTURE AD_SPI_CONTROLLER_ARCH OF AD_SPI_CONTROLLER IS 
	
	-- STATE MACHINE TYPE  
	TYPE State_Type IS (IDLE, DATA_INTERPRET, ADDRESS_SHIFT_L, ADDRESS_SHIFT_H, DATA_READ_L,
                      DATA_READ_H, DATA_READ_WE, DATA_WRITE_L, DATA_WRITE_H, DATA_WRITE_WT, ABORT_L, ABORT_H); 
	SIGNAL sSPI_State  : State_Type; 
	
	-- Counter for STATE MACHINE
	SIGNAL sCnt					: INTEGER RANGE 0 TO 32;
	
	-- Counter for waiting time
	CONSTANT WT_DEFAULT    	: INTEGER := 100 / CLK_PERIOD_NS + 1;    -- 100 ns
	SIGNAL sCnt_WT 			: INTEGER RANGE 0 TO WT_DEFAULT := WT_DEFAULT;
	
	SIGNAL sSPI_ADDRESS		: STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_IN		: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_RW		: STD_LOGIC := '0';

	SIGNAL sSEL_FLAG_A		: STD_LOGIC := '0';
	SIGNAL sSEL_FLAG_B		: STD_LOGIC := '0';
	SIGNAL sSEL_FLAG_C		: STD_LOGIC := '0';
	
	SIGNAL sAD_SDI				: STD_LOGIC := '0';
	SIGNAL sAD_SDO				: STD_LOGIC := '0';
	SIGNAL sAD_SDIO_OE		: STD_LOGIC := '0';
	
	
BEGIN

  iobuff : alt_iobuf
  GENERIC MAP(
		IO_STANDARD => "NONE",
		CURRENT_STRENGTH => "NONE",
		SLOW_SLEW_RATE => "NONE",
		LOCATION => "NONE",
		ENABLE_BUS_HOLD => "NONE",
		WEAK_PULL_UP_RESISTOR => "NONE",
		TERMINATION => "NONE",
		INPUT_TERMINATION => "NONE",
		OUTPUT_TERMINATION => "NONE",
		SLEW_RATE =>  -1
    )
  PORT MAP(
    i => sAD_SDI,
    oe => sAD_SDIO_OE,
    io => AD_SDIO,
    o => sAD_SDO
    );     
	
	PROCESS (CLK, RST) IS
	BEGIN
		IF RST = '1' THEN 
			SPI_DATA_OUT 		<= (OTHERS => '0');
			SPI_ADA_OUT_WE		<= '0';
			SPI_ADA_OUT_WE		<= '0';
			SPI_AIC_OUT_WE		<= '0';
			SPI_BUSY				<= '1';
			AD_SCLK				<= '0';					-- Bynary when SPI not active
			sAD_SDI 				<= '1';					-- Duty Cycle Stabilazer when SPI not active
			sAD_SDIO_OE			<= '1'; 				-- OUTPUT
			ADA_SPI_CS 			<= '1';
			ADB_SPI_CS 			<= '1';
			AIC_SPI_CS 			<= '1';
			
		ELSIF RISING_EDGE(CLK) THEN
			-- defaults
			SPI_BUSY <= '1';
			SPI_ADA_OUT_WE <= '0';
			SPI_ADB_OUT_WE <= '0';
			SPI_AIC_OUT_WE <= '0';
			
			CASE sSPI_State IS 

				WHEN IDLE => ---------------------------------------------
				  
					AD_SCLK 			<= '0';
					SPI_BUSY 		<= '0';
					sSEL_FLAG_A 	<= '0';
					sSEL_FLAG_B		<= '0';
					sSEL_FLAG_C		<= '0';			-- C = CODEC
					ADA_SPI_CS 		<= '1';
					ADB_SPI_CS 		<= '1';
					AIC_SPI_CS 		<= '1';
					sAD_SDIO_OE 	<= '1';  	 	--OUTPUT 
					sCnt <= 0;
					
					sSPI_ADDRESS <= x"00" & SPI_ADDRESS;
					sSPI_DATA_IN <= SPI_DATA_IN;
					sSPI_DATA_RW <= SPI_DATA_RW;
					
					IF SPI_ADA_IN_WE = '1' THEN 
					
						sSEL_FLAG_A <= '1';
						sSPI_State <= DATA_INTERPRET;
						
					ELSIF SPI_ADB_IN_WE = '1' THEN
					
						sSEL_FLAG_B <= '1';
						sSPI_State <= DATA_INTERPRET;
					
					ELSIF SPI_AIC_IN_WE = '1' THEN
					
						sSEL_FLAG_C <= '1';
						sSPI_State <= ABORT_L;					--Add Support for CODEC later
						
					END IF;

				WHEN DATA_INTERPRET => ---------------------------------------------
				
					sCnt <= 16; 										--16 bits for the ADDRESS
					sCnt_WT <= WT_DEFAULT;
					
					CASE sSPI_ADDRESS(7 DOWNTO 0) IS
					
						WHEN x"00" =>									
							IF sSPI_DATA_RW = '1' THEN				--READ
								sSPI_ADDRESS(15) <= '1';
								sSPI_State <= ADDRESS_SHIFT_L;
							ELSE											--WRITE
								IF ((sSPI_DATA_IN(0) = sSPI_DATA_IN(7)) AND 
									 (sSPI_DATA_IN(1) = sSPI_DATA_IN(6)) AND 
									 (sSPI_DATA_IN(2) = sSPI_DATA_IN(5)) AND
									 (sSPI_DATA_IN(3) = sSPI_DATA_IN(4)) AND 
									 (sSPI_DATA_IN(0) = '0') AND (sSPI_DATA_IN(3) = '1')) THEN
									sSPI_ADDRESS(15) <= '0';
									sSPI_State <= ADDRESS_SHIFT_L;
								ELSE
									sSPI_State <= ABORT_L;
								END IF;	
							END IF;
	
						WHEN x"01" | x"02" =>
							sSPI_ADDRESS(15) <= '1';
							sSPI_State <= ADDRESS_SHIFT_L;			--READ ONLY

						WHEN x"08" | x"09" | x"10" | x"0D" |
						     x"14" | x"16" | x"18" | x"FF" =>								
							sSPI_ADDRESS(15) <= SPI_DATA_RW;
							sSPI_State <= ADDRESS_SHIFT_L;
						
						WHEN OTHERS => 
							sSPI_State <= ABORT_L;
					END CASE;
				
				WHEN ADDRESS_SHIFT_L => ----------------------------------------------------------
					
					AD_SCLK <= '0';
					sAD_SDIO_OE <= '1'; 										--OUTPUT 
					sAD_SDI <= sSPI_ADDRESS(15);
					sSPI_ADDRESS <= sSPI_ADDRESS(14 DOWNTO 0) & '0';
					IF sSEL_FLAG_A = '1' THEN
						ADA_SPI_CS <= '0';
					ELSIF sSEL_FLAG_B = '1' THEN
						ADB_SPI_CS <= '0';
					END IF;
					IF (sCnt_WT = 0) THEN 
						sSPI_State <= ADDRESS_SHIFT_H;
						sCnt_WT <= WT_DEFAULT;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
					
				
				WHEN ADDRESS_SHIFT_H => -------------------------------------------------------------
					
					AD_SCLK <= '1';
					IF (sCnt_WT = 0) THEN 
						sCnt <= sCnt - 1;
						sCnt_WT <= WT_DEFAULT;
						IF sCnt > 1 THEN  
							sSPI_State <= ADDRESS_SHIFT_L; 
						ELSIF sSPI_DATA_RW = '1' THEN
							sCnt <= 8;                        -- 8 bits for data read
							sSPI_State <= DATA_READ_L;
						ELSE	
							sCnt <= 8;                        -- 8 bits for data write
							sSPI_State <= DATA_WRITE_L;
						END IF; 
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
				
				WHEN DATA_READ_L => -----------------------------------------------------------------
				
					AD_SCLK <= '0';
					sAD_SDIO_OE <= '0'; 										--INPUT 
					IF (sCnt_WT = 0) THEN 
						sSPI_State <= DATA_READ_H; 
						sCnt_WT <= WT_DEFAULT;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
					
				WHEN DATA_READ_H => -----------------------------------------------------------------
	
					AD_SCLK <= '1';
					IF (sCnt_WT = 0) THEN 
						sCnt_WT <= WT_DEFAULT;
						sSPI_DATA_OUT <= sSPI_DATA_OUT(6 DOWNTO 0) & sAD_SDO;
						sCnt <= sCnt - 1;
						IF sCnt > 1 THEN  
							sSPI_State <= DATA_READ_L; 
						ELSE 
							sSPI_State <= DATA_READ_WE; 
						END IF;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
					
				WHEN DATA_READ_WE => ----------------------------------------------------------------
															-- NOTE: There is no waiting here, the OUT_WE is at
															-- the CLK frequency
															
					IF sSEL_FLAG_A = '1' THEN
						SPI_ADA_OUT_WE <= '1';
					ELSIF sSEL_FLAG_B = '1' THEN
						SPI_ADB_OUT_WE <= '1';
					END IF;
					sSPI_State <= IDLE;
					
				WHEN DATA_WRITE_L => ----------------------------------------------------------------
				
					AD_SCLK <= '0';
					sAD_SDIO_OE <= '1';  										--OUTPUT 
					sAD_SDI <= sSPI_DATA_IN(7);
					
					IF (sCnt_WT = 0) THEN 
						sCnt_WT <= WT_DEFAULT;
						sSPI_DATA_IN <= sSPI_DATA_IN(6 DOWNTO 0) & '0';
						sSPI_State <= DATA_WRITE_H;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
					
				WHEN DATA_WRITE_H => ----------------------------------------------------------------
				
					AD_SCLK <= '1';
					
					IF (sCnt_WT = 0) THEN 
						sCnt_WT <= WT_DEFAULT;
						sCnt <= sCnt - 1;
						IF sCnt > 1 THEN  
							sSPI_State <= DATA_WRITE_L; 
						ELSE
							sSPI_State <= DATA_WRITE_WT;
						END IF;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
					
				WHEN DATA_WRITE_WT => ----------------------------------------------------------------
					
					IF (sCnt_WT = 0) THEN 
						sCnt_WT <= WT_DEFAULT;
						sSPI_State <= IDLE;
					ELSE
						sCnt_WT	<= sCnt_WT - 1;     -- waiting
					END IF;
				
				WHEN ABORT_L => ----------------------------------------------------------------------
				
					sSPI_DATA_OUT <= x"FF";
					sSPI_State <= ABORT_H;
				
				WHEN ABORT_H => ----------------------------------------------------------------------
				
					IF sSEL_FLAG_A = '1' THEN
						SPI_ADA_OUT_WE <= '1';
					ELSIF sSEL_FLAG_B = '1' THEN
						SPI_ADB_OUT_WE <= '1';
					ELSIF sSEL_FLAG_C = '1' THEN
						SPI_AIC_OUT_WE <= '1';
					END IF;
					sSPI_State <= IDLE;
				
				WHEN OTHERS => -----------------------------------------------------------------------
				
					sSPI_State <= IDLE;
			
			END CASE;
			
		END IF;
		
		SPI_DATA_OUT <= sSPI_DATA_OUT;
		
	END PROCESS;
	
END AD_SPI_CONTROLLER_ARCH;
