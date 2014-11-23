library ieee;
use ieee.std_logic_1164.all;

library altera; 
use altera.altera_primitives_components.all; 

entity tb_LCD16x2 is
end tb_LCD16x2;

architecture tb of tb_LCD16x2 is

    component LCD16x2
        generic (CLK_PERIOD_NS : positive := 20);
        port (CLK         : in std_logic;
              RST         : in std_logic;
              ADA_DATA_IN : in std_logic_vector (7 downto 0);
              ADA_DATA_EN : in std_logic;
              ADB_DATA_IN : in std_logic_vector (7 downto 0);
              ADB_DATA_EN : in std_logic;
              LCD_DATA    : inout std_logic_vector (7 downto 0);
              LCD_EN      : out std_logic;
              LCD_ON      : out std_logic;
              LCD_RS      : out std_logic;
              LCD_RW      : out std_logic);
    end component;

    signal CLK         : std_logic;
    signal RST         : std_logic;
    signal ADA_DATA_IN : std_logic_vector (7 downto 0);
    signal ADA_DATA_EN : std_logic;
    signal ADB_DATA_IN : std_logic_vector (7 downto 0);
    signal ADB_DATA_EN : std_logic;
    signal LCD_DATA    : std_logic_vector (7 downto 0);
    signal LCD_EN      : std_logic;
    signal LCD_ON      : std_logic;
    signal LCD_RS      : std_logic;
    signal LCD_RW      : std_logic;
    
    SIGNAL LCD_DATA_OE : STD_LOGIC := '0';
    SIGNAL LCD_DATA_I : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL LCD_DATA_O : STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');

    constant TbPeriod : time := 1000 ns; -- EDIT put right period here
    signal TbClock : std_logic := '0';

begin
  
  LCD_DATA_GEN : FOR i IN 0 TO 7 GENERATE
    iobuff : alt_iobuf 
      GENERIC MAP( 
        WEAK_PULL_UP_RESISTOR => "ON" 
        ) 
      PORT MAP( 
        i => LCD_DATA_I(i), 
        oe => LCD_DATA_OE, 
        io => LCD_DATA(i), 
        o => LCD_DATA_O(i) 
        );  
  END GENERATE; 
  
  LCD_DATA_OE <= LCD_RW;

    dut : LCD16x2
    generic map (CLK_PERIOD_NS => 100)
    port map (CLK         => CLK,
              RST         => RST,
              ADA_DATA_IN => ADA_DATA_IN,
              ADA_DATA_EN => ADA_DATA_EN,
              ADB_DATA_IN => ADB_DATA_IN,
              ADB_DATA_EN => ADB_DATA_EN,
              LCD_DATA    => LCD_DATA,
              LCD_EN      => LCD_EN,
              LCD_ON      => LCD_ON,
              LCD_RS      => LCD_RS,
              LCD_RW      => LCD_RW);

    TbClock <= not TbClock after TbPeriod/2;

    -- EDIT: Check that CLK is really your main clock signal
    CLK <= TbClock;

    stimuli : process
    begin
        RST <= '1';
        ADA_DATA_IN <= x"11";
        ADA_DATA_EN <= '0';
        ADB_DATA_IN <= x"12";
        ADB_DATA_EN <= '0';
        wait for TbPeriod*10;
        RST <= '0';
        ADA_DATA_IN <= x"12";
        ADA_DATA_EN <= '0';
        ADB_DATA_IN <= x"13";
        ADB_DATA_EN <= '0';
        wait for TbPeriod*1000;
        ADA_DATA_EN <= '1';
        ADB_DATA_EN <= '1';
        wait for TbPeriod*1;
        ADA_DATA_EN <= '0';
        ADB_DATA_EN <= '0';
        
        wait;
    end process;

end tb;