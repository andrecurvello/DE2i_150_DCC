LIBRARY IEEE; 
USE IEEE.STD_LOGIC_1164.ALL; 
USE IEEE.NUMERIC_STD.ALL; 

ENTITY TB_AD_SPI_CONTROLLER IS
END TB_AD_SPI_CONTROLLER;

ARCHITECTURE TB OF TB_AD_SPI_CONTROLLER IS

    COMPONENT AD_SPI_CONTROLLER
        PORT(CLK10            : in std_logic;
              RST              : in std_logic;
              SPI_ADDRESS      : in std_logic_vector (7 downto 0);
              SPI_DATA_IN      : in std_logic_vector (7 downto 0);
              SPI_DATA_RW      : in std_logic;
              SPI_DATA_IN_WEA  : in std_logic;
              SPI_DATA_IN_WEB  : in std_logic;
              SPI_DATA_OUT     : out std_logic_vector (7 downto 0);
              SPI_DATA_OUT_WEA : out std_logic;
              SPI_DATA_OUT_WEB : out std_logic;
              SPI_BUSY         : out std_logic;
              AD_SCLK          : out std_logic;
              AD_SDIO          : inout std_logic;
              ADA_SPI_CS_n     : out std_logic;
              ADB_SPI_CS_n     : out std_logic);
    END COMPONENT;

    SIGNAL CLK10            : std_logic := '0';
    SIGNAL RST              : std_logic := '0';
    SIGNAL SPI_ADDRESS      : std_logic_vector (7 downto 0) := (OTHERS => '0');
    SIGNAL SPI_DATA_IN      : std_logic_vector (7 downto 0) := (OTHERS => '0');
    SIGNAL SPI_DATA_RW      : std_logic := '0';
    SIGNAL SPI_DATA_IN_WEA  : std_logic := '0';
    SIGNAL SPI_DATA_IN_WEB  : std_logic := '0';
    SIGNAL SPI_DATA_OUT     : std_logic_vector (7 downto 0) := (OTHERS => '0');
    SIGNAL SPI_DATA_OUT_WEA : std_logic := '0';
    SIGNAL SPI_DATA_OUT_WEB : std_logic := '0';
    SIGNAL SPI_BUSY         : std_logic := '0';
    SIGNAL AD_SCLK          : std_logic := '0';
    SIGNAL AD_SDIO          : std_logic := '0';
    SIGNAL ADA_SPI_CS_n     : std_logic := '0';
    SIGNAL ADB_SPI_CS_n     : std_logic := '0';

    constant CLK10_Period : time := 100 ns;    -- 10 MHz

BEGIN

    dut : AD_SPI_CONTROLLER
    PORT MAP (CLK10            => CLK10,
              RST              => RST,
              SPI_ADDRESS      => SPI_ADDRESS,
              SPI_DATA_IN      => SPI_DATA_IN,
              SPI_DATA_RW      => SPI_DATA_RW,
              SPI_DATA_IN_WEA  => SPI_DATA_IN_WEA,
              SPI_DATA_IN_WEB  => SPI_DATA_IN_WEB,
              SPI_DATA_OUT     => SPI_DATA_OUT,
              SPI_DATA_OUT_WEA => SPI_DATA_OUT_WEA,
              SPI_DATA_OUT_WEB => SPI_DATA_OUT_WEB,
              SPI_BUSY         => SPI_BUSY,
              AD_SCLK          => AD_SCLK,
              AD_SDIO          => AD_SDIO,
              ADA_SPI_CS_n     => ADA_SPI_CS_n,
              ADB_SPI_CS_n     => ADB_SPI_CS_n);

    CLK10 <= not CLK10 after CLK10_Period/2;

    stimuli : PROCESS
    BEGIN
		    RST              <= '1';
        SPI_ADDRESS      <= x"11";
        SPI_DATA_IN      <= x"11";
        SPI_DATA_RW      <= '0';
        SPI_DATA_IN_WEA  <= '0';
        SPI_DATA_IN_WEB  <= '0';
      wait for CLK10_Period*10;
		    RST              <= '0';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '0';
		    
		  wait until SPI_BUSY = '0';
		  wait until CLK10 = '1';
		    SPI_ADDRESS      <= x"00";
		    SPI_DATA_IN      <= x"18";
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '0'; 
		    
		  wait until SPI_BUSY = '0';
		  wait until CLK10 = '1';
		    SPI_ADDRESS      <= x"00";
		    SPI_DATA_IN      <= x"19";
		    SPI_DATA_RW      <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEA  <= '0'; 
		  
		 wait until SPI_BUSY = '0';
		  wait until CLK10 = '1';
		    SPI_ADDRESS      <= x"14";
		    SPI_DATA_IN      <= x"25";
		    SPI_DATA_RW      <= '0';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEB  <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEB  <= '0'; 
		  
		  wait until SPI_BUSY = '0';
		  wait until CLK10 = '1';
		    SPI_ADDRESS      <= x"14";
		    SPI_DATA_IN      <= x"26";
		    SPI_DATA_RW      <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEB  <= '1';
		  wait for CLK10_Period;
		    SPI_DATA_IN_WEB  <= '0'; 
      wait;
    END PROCESS;

END TB;