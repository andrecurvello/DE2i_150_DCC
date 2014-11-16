library ieee;
use ieee.std_logic_1164.all;

entity tb_LCD16x2 is
end tb_LCD16x2;

architecture tb of tb_LCD16x2 is

    component LCD16x2
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

    constant TbPeriod : time := 1000 ns; -- EDIT put right period here
    signal TbClock : std_logic := '0';

begin

    dut : LCD16x2
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
        -- EDIT
        wait;
    end process;

end tb;

configuration cfg_tb_LCD16x2 of tb_LCD16x2 is
    for tb
    end for;
end cfg_tb_LCD16x2;
