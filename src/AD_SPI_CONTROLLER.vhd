------------------------------------------------------------------------------
-- SPI Controller for the "DCC" AD/DA Data Conversion Card from TERASIC
-- Copyright (c) 2014 		Luis Ardila 	leardilap@unal.edu.co

LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 

library altera;
use altera.altera_primitives_components.all;

ENTITY AD_SPI_CONTROLLER IS
PORT(
	CLK10					: IN STD_LOGIC;								-- 10 MHz
	RST					: IN STD_LOGIC;
	SPI_ADDRESS			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_IN			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_RW			: IN STD_LOGIC;								--1 READ - 0 WRITE
	SPI_DATA_IN_WEA	: IN STD_LOGIC;
	SPI_DATA_IN_WEB	: IN STD_LOGIC;
	SPI_DATA_OUT		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_OUT_WEA	: OUT STD_LOGIC;
	SPI_DATA_OUT_WEB	: OUT STD_LOGIC;
	SPI_BUSY				: OUT STD_LOGIC;
	-- ADCs SPI INTERFACE
	AD_SCLK				: OUT STD_LOGIC;
	AD_SDIO				: INOUT STD_LOGIC;
	ADA_SPI_CS_n		: OUT STD_LOGIC;
	ADB_SPI_CS_n		: OUT STD_LOGIC
	);
END AD_SPI_CONTROLLER;

ARCHITECTURE AD_SPI_CONTROLLER_ARCH OF AD_SPI_CONTROLLER IS 
  
	TYPE State_Type IS (IDLE, DATA_INTERPRET, ADDRESS_SHIFT_L, ADDRESS_SHIFT_H, DATA_READ_L,
                      DATA_READ_H, DATA_READ_WE, DATA_WRITE_L, DATA_WRITE_H, ABORT_L, ABORT_H); 
	SIGNAL sSPI_State  : State_Type; 
	
	SIGNAL sCnt					: INTEGER RANGE 0 TO 32;
	
	SIGNAL sSPI_ADDRESS		: STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_IN		: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
	SIGNAL sSPI_DATA_RW		: STD_LOGIC := '0';

	SIGNAL sSEL_FLAG_A		: STD_LOGIC := '0';
	SIGNAL sSEL_FLAG_B		: STD_LOGIC := '0';
	
	SIGNAL sAD_SDI				: STD_LOGIC := '0';
	SIGNAL sAD_SDO				: STD_LOGIC := '0';
	SIGNAL sAD_SDIO_IO		: STD_LOGIC := '0';
	
BEGIN

  iobuff : alt_iobuf
  GENERIC MAP(
    WEAK_PULL_UP_RESISTOR => "ON"
    )
  PORT MAP(
    i => sAD_SDI,
    oe => sAD_SDIO_IO,
    io => AD_SDIO,
    o => sAD_SDO
    );    
	
	PROCESS (CLK10, RST) IS
	BEGIN
		IF RST = '1' THEN 
			SPI_DATA_OUT 		<= (OTHERS => '0');
			SPI_DATA_OUT_WEA	<= '0';
			SPI_DATA_OUT_WEB	<= '0';
			SPI_BUSY				<= '1';
			AD_SCLK				<= '0';
			sAD_SDI 				<= '0';
			sAD_SDIO_IO			<= '1';  				--OUTPUT (NEED CHECK)
			ADA_SPI_CS_n <= '1';
			ADB_SPI_CS_n <= '1';
			
		ELSIF RISING_EDGE(CLK10) THEN
			-- defaults
			SPI_BUSY <= '1';
			SPI_DATA_OUT_WEA <= '0';
			SPI_DATA_OUT_WEB <= '0';
			
			CASE sSPI_State IS 

				WHEN IDLE => 
				  
          AD_SCLK <= '0';
					SPI_BUSY <= '0';
					sSEL_FLAG_A <= '0';
					sSEL_FLAG_B	<= '0';
					ADA_SPI_CS_n <= '1';
					ADB_SPI_CS_n <= '1';
					sAD_SDIO_IO <= '1';  										            --OUTPUT (NEED CHECK)
					sCnt <= 0; 										
					IF SPI_DATA_IN_WEA = '1' THEN 
						sSEL_FLAG_A <= '1';
						sSPI_ADDRESS <= x"00" & SPI_ADDRESS;
						sSPI_DATA_IN <= SPI_DATA_IN;
						sSPI_DATA_RW <= SPI_DATA_RW;
						sSPI_State <= DATA_INTERPRET;
					ELSIF SPI_DATA_IN_WEB = '1' THEN
						sSEL_FLAG_B <= '1';
						sSPI_ADDRESS <= x"00" & SPI_ADDRESS;
						sSPI_DATA_IN <= SPI_DATA_IN;
						sSPI_DATA_RW <= SPI_DATA_RW;
						sSPI_State <= DATA_INTERPRET;
					END IF;

				WHEN DATA_INTERPRET =>
					sCnt <= 16; 										--16 bits for the ADDRESS 
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
				
				WHEN ADDRESS_SHIFT_L =>
					
					AD_SCLK <= '0';
					sAD_SDIO_IO <= '1';  										--OUTPUT (NEED CHECK)
					sAD_SDI <= sSPI_ADDRESS(15);
					sSPI_ADDRESS <= sSPI_ADDRESS(14 DOWNTO 0) & '0';
					IF sSEL_FLAG_A = '1' THEN
						ADA_SPI_CS_n <= '0';
					ELSIF sSEL_FLAG_B = '1' THEN
						ADB_SPI_CS_n <= '0';
					END IF;
					sSPI_State <= ADDRESS_SHIFT_H;
				
				WHEN ADDRESS_SHIFT_H =>
					
					AD_SCLK <= '1';
					sCnt <= sCnt - 1;
					IF sCnt > 1 THEN  
 						sSPI_State <= ADDRESS_SHIFT_L; 
 					ELSIF sSPI_DATA_RW = '1' THEN
						sCnt <= 8;                        -- 8 bits for data read
						sSPI_State <= DATA_READ_L;
					ELSE	
						sCnt <= 8;                        -- 8 bits for data write
						sSPI_State <= DATA_WRITE_L;
					END IF; 
				
				WHEN DATA_READ_L =>
					AD_SCLK <= '0';
					sAD_SDIO_IO <= '0';  										--INPUT (NEED CHECK)
					sSPI_State <= DATA_READ_H; 
				
				WHEN DATA_READ_H =>
					AD_SCLK <= '1';
					sSPI_DATA_OUT <= sSPI_DATA_OUT(6 DOWNTO 0) & sAD_SDO;
					sCnt <= sCnt - 1;
					IF sCnt > 1 THEN  
 						sSPI_State <= DATA_READ_L; 
					ELSE 
						sSPI_State <= DATA_READ_WE; 
					END IF;
				
				WHEN DATA_READ_WE =>
				  IF sSEL_FLAG_A = '1' THEN
						SPI_DATA_OUT_WEA <= '1';
					ELSIF sSEL_FLAG_B = '1' THEN
						SPI_DATA_OUT_WEB <= '1';
					END IF;
					sSPI_State <= IDLE;
					
				WHEN DATA_WRITE_L =>
					AD_SCLK <= '0';
					sAD_SDIO_IO <= '1';  										--OUTPUT (NEED CHECK)
					sAD_SDI <= sSPI_DATA_IN(7);
					sSPI_DATA_IN <= sSPI_DATA_IN(6 DOWNTO 0) & '0';
					sSPI_State <= DATA_WRITE_H;
					
				WHEN DATA_WRITE_H =>
					AD_SCLK <= '1';
					sCnt <= sCnt - 1;
					IF sCnt > 1 THEN  
 						sSPI_State <= DATA_WRITE_L; 
 					ELSE
						sSPI_State <= IDLE;
					END IF;
				
				WHEN ABORT_L =>
					sSPI_DATA_OUT <= x"FF";
					sSPI_State <= ABORT_H;
				
				WHEN ABORT_H =>
					IF sSEL_FLAG_A = '1' THEN
						SPI_DATA_OUT_WEA <= '1';
					ELSIF sSEL_FLAG_B = '1' THEN
						SPI_DATA_OUT_WEB <= '1';
					END IF;
					sSPI_State <= IDLE;
				
				WHEN OTHERS =>
					sSPI_State <= IDLE;
			
			END CASE;
			
		END IF;
		
		SPI_DATA_OUT <= sSPI_DATA_OUT;
		
	END PROCESS;
	
	
	
END AD_SPI_CONTROLLER_ARCH;
