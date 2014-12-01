----------------------------------------------------------------------------------
-- Copyright (c) 2014, Luis Ardila
-- E-mail: leardilap@unal.edu.co
--
-- Description:
--
-- Revisions: 
-- Date        	Version    	Author    		Description
-- 12/10/2014    	1.0    		Luis Ardila    File created
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY DE2i_150_DCC_TOP IS 
PORT (
	--	CLOCKS
		CLOCK_50				: IN STD_LOGIC;	
		CLOCK2_50			: IN STD_LOGIC;	
		CLOCK3_50			: IN STD_LOGIC;	

	--	DRAM
		DRAM_ADDR			: OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
		DRAM_BA				: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		DRAM_CAS_N			: OUT STD_LOGIC;
		DRAM_CKE				: OUT STD_LOGIC;
		DRAM_CLK				: OUT STD_LOGIC;
		DRAM_CS_N			: OUT STD_LOGIC;
		DRAM_DQM				: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		DRAM_DQ				: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		DRAM_RAS_N			: OUT STD_LOGIC;
		DRAM_WE_N			: OUT STD_LOGIC;

	-- EEP
		EEP_I2C_SCLK		: OUT STD_LOGIC;
		EEP_I2C_SDAT		: INOUT STD_LOGIC;

	-- ENET
		ENET_GTX_CLK		: OUT STD_LOGIC;
		ENET_INT_N			: IN STD_LOGIC;
		ENET_LINK100		: IN STD_LOGIC;
		ENET_MDC				: OUT STD_LOGIC;
		ENET_MDIO			: INOUT STD_LOGIC;
		ENET_RST_N			: OUT STD_LOGIC;
		ENET_RX_CLK			: IN STD_LOGIC;
		ENET_RX_COL			: IN STD_LOGIC;
		ENET_RX_CRS			: IN STD_LOGIC;
		ENET_RX_DATA		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		ENET_RX_DV			: IN STD_LOGIC;
		ENET_RX_ER			: IN STD_LOGIC;
		ENET_TX_CLK			: IN STD_LOGIC;
		ENET_TX_DATA		: OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		ENET_TX_EN			: OUT STD_LOGIC;
		ENET_TX_ER			: OUT STD_LOGIC;

	-- FAN
		FAN_CTRL				: OUT STD_LOGIC;

	-- FL
		FL_CE_N				: OUT STD_LOGIC;
		FL_OE_N				: OUT STD_LOGIC;
		FL_RESET_N			: OUT STD_LOGIC;
		FL_RY					: IN STD_LOGIC;
		FL_WE_N				: OUT STD_LOGIC;
		FL_WP_N				: OUT STD_LOGIC;

	-- FS
		FS_ADDR				: OUT STD_LOGIC_VECTOR (26 DOWNTO 0);
		FS_DQ					: INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);

	-- GPIO
		GPIO					: INOUT STD_LOGIC_VECTOR (35 DOWNTO 0);

	-- G
		G_SENSOR_INT1		: IN STD_LOGIC;
		G_SENSOR_SCLK		: OUT STD_LOGIC;
		G_SENSOR_SDAT		: INOUT STD_LOGIC;

	-- HEX
		HEX0					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX1					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX2					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX3					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX4					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX5					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX6					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX7					: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);

	-- HSMC
		HSMC_CLKIN1			: IN STD_LOGIC; 										--TP1
		HSMC_CLKOUT0		: OUT STD_LOGIC;										--TP2
		HSMC_J1_152			: OUT STD_LOGIC;										--TP5
		
		HSMC_SCL				: OUT STD_LOGIC;
		HSMC_SDA				: INOUT STD_LOGIC;	
		
		HSMC_XT_IN_N		: IN STD_LOGIC;
		HSMC_XT_IN_P		: IN STD_LOGIC;
		
		HSMC_FPGA_CLK_A_N	: OUT STD_LOGIC;
		HSMC_FPGA_CLK_A_P : OUT STD_LOGIC;
		HSMC_FPGA_CLK_B_N	: OUT STD_LOGIC;
		HSMC_FPGA_CLK_B_P : OUT STD_LOGIC;

		HSMC_ADA_D			: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		HSMC_ADA_OR			: IN STD_LOGIC;
		HSMC_ADA_SPI_CS	: OUT STD_LOGIC;
		HSMC_ADA_OE			: OUT STD_LOGIC;
		HSMC_ADA_DCO		: IN STD_LOGIC;
		
		HSMC_ADB_D			: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
		HSMC_ADB_OR			: IN STD_LOGIC;
		HSMC_ADB_SPI_CS	: OUT STD_LOGIC;
		HSMC_ADB_OE			: OUT STD_LOGIC;
		HSMC_ADB_DCO		: IN STD_LOGIC;
		
		HSMC_DA				: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
		HSMC_DB				: OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
		
		HSMC_AIC_XCLK		: IN STD_LOGIC;
		HSMC_AIC_LRCOUT	: INOUT STD_LOGIC;
		HSMC_AIC_LRCIN		: INOUT STD_LOGIC;
		HSMC_AIC_DIN		: OUT STD_LOGIC;
		HSMC_AIC_DOUT		: IN STD_LOGIC;
		HSMC_AD_SCLK		: OUT STD_LOGIC;
		HSMC_AD_SDIO		: INOUT STD_LOGIC;
		HSMC_AIC_SPI_CS	: OUT STD_LOGIC;						--low active
		HSMC_AIC_BCLK		: INOUT STD_LOGIC;
		
	-- I2C
		I2C_SCLK				: OUT STD_LOGIC;
		I2C_SDAT				: INOUT STD_LOGIC;

	-- IRDA
		IRDA_RXD				: IN STD_LOGIC;

	-- KEY
		KEY					: IN STD_LOGIC_VECTOR (3 DOWNTO 0);

	-- LCD
		LCD_DATA				: INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		LCD_EN				: OUT STD_LOGIC;
		LCD_ON				: OUT STD_LOGIC;
		LCD_RS				: OUT STD_LOGIC;
		LCD_RW				: OUT STD_LOGIC;

	-- LEDS
		LEDG					: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		LEDR					: OUT STD_LOGIC_VECTOR (17 DOWNTO 0);

	-- PCIE
		--PCIE_PERST_N		: IN STD_LOGIC;
		--PCIE_REFCLK_P	: IN STD_LOGIC;
		--PCIE_RX_P			: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		--PCIE_TX_P			: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		--PCIE_WAKE_N		: OUT STD_LOGIC;

	-- SD
		SD_CLK				: OUT STD_LOGIC;
		SD_CMD				: INOUT STD_LOGIC;
		SD_DAT				: INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		SD_WP_N				: IN STD_LOGIC;

	-- SMA
		SMA_CLKIN			: IN STD_LOGIC;
		SMA_CLKOUT        : OUT STD_LOGIC;

	-- SSRAM
		SSRAM0_CE_N       : OUT STD_LOGIC;
		SSRAM1_CE_N       : OUT STD_LOGIC;
		SSRAM_ADSC_N      : OUT STD_LOGIC;
		SSRAM_ADSP_N      : OUT STD_LOGIC;
		SSRAM_ADV_N       : OUT STD_LOGIC;
		SSRAM_BE				: INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
		SSRAM_CLK			: OUT STD_LOGIC;
		SSRAM_GW_N        : OUT STD_LOGIC;
		SSRAM_OE_N        : OUT STD_LOGIC;
		SSRAM_WE_N        : OUT STD_LOGIC;

	-- SW
		SW						: IN STD_LOGIC_VECTOR (17 DOWNTO 0);

	-- TD
		TD_CLK27				: IN STD_LOGIC;
		TD_DATA				: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		TD_HS					: IN STD_LOGIC;
		TD_RESET_N        : OUT STD_LOGIC;
		TD_VS             : IN STD_LOGIC;

	-- UART
		UART_CTS          : IN STD_LOGIC;
		UART_RTS          : OUT STD_LOGIC;
		UART_RXD          : IN STD_LOGIC;
		UART_TXD          : OUT STD_LOGIC;
		
	-- VGA
		VGA_BLANK_N       : OUT STD_LOGIC;
		VGA_B					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		VGA_CLK				: OUT STD_LOGIC;
		VGA_G					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		VGA_HS				: OUT STD_LOGIC;
		VGA_R					: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		VGA_SYNC_N			: OUT STD_LOGIC;
		VGA_VS				: OUT STD_LOGIC
		);
END DE2i_150_DCC_TOP;

ARCHITECTURE DE2i_150_DCC_TOP_ARCH OF DE2i_150_DCC_TOP IS

---------------------------------------------------------------
-- COMPONENTS 
---------------------------------------------------------------

COMPONENT PLL_1 IS 
PORT (
	inclk0		: IN STD_LOGIC  := '0';
	c0				: OUT STD_LOGIC ;
	c1				: OUT STD_LOGIC ;
	c2				: OUT STD_LOGIC ;
	c3				: OUT STD_LOGIC ;
	locked		: OUT STD_LOGIC 
	);
END COMPONENT PLL_1;

COMPONENT HSMC_DCC IS 
PORT (
	CLK				: IN STD_LOGIC;
	CLK_180			: IN STD_LOGIC;
	CLK_270			: IN STD_LOGIC;
	RST				: IN STD_LOGIC;
	-- SPI CONTROL
	SPI_ADDRESS			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_IN			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_DATA_RW			: IN STD_LOGIC;								--1 READ - 0 WRITE
	SPI_ADA_IN_WE		: IN STD_LOGIC;
	SPI_ADB_IN_WE		: IN STD_LOGIC;
	SPI_AIC_IN_WE		: IN STD_LOGIC;
	SPI_DATA_OUT		: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
	SPI_ADA_OUT_WE		: OUT STD_LOGIC;
	SPI_ADB_OUT_WE	   : OUT STD_LOGIC;
	SPI_AIC_OUT_WE		: OUT STD_LOGIC;
	SPI_BUSY				: OUT STD_LOGIC;
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
		
	XT_IN_N			: IN STD_LOGIC;
	XT_IN_P			: IN STD_LOGIC;
	
	FPGA_CLK_A_N	: OUT STD_LOGIC;
	FPGA_CLK_A_P 	: OUT STD_LOGIC;
	FPGA_CLK_B_N	: OUT STD_LOGIC;
	FPGA_CLK_B_P 	: OUT STD_LOGIC;

	ADA_D				: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	ADA_OR			: IN STD_LOGIC;					-- Out of range
	ADA_SPI_CS		: OUT STD_LOGIC;					-- Chip Select = 0
	ADA_OE			: OUT STD_LOGIC;					-- Enable = 0
	ADA_DCO			: IN STD_LOGIC;					-- Data clock output
	
	ADB_D				: IN STD_LOGIC_VECTOR(13 DOWNTO 0);
	ADB_OR			: IN STD_LOGIC;					-- Out of range
	ADB_SPI_CS		: OUT STD_LOGIC;              -- Chip Select = 0
	ADB_OE			: OUT STD_LOGIC;              -- Enable = 0
	ADB_DCO			: IN STD_LOGIC;               -- Data clock output
	
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
END COMPONENT HSMC_DCC;

COMPONENT HEX_MODULE IS
	PORT (
		HDIG_0		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_1		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_2		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_3		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_4		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_5		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_6		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);
		HDIG_7		: IN 	STD_LOGIC_VECTOR (3 DOWNTO 0);		
		HEX_0			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_1			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_2			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_3			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_4			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_5			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_6			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		HEX_7			: OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
END COMPONENT HEX_MODULE;

COMPONENT LCD16x2 IS 
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
END COMPONENT LCD16x2;

---------------------------------------------------------------------------
-- SIGNALS 
---------------------------------------------------------------------------

-- CLOCK PLL SIGNALS 
SIGNAL sCLK100			: STD_LOGIC := '0';
SIGNAL sCLK100_90		: STD_LOGIC := '0';
SIGNAL sCLK100_180	: STD_LOGIC := '0';
SIGNAL sCLK100_270	: STD_LOGIC := '0';
SIGNAL sLocked 		: STD_LOGIC := '0';

-- SIGNALs FOR OUTSIDE
SIGNAL	RST			:	STD_LOGIC; 	
SIGNAL	SUB			:	STD_LOGIC; 	
SIGNAL	ADD         :	STD_LOGIC; 	
SIGNAL	SEG_0		:	STD_LOGIC_VECTOR (6 DOWNTO 0); --Seven Segments ¨HEX0¨ 

SIGNAL sADD					: 	STD_LOGIC := '0';
SIGNAL sSUB					: 	STD_LOGIC := '0';
SIGNAL sHDIG				:	STD_LOGIC_VECTOR (3 DOWNTO 0) := (OTHERS => '0');
SIGNAL sHEX0				:	STD_LOGIC_VECTOR (6 DOWNTO 0) := (OTHERS => '0');

SIGNAL sSPI_DATA_OUT  		: STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
SIGNAL sSPI_DATA_IN_WEA		: STD_LOGIC := '0';
SIGNAL sSPI_DATA_OUT_WEA	: STD_LOGIC := '0';
SIGNAL sSPI_DATA_OUT_WEB	: STD_LOGIC := '0';
SIGNAL sSPI_DATA_OUT_WEA_BUFF	: STD_LOGIC := '0';
SIGNAL sSPI_DATA_OUT_WEB_BUFF	: STD_LOGIC := '0';
SIGNAL sSPI_BUSY				: STD_LOGIC := '0';

SIGNAL sADA_DATA_EN			: STD_LOGIC := '0';
SIGNAL sADB_DATA_EN			: STD_LOGIC := '0';
SIGNAL sADA_DOUT				: STD_LOGIC_VECTOR (13 DOWNTO 0);
SIGNAL sADB_DOUT				: STD_LOGIC_VECTOR (13 DOWNTO 0);


SIGNAL sSPI_CNT  				: INTEGER RANGE 0 to 655000 := 0;

BEGIN 

PLL_1_inst : PLL_1 
PORT MAP (
		inclk0	=> CLOCK_50,
		c0	 		=> sCLK100,
		c1			=> sCLK100_90,
		c2			=> sCLK100_180,
		c3			=> sCLK100_270,
		locked	=> sLocked
		);
			
HSMC_DCC_INST : HSMC_DCC
PORT MAP(
	CLK					=> sCLK100,
	CLK_180				=> sCLK100_180,
	CLK_270				=> sCLK100_270,
	RST					=> RST,
	-- SPI CONTROL
	SPI_ADDRESS			=> SW(15 DOWNTO 8),
	SPI_DATA_IN			=> SW(7 DOWNTO 0),
	SPI_DATA_RW			=>	SW(17),					--1 READ - 0 WRITE
	SPI_ADA_IN_WE		=> sSPI_DATA_IN_WEA,
	SPI_ADB_IN_WE		=> '0',
	SPI_AIC_IN_WE		=> '0',
	SPI_DATA_OUT		=> sSPI_DATA_OUT,
	SPI_ADA_OUT_WE		=> sSPI_DATA_OUT_WEA,
	SPI_ADB_OUT_WE		=> sSPI_DATA_OUT_WEB,
	SPI_AIC_OUT_WE		=> OPEN,
	SPI_BUSY				=> sSPI_BUSY,
	-- ADC DATA
	ADA_DOUT				=> sADA_DOUT,
	ADB_DOUT				=> sADB_DOUT,
	-- DAC DATA
	DA_DIN				=> (OTHERS => '0'),
	DB_DIN				=> (OTHERS => '0'),
	-- TO HSMC CONNECTOR DCC
	CLKIN1				=> HSMC_CLKIN1,								--TP1
	CLKOUT0				=> HSMC_CLKOUT0,							--TP2
	J1_152				=> HSMC_J1_152,								--TP5
	-- I2C EEPROM	      
	SCL					=> HSMC_SCL,									
	SDA					=> HSMC_SDA,				
			               
	XT_IN_N				=> HSMC_XT_IN_N,		
	XT_IN_P				=> HSMC_XT_IN_P,		
		                  
	FPGA_CLK_A_N		=> HSMC_FPGA_CLK_A_N,	
	FPGA_CLK_A_P 		=> HSMC_FPGA_CLK_A_P, 
	FPGA_CLK_B_N		=> HSMC_FPGA_CLK_B_N,	
	FPGA_CLK_B_P 		=> HSMC_FPGA_CLK_B_P, 
                        
	ADA_D					=> HSMC_ADA_D,			
	ADA_OR				=> HSMC_ADA_OR,			-- Out of range
	ADA_SPI_CS			=> HSMC_ADA_SPI_CS,	-- Chip Select = 0
	ADA_OE				=> HSMC_ADA_OE,			-- Enable = 0
	ADA_DCO				=> HSMC_ADA_DCO,		-- Data clock output
	                     
	ADB_D					=> HSMC_ADB_D,			
	ADB_OR				=> HSMC_ADB_OR,			-- Out of range
	ADB_SPI_CS			=> HSMC_ADB_SPI_CS,	-- Chip Select = 0
	ADB_OE				=> HSMC_ADB_OE,			-- Enable = 0
	ADB_DCO				=> HSMC_ADB_DCO,		-- Data clock output
	                     
	DA						=> HSMC_DA,				
	DB						=> HSMC_DB,				
	-- Audio CODEC	      
	AIC_XCLK				=> HSMC_AIC_XCLK,		-- Crystal or external-clock input
	AIC_LRCOUT			=> HSMC_AIC_LRCOUT,	-- I2S ADC-word clock signal
	AIC_LRCIN			=> HSMC_AIC_LRCIN,		-- I2S DAC-word clock signal.
	AIC_DIN				=> HSMC_AIC_DIN,		-- I2S format serial data input to the sigma delta stereo DAC
	AIC_DOUT				=> HSMC_AIC_DOUT,		-- Output
	AD_SCLK				=> HSMC_AD_SCLK,		-- SPI
	AD_SDIO				=> HSMC_AD_SDIO,		-- SPI
	AIC_SPI_CS			=> HSMC_AIC_SPI_CS,	-- Chip Select = 0  (low active)
	AIC_BCLK				=> HSMC_AIC_BCLK		-- I2S serial-bit clock.
	);
	
LCD16x2_INST : LCD16x2
GENERIC MAP(
	CLK_PERIOD_NS => 10)    -- 10MHz   --POSITIVE is INTEGER but from 1 to 2147483647
PORT MAP(	
	CLK            => sCLK100,
	RST            => RST,
	ADA_DATA_IN    => sADA_DOUT(7 DOWNTO 0),
	ADA_DATA_EN    => sCLK100,
	ADB_DATA_IN		=> sADB_DOUT(7 DOWNTO 0),
	ADB_DATA_EN    => sCLK100,   
	--LCD INTERFACE
	LCD_DATA       => LCD_DATA,
	LCD_EN			=> LCD_EN,
	LCD_ON			=> LCD_ON,
	LCD_RS			=> LCD_RS,
	LCD_RW			=> LCD_RW
	);


HEX_MODULE_INST : HEX_MODULE
PORT MAP(
		HDIG_0	=> sHDIG,	
		HDIG_1	=> (OTHERS => '0'),
		HDIG_2	=> sSPI_DATA_OUT(3 DOWNTO 0),	
		HDIG_3	=> sSPI_DATA_OUT(7 DOWNTO 4),	
		HDIG_4	=> SW(3 DOWNTO 0),	
		HDIG_5	=> SW(7 DOWNTO 4),	
		HDIG_6	=> SW(11 DOWNTO 8),
		HDIG_7	=> SW(15 DOWNTO 12),			
		HEX_0		=> sHEX0,	
		HEX_1		=> OPEN,	
		HEX_2		=> HEX2,
		HEX_3		=> HEX3,	
		HEX_4		=> HEX4,	
		HEX_5		=> HEX5,	
		HEX_6		=> HEX6,	
		HEX_7		=> HEX7
		);

AD_SPI_PROCESS : PROCESS (sCLK100, RST) IS
BEGIN
	IF RST = '1' THEN
		sSPI_DATA_IN_WEA <= '0';
	ELSIF rising_edge(sCLK100) AND sSPI_BUSY = '0' THEN
		sSPI_DATA_IN_WEA <= '0';
		IF KEY(3) = '0' THEN
			IF sSPI_CNT > 650000 THEN
				sSPI_DATA_IN_WEA <= '1';
				sSPI_CNT <= 0;
			ELSE 
				sSPI_DATA_IN_WEA <= '0';
				sSPI_CNT <= sSPI_CNT + 1;
			END IF;
		END IF;
	END IF;
	
END PROCESS AD_SPI_PROCESS;

COUNTER: PROCESS (sCLK100, RST) IS
BEGIN

	IF RST = '1' THEN
		sHDIG <= (OTHERS => '0');
	ELSIF rising_edge(sCLK100) THEN
		sADD <= ADD;
		sSUB <= SUB;
		IF (sADD = '1') AND (ADD = '0')  AND (SUB = '1') THEN							--add
			sHDIG <= STD_LOGIC_VECTOR(UNSIGNED(sHDIG) + 1);
		ELSIF (sSUB = '1') AND (SUB = '0') AND (ADD = '1') THEN						--subtract
			sHDIG <= STD_LOGIC_VECTOR(UNSIGNED(sHDIG) - 1);
		ELSE
			sHDIG <= sHDIG;													--keep value
		END IF;
	END IF;
END PROCESS COUNTER;

RST		<= not KEY(2);
SUB		<= KEY(1);
ADD		<= KEY(0); 

LEDR		<= SW;
LEDG 		<= sLocked & b"0" & sHEX0;

HEX0 		<= sHEX0;
HEX1		<= (OTHERS => '1'); -- OFF

--Turn fan off
FAN_CTRL <= '0';

END DE2i_150_DCC_TOP_ARCH;