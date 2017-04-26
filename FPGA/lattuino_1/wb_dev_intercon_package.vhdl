
library IEEE;
use IEEE.std_logic_1164.all;

package WBDevInterconPkg is

   component WBDevIntercon is
      port(
         -- wishbone master port(s)
         -- cpu
         cpu_dat_o : out std_logic_vector(7 downto 0);
         cpu_ack_o : out std_logic;
         cpu_dat_i : in  std_logic_vector(7 downto 0);
         cpu_we_i  : in  std_logic;
         cpu_adr_i : in  std_logic_vector(7 downto 0);
         cpu_cyc_i : in  std_logic;
         cpu_stb_i : in  std_logic;
         -- wishbone slave port(s)
         -- rs2
         rs2_dat_i : in  std_logic_vector(7 downto 0);
         rs2_ack_i : in  std_logic;
         rs2_dat_o : out std_logic_vector(7 downto 0);
         rs2_we_o  : out std_logic;
         rs2_adr_o : out std_logic_vector(0 downto 0);
         rs2_stb_o : out std_logic;
         -- ad
         ad_dat_i : in  std_logic_vector(7 downto 0);
         ad_ack_i : in  std_logic;
         ad_dat_o : out std_logic_vector(7 downto 0);
         ad_we_o  : out std_logic;
         ad_adr_o : out std_logic_vector(0 downto 0);
         ad_stb_o : out std_logic;
         -- tmr
         tmr_dat_i : in  std_logic_vector(7 downto 0);
         tmr_ack_i : in  std_logic;
         tmr_dat_o : out std_logic_vector(7 downto 0);
         tmr_we_o  : out std_logic;
         tmr_adr_o : out std_logic_vector(2 downto 0);
         tmr_stb_o : out std_logic;
         -- t16
         t16_dat_i : in  std_logic_vector(7 downto 0);
         t16_ack_i : in  std_logic;
         t16_dat_o : out std_logic_vector(7 downto 0);
         t16_we_o  : out std_logic;
         t16_adr_o : out std_logic_vector(0 downto 0);
         t16_stb_o : out std_logic;
         -- clock and reset
         wb_clk_i  : in std_logic;
         wb_rst_i  : in std_logic);
   end component WBDevIntercon;

end package WBDevInterconPkg;

-- Instantiation example:
-- library IEEE;
-- use IEEE.std_logic_1164.all;
-- use work.WBDevInterconPkg.all;
-- 
--    -- signals:
--    -- cpu
--    signal cpu_dati  : std_logic_vector(7 downto 0);
--    signal cpu_acki  : std_logic;
--    signal cpu_dato  : std_logic_vector(7 downto 0);
--    signal cpu_weo   : std_logic;
--    signal cpu_adro  : std_logic_vector(7 downto 0);
--    signal cpu_cyco  : std_logic;
--    signal cpu_stbo  : std_logic;
--    -- rs2
--    signal rs2_dato  : std_logic_vector(7 downto 0);
--    signal rs2_acko  : std_logic;
--    signal rs2_dati  : std_logic_vector(7 downto 0);
--    signal rs2_wei   : std_logic;
--    signal rs2_adri  : std_logic_vector(0 downto 0);
--    signal rs2_stbi  : std_logic;
--    -- ad
--    signal ad_dato  : std_logic_vector(7 downto 0);
--    signal ad_acko  : std_logic;
--    signal ad_dati  : std_logic_vector(7 downto 0);
--    signal ad_wei   : std_logic;
--    signal ad_adri  : std_logic_vector(0 downto 0);
--    signal ad_stbi  : std_logic;
--    -- tmr
--    signal tmr_dato  : std_logic_vector(7 downto 0);
--    signal tmr_acko  : std_logic;
--    signal tmr_dati  : std_logic_vector(7 downto 0);
--    signal tmr_wei   : std_logic;
--    signal tmr_adri  : std_logic_vector(2 downto 0);
--    signal tmr_stbi  : std_logic;
--    -- t16
--    signal t16_dato  : std_logic_vector(7 downto 0);
--    signal t16_acko  : std_logic;
--    signal t16_dati  : std_logic_vector(7 downto 0);
--    signal t16_wei   : std_logic;
--    signal t16_adri  : std_logic_vector(0 downto 0);
--    signal t16_stbi  : std_logic;
-- 
-- intercon: WBDevIntercon
--    port map(
--       -- wishbone master port(s)
--       -- cpu
--       cpu_dat_o => cpu_dati,
--       cpu_ack_o => cpu_acki,
--       cpu_dat_i => cpu_dato,
--       cpu_we_i  => cpu_weo,
--       cpu_adr_i => cpu_adro,
--       cpu_cyc_i => cpu_cyco,
--       cpu_stb_i => cpu_stbo,
--       -- wishbone slave port(s)
--       -- rs2
--       rs2_dat_i => rs2_dato,
--       rs2_ack_i => rs2_acko,
--       rs2_dat_o => rs2_dati,
--       rs2_we_o  => rs2_wei,
--       rs2_adr_o => rs2_adri,
--       rs2_stb_o => rs2_stbi,
--       -- ad
--       ad_dat_i => ad_dato,
--       ad_ack_i => ad_acko,
--       ad_dat_o => ad_dati,
--       ad_we_o  => ad_wei,
--       ad_adr_o => ad_adri,
--       ad_stb_o => ad_stbi,
--       -- tmr
--       tmr_dat_i => tmr_dato,
--       tmr_ack_i => tmr_acko,
--       tmr_dat_o => tmr_dati,
--       tmr_we_o  => tmr_wei,
--       tmr_adr_o => tmr_adri,
--       tmr_stb_o => tmr_stbi,
--       -- t16
--       t16_dat_i => t16_dato,
--       t16_ack_i => t16_acko,
--       t16_dat_o => t16_dati,
--       t16_we_o  => t16_wei,
--       t16_adr_o => t16_adri,
--       t16_stb_o => t16_stbi,
--       -- clock and reset
--       wb_clk_i => wb_clk_o,
--       wb_rst_i => wb_rst_o);
