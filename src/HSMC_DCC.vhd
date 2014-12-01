----------------------------------------------------------------------------------
-- Copyright (c) 2014, Luis Ardila
-- E-mail: leardilap@unal.edu.co
--
-- Description:
--
-- Revisions: 
-- Date        	Version    	Author    		Description
-- 28/11/2014    	1.0    		Luis Ardila    File created
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY HSMC_DCC IS 
PORT (
	CLK				: IN STD_LOGIC;
	CLK_180			: IN STD_LOGIC;
	CLK_270			: IN STD_LOGIC;
	RST				: IN STD_LOGIC;
	-- SPI CONTROL
	SPI_ADDRESS		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_IN		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_RW		: IN STD_LOGIC;								--1 READ - 0 WRITE
	SPI_ADA_IN_WE	: IN STD_LOGIC;
	SPI_ADB_IN_WE	: IN STD_LOGIC;
	SPI_AIC_IN_WE	: IN STD_LOGIC;
	SPI_DATA_OUT	: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_ADA_OUT_WE	: OUT STD_LOGIC;
	SPI_ADB_OUT_WE	: OUT STD_LOGIC;
	SPI_AIC_OUT_WE	: OUT STD_LOGIC;
	SPI_BUSY			: OUT STD_LOGIC;
	-- ADC DATA
	ADA_DOUT			: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
	ADB_DOUT			: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
	-- DAC DATA
	DA_DIN			: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	DB_DIN			: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	-- TO HSMC CONNECTOR DCC
	CLKIN1			: IN STD_LOGIC; 					--TP1
	CLKOUT0			: OUT STD_LOGIC;					--TP2
	J1_152			: OUT STD_LOGIC;					--TP5
	-- I2C EEPROM
	SCL				: OUT STD_LOGIC;					
	SDA				: INOUT STD_LOGIC;	
	-- External Clock Source in DCC
	XT_IN_N			: IN STD_LOGIC;					
	XT_IN_P			: IN STD_LOGIC;
	-- Clocks from FPGA
	FPGA_CLK_A_N	: OUT STD_LOGIC;
	FPGA_CLK_A_P 	: OUT STD_LOGIC;
	FPGA_CLK_B_N	: OUT STD_LOGIC;
	FPGA_CLK_B_P 	: OUT STD_LOGIC;
	-- ADC A
	ADA_D				: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	ADA_OR			: IN STD_LOGIC;					-- Out of range
	ADA_SPI_CS		: OUT STD_LOGIC;					-- Chip Select = 0
	ADA_OE			: OUT STD_LOGIC;					-- Enable = 0
	ADA_DCO			: IN STD_LOGIC;					-- Data clock output
	-- ADC B
	ADB_D				: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	ADB_OR			: IN STD_LOGIC;					-- Out of range
	ADB_SPI_CS		: OUT STD_LOGIC;              -- Chip Select = 0
	ADB_OE			: OUT STD_LOGIC;              -- Enable = 0
	ADB_DCO			: IN STD_LOGIC;               -- Data clock output
	-- DACs
	DA					: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
	DB					: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
	-- Audio CODEC
	AIC_XCLK			: IN STD_LOGIC;					-- Crystal or external-clock input
	AIC_LRCOUT		: INOUT STD_LOGIC;				-- I2S ADC-word clock signal
	AIC_LRCIN		: INOUT STD_LOGIC;				-- I2S DAC-word clock signal.
	AIC_DIN			: OUT STD_LOGIC;					-- I2S format serial data input to the sigma delta stereo DAC
	AIC_DOUT			: IN STD_LOGIC;					-- Output
	AD_SCLK			: OUT STD_LOGIC;					-- SPI
	AD_SDIO			: INOUT STD_LOGIC;				-- SPI
	AIC_SPI_CS		: OUT STD_LOGIC;					-- Chip Select = 0  (low active)
	AIC_BCLK			: INOUT STD_LOGIC					-- I2S serial-bit clock.
	);
END HSMC_DCC;

ARCHITECTURE HSMC_DCC_ARCH OF HSMC_DCC IS 

	COMPONENT AD_SPI_CONTROLLER IS
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
	END COMPONENT AD_SPI_CONTROLLER;

	SIGNAL sADA_DOUT : STD_LOGIC_VECTOR (13 DOWNTO 0);
	SIGNAL sADB_DOUT : STD_LOGIC_VECTOR (13 DOWNTO 0);
	
BEGIN 

	------------------------------------------------------------------------
	-- SPI
	AD_SPI_CONTROLLER_inst : AD_SPI_CONTROLLER
	PORT MAP (
		CLK						=> CLK,
		RST						=> RST,
		-- SPI CONTROL	
		SPI_ADDRESS				=> SPI_ADDRESS,		
		SPI_DATA_IN				=> SPI_DATA_IN,					
		SPI_DATA_RW			   => SPI_DATA_RW,		
		SPI_ADA_IN_WE		   => SPI_ADA_IN_WE,	
		SPI_ADB_IN_WE			=> SPI_ADB_IN_WE,	
		SPI_AIC_IN_WE			=> SPI_AIC_IN_WE,	
		SPI_DATA_OUT			=> SPI_DATA_OUT,	
		SPI_ADA_OUT_WE			=> SPI_ADA_OUT_WE,
		SPI_ADB_OUT_WE	      => SPI_ADB_OUT_WE,	
		SPI_AIC_OUT_WE			=> SPI_AIC_OUT_WE,
		SPI_BUSY					=> SPI_BUSY,				
		-- HSMC_DCC SPI
		AD_SCLK					=> AD_SCLK,	
		AD_SDIO					=> AD_SDIO,	
      ADA_SPI_CS				=> ADA_SPI_CS,
      ADB_SPI_CS				=> ADB_SPI_CS,
		AIC_SPI_CS				=> AIC_SPI_CS
	);
	
	------------------------------------------------------------------------
	-- ADC A
	-- NOTE: NOT USING THE OUT OF RANGE FLAG ADA_OR		
	
	ADA_OE			<= '1';			-- Output enabled

	ADA_PINS: PROCESS (RST, ADA_DCO) IS
	BEGIN
		IF RST = '1' THEN
			sADA_DOUT <= (OTHERS => '0');
		ELSIF RISING_EDGE(ADA_DCO) THEN
			sADA_DOUT <= ADA_D;
		END IF;
	END PROCESS ADA_PINS;
	
	ADA_SYNC : PROCESS (RST, CLK) IS
	BEGIN 
		IF RST = '1' THEN
			ADA_DOUT <= (OTHERS => '0');
		ELSIF RISING_EDGE(ADA_DCO) THEN
			ADA_DOUT <= sADA_DOUT;
		END IF;
	END PROCESS ADA_SYNC;
	
	------------------------------------------------------------------------
	-- ADC B
	-- NOTE: NOT USING THE OUT OF RANGE FLAG ADB_OR	
	
	ADB_OE			<= '1';			-- Output enabled
	
	ADB_PINS: PROCESS (RST, ADB_DCO) IS
	BEGIN
		IF RST = '1' THEN
			sADB_DOUT <= (OTHERS => '0');
		ELSIF RISING_EDGE(ADB_DCO) THEN
			sADB_DOUT <= ADB_D;
		END IF;
	END PROCESS ADB_PINS;
	
	ADB_SYNC : PROCESS (RST, CLK) IS
	BEGIN 
		IF RST = '1' THEN
			ADB_DOUT <= (OTHERS => '0');
		ELSIF RISING_EDGE(ADB_DCO) THEN
			ADB_DOUT <= sADB_DOUT;
		END IF;
	END PROCESS ADB_SYNC;
	
	------------------------------------------------------------------------
	-- DACs
	DA <= DA_DIN;
	DB <= DB_DIN;
	
	------------------------------------------------------------------------
	-- CLOCKS
	FPGA_CLK_A_P <= CLK_180;
	FPGA_CLK_A_N <= NOT CLK_180;
	FPGA_CLK_B_P <= CLK_270;
	FPGA_CLK_B_N <= NOT CLK_270;
	
	CLKOUT0 <= CLK_180; 					-- Test Point 2
	
	------------------------------------------------------------------------
	-- NOT USED
	SCL <= 'Z';
   SDA <= 'Z';
		
END HSMC_DCC_ARCH;
		