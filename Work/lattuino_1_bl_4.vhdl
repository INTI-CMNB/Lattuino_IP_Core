------------------------------------------------------------------------------
----                                                                      ----
----  Single Port RAM that maps to a Xilinx/Lattice BRAM                  ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This is a program memory for the AVR. It maps to a Xilinx/Lattice   ----
----  BRAM.                                                               ----
----  This version can be modified by the CPU (i. e. SPM instruction)     ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2008-2017 Salvador E. Tropea <salvador inti.gob.ar>    ----
---- Copyright (c) 2008-2017 Instituto Nacional de Tecnología Industrial  ----
----                                                                      ----
---- Distributed under the BSD license                                    ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      SinglePortPM(Xilinx) (Entity and architecture)     ----
---- File name:        pm_s_rw.in.vhdl (template used)                    ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          work                                               ----
---- Dependencies:     IEEE.std_logic_1164                                ----
---- Target FPGA:      Spartan 3 (XC3S1500-4-FG456)                       ----
----                   iCE40 (iCE40HX4K)                                  ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Xilinx Release 9.2.03i - xst J.39                  ----
----                   iCEcube2.2016.02                                   ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lattuino_1_blPM_4 is
   generic(
      WORD_SIZE  : integer:=16;  -- Word Size
      FALL_EDGE  : std_logic:='0'; -- Ram clock falling edge
      ADDR_W     : integer:=13); -- Address Width
   port(
      clk_i   : in  std_logic;
      addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
      data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
      we_i    : in  std_logic;
      data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
end entity lattuino_1_blPM_4;

architecture Xilinx of lattuino_1_blPM_4 is
   constant ROM_SIZE : natural:=2**ADDR_W;
   type rom_t is array(natural range 0 to ROM_SIZE-1) of std_logic_vector(WORD_SIZE-1 downto 0);
   signal addr_r  : std_logic_vector(ADDR_W-1 downto 0);

   signal rom : rom_t :=
(
  1720 => x"c00e",
  1721 => x"c01d",
  1722 => x"c01c",
  1723 => x"c01b",
  1724 => x"c01a",
  1725 => x"c019",
  1726 => x"c018",
  1727 => x"c017",
  1728 => x"c016",
  1729 => x"c015",
  1730 => x"c014",
  1731 => x"c013",
  1732 => x"c012",
  1733 => x"c011",
  1734 => x"c010",
  1735 => x"2411",
  1736 => x"be1f",
  1737 => x"e5cf",
  1738 => x"e0d1",
  1739 => x"bfde",
  1740 => x"bfcd",
  1741 => x"e020",
  1742 => x"e6a0",
  1743 => x"e0b0",
  1744 => x"c001",
  1745 => x"921d",
  1746 => x"36a5",
  1747 => x"07b2",
  1748 => x"f7e1",
  1749 => x"d036",
  1750 => x"c125",
  1751 => x"cfe0",
  1752 => x"e081",
  1753 => x"bb8f",
  1754 => x"e681",
  1755 => x"ee93",
  1756 => x"e1a6",
  1757 => x"e0b0",
  1758 => x"99f1",
  1759 => x"c00a",
  1760 => x"9701",
  1761 => x"09a1",
  1762 => x"09b1",
  1763 => x"9700",
  1764 => x"05a1",
  1765 => x"05b1",
  1766 => x"f7b9",
  1767 => x"e0e0",
  1768 => x"e0f0",
  1769 => x"9509",
  1770 => x"ba1f",
  1771 => x"b38e",
  1772 => x"9508",
  1773 => x"e091",
  1774 => x"bb9f",
  1775 => x"9bf0",
  1776 => x"cffe",
  1777 => x"ba1f",
  1778 => x"bb8e",
  1779 => x"e080",
  1780 => x"e090",
  1781 => x"9508",
  1782 => x"dfe1",
  1783 => x"3280",
  1784 => x"f421",
  1785 => x"e184",
  1786 => x"dff2",
  1787 => x"e180",
  1788 => x"cff0",
  1789 => x"9508",
  1790 => x"93cf",
  1791 => x"2fc8",
  1792 => x"dfd7",
  1793 => x"3280",
  1794 => x"f439",
  1795 => x"e184",
  1796 => x"dfe8",
  1797 => x"2f8c",
  1798 => x"dfe6",
  1799 => x"e180",
  1800 => x"91cf",
  1801 => x"cfe3",
  1802 => x"91cf",
  1803 => x"9508",
  1804 => x"9abe",
  1805 => x"e044",
  1806 => x"e450",
  1807 => x"e020",
  1808 => x"e030",
  1809 => x"b388",
  1810 => x"2785",
  1811 => x"bb88",
  1812 => x"01c9",
  1813 => x"9701",
  1814 => x"f7f1",
  1815 => x"5041",
  1816 => x"f7c1",
  1817 => x"e011",
  1818 => x"dfbd",
  1819 => x"3380",
  1820 => x"f0c9",
  1821 => x"3381",
  1822 => x"f499",
  1823 => x"dfb8",
  1824 => x"3280",
  1825 => x"f7c1",
  1826 => x"e184",
  1827 => x"dfc9",
  1828 => x"e481",
  1829 => x"dfc7",
  1830 => x"e586",
  1831 => x"dfc5",
  1832 => x"e582",
  1833 => x"dfc3",
  1834 => x"e280",
  1835 => x"dfc1",
  1836 => x"e489",
  1837 => x"dfbf",
  1838 => x"e583",
  1839 => x"dfbd",
  1840 => x"e580",
  1841 => x"c0c2",
  1842 => x"3480",
  1843 => x"f421",
  1844 => x"dfa3",
  1845 => x"dfa2",
  1846 => x"dfbf",
  1847 => x"cfe2",
  1848 => x"3481",
  1849 => x"f469",
  1850 => x"df9d",
  1851 => x"3880",
  1852 => x"f411",
  1853 => x"e082",
  1854 => x"c029",
  1855 => x"3881",
  1856 => x"f411",
  1857 => x"e081",
  1858 => x"c025",
  1859 => x"3882",
  1860 => x"f511",
  1861 => x"e182",
  1862 => x"c021",
  1863 => x"3482",
  1864 => x"f429",
  1865 => x"e1c4",
  1866 => x"df8d",
  1867 => x"50c1",
  1868 => x"f7e9",
  1869 => x"cfe8",
  1870 => x"3485",
  1871 => x"f421",
  1872 => x"df87",
  1873 => x"df86",
  1874 => x"df85",
  1875 => x"cfe0",
  1876 => x"eb90",
  1877 => x"0f98",
  1878 => x"3093",
  1879 => x"f2f0",
  1880 => x"3585",
  1881 => x"f439",
  1882 => x"df7d",
  1883 => x"9380",
  1884 => x"0063",
  1885 => x"df7a",
  1886 => x"9380",
  1887 => x"0064",
  1888 => x"cfd5",
  1889 => x"3586",
  1890 => x"f439",
  1891 => x"df74",
  1892 => x"df73",
  1893 => x"df72",
  1894 => x"df71",
  1895 => x"e080",
  1896 => x"df95",
  1897 => x"cfb0",
  1898 => x"3684",
  1899 => x"f009",
  1900 => x"c039",
  1901 => x"df6a",
  1902 => x"9380",
  1903 => x"0062",
  1904 => x"df67",
  1905 => x"9380",
  1906 => x"0061",
  1907 => x"9210",
  1908 => x"0060",
  1909 => x"df62",
  1910 => x"3485",
  1911 => x"f419",
  1912 => x"9310",
  1913 => x"0060",
  1914 => x"c00a",
  1915 => x"9180",
  1916 => x"0063",
  1917 => x"9190",
  1918 => x"0064",
  1919 => x"0f88",
  1920 => x"1f99",
  1921 => x"9390",
  1922 => x"0064",
  1923 => x"9380",
  1924 => x"0063",
  1925 => x"e0c0",
  1926 => x"e0d0",
  1927 => x"9180",
  1928 => x"0061",
  1929 => x"9190",
  1930 => x"0062",
  1931 => x"17c8",
  1932 => x"07d9",
  1933 => x"f008",
  1934 => x"cfa7",
  1935 => x"df48",
  1936 => x"2f08",
  1937 => x"df46",
  1938 => x"9190",
  1939 => x"0060",
  1940 => x"91e0",
  1941 => x"0063",
  1942 => x"91f0",
  1943 => x"0064",
  1944 => x"1191",
  1945 => x"c005",
  1946 => x"921f",
  1947 => x"2e00",
  1948 => x"2e18",
  1949 => x"95e8",
  1950 => x"901f",
  1951 => x"9632",
  1952 => x"93f0",
  1953 => x"0064",
  1954 => x"93e0",
  1955 => x"0063",
  1956 => x"9622",
  1957 => x"cfe1",
  1958 => x"3784",
  1959 => x"f009",
  1960 => x"c03e",
  1961 => x"df2e",
  1962 => x"9380",
  1963 => x"0062",
  1964 => x"df2b",
  1965 => x"9380",
  1966 => x"0061",
  1967 => x"9210",
  1968 => x"0060",
  1969 => x"df26",
  1970 => x"3485",
  1971 => x"f419",
  1972 => x"9310",
  1973 => x"0060",
  1974 => x"c00a",
  1975 => x"9180",
  1976 => x"0063",
  1977 => x"9190",
  1978 => x"0064",
  1979 => x"0f88",
  1980 => x"1f99",
  1981 => x"9390",
  1982 => x"0064",
  1983 => x"9380",
  1984 => x"0063",
  1985 => x"df16",
  1986 => x"3280",
  1987 => x"f009",
  1988 => x"cf55",
  1989 => x"e184",
  1990 => x"df26",
  1991 => x"e0c0",
  1992 => x"e0d0",
  1993 => x"9180",
  1994 => x"0061",
  1995 => x"9190",
  1996 => x"0062",
  1997 => x"17c8",
  1998 => x"07d9",
  1999 => x"f528",
  2000 => x"9180",
  2001 => x"0060",
  2002 => x"2388",
  2003 => x"f011",
  2004 => x"e080",
  2005 => x"c005",
  2006 => x"91e0",
  2007 => x"0063",
  2008 => x"91f0",
  2009 => x"0064",
  2010 => x"9184",
  2011 => x"df11",
  2012 => x"9180",
  2013 => x"0063",
  2014 => x"9190",
  2015 => x"0064",
  2016 => x"9601",
  2017 => x"9390",
  2018 => x"0064",
  2019 => x"9380",
  2020 => x"0063",
  2021 => x"9621",
  2022 => x"cfe2",
  2023 => x"3785",
  2024 => x"f479",
  2025 => x"deee",
  2026 => x"3280",
  2027 => x"f009",
  2028 => x"cf2d",
  2029 => x"e184",
  2030 => x"defe",
  2031 => x"e18e",
  2032 => x"defc",
  2033 => x"e982",
  2034 => x"defa",
  2035 => x"e086",
  2036 => x"def8",
  2037 => x"e180",
  2038 => x"def6",
  2039 => x"cf22",
  2040 => x"3786",
  2041 => x"f009",
  2042 => x"cf1f",
  2043 => x"cf6b",
  2044 => x"94f8",
  2045 => x"cfff",
others => x"0000"

);
begin

   use_rising_edge:
   if FALL_EDGE='0' generate
      do_rom:
      process (clk_i)
      begin
         if rising_edge(clk_i)then
            addr_r <= addr_i;
            if we_i='1' then
               rom(to_integer(unsigned(addr_i))) <= data_i;
            end if;
         end if;
      end process do_rom;
  end generate use_rising_edge;

  use_falling_edge:
  if FALL_EDGE='1' generate
      do_rom:
      process (clk_i)
      begin
         if falling_edge(clk_i)then
            addr_r <= addr_i;
            if we_i='1' then
               rom(to_integer(unsigned(addr_i))) <= data_i;
            end if;
         end if;
      end process do_rom;
  end generate use_falling_edge;

  data_o <= rom(to_integer(unsigned(addr_r)));

end architecture Xilinx; -- Entity: lattuino_1_blPM_4

