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

entity lattuino_1_blPM_2S is
   generic(
      WORD_SIZE  : integer:=16;  -- Word Size
      FALL_EDGE  : boolean:=false;-- Ram clock falling edge
      ADDR_W     : integer:=13); -- Address Width
   port(
      clk_i   : in  std_logic;
      addr_i  : in  std_logic_vector(ADDR_W-1 downto 0);
      data_o  : out std_logic_vector(WORD_SIZE-1 downto 0);
      we_i    : in  std_logic;
      data_i  : in  std_logic_vector(WORD_SIZE-1 downto 0));
end entity lattuino_1_blPM_2S;

architecture Xilinx of lattuino_1_blPM_2S is
   constant ROM_SIZE : natural:=2**ADDR_W;
   type rom_t is array(natural range 0 to ROM_SIZE-1) of std_logic_vector(WORD_SIZE-1 downto 0);
   signal addr_r  : std_logic_vector(ADDR_W-1 downto 0);

   signal rom : rom_t :=
(
   696 => x"c00b",
   697 => x"c018",
   698 => x"c017",
   699 => x"c016",
   700 => x"c015",
   701 => x"c014",
   702 => x"c013",
   703 => x"c012",
   704 => x"c011",
   705 => x"c010",
   706 => x"c00f",
   707 => x"c00e",
   708 => x"2411",
   709 => x"be1f",
   710 => x"edcf",
   711 => x"bfcd",
   712 => x"e020",
   713 => x"e6a0",
   714 => x"e0b0",
   715 => x"c001",
   716 => x"921d",
   717 => x"36a5",
   718 => x"07b2",
   719 => x"f7e1",
   720 => x"d036",
   721 => x"c127",
   722 => x"cfe5",
   723 => x"e081",
   724 => x"bb8f",
   725 => x"e681",
   726 => x"ee93",
   727 => x"e1a6",
   728 => x"e0b0",
   729 => x"99f1",
   730 => x"c00a",
   731 => x"9701",
   732 => x"09a1",
   733 => x"09b1",
   734 => x"9700",
   735 => x"05a1",
   736 => x"05b1",
   737 => x"f7b9",
   738 => x"e0e0",
   739 => x"e0f0",
   740 => x"9509",
   741 => x"ba1f",
   742 => x"b38e",
   743 => x"9508",
   744 => x"e091",
   745 => x"bb9f",
   746 => x"9bf0",
   747 => x"cffe",
   748 => x"ba1f",
   749 => x"bb8e",
   750 => x"e080",
   751 => x"e090",
   752 => x"9508",
   753 => x"dfe1",
   754 => x"3280",
   755 => x"f421",
   756 => x"e184",
   757 => x"dff2",
   758 => x"e180",
   759 => x"cff0",
   760 => x"9508",
   761 => x"93cf",
   762 => x"2fc8",
   763 => x"dfd7",
   764 => x"3280",
   765 => x"f439",
   766 => x"e184",
   767 => x"dfe8",
   768 => x"2f8c",
   769 => x"dfe6",
   770 => x"e180",
   771 => x"91cf",
   772 => x"cfe3",
   773 => x"91cf",
   774 => x"9508",
   775 => x"9abe",
   776 => x"e044",
   777 => x"e450",
   778 => x"e020",
   779 => x"e030",
   780 => x"b388",
   781 => x"2785",
   782 => x"bb88",
   783 => x"2f82",
   784 => x"2f93",
   785 => x"9701",
   786 => x"f7f1",
   787 => x"5041",
   788 => x"f7b9",
   789 => x"e011",
   790 => x"dfbc",
   791 => x"3380",
   792 => x"f0c9",
   793 => x"3381",
   794 => x"f499",
   795 => x"dfb7",
   796 => x"3280",
   797 => x"f7c1",
   798 => x"e184",
   799 => x"dfc8",
   800 => x"e481",
   801 => x"dfc6",
   802 => x"e586",
   803 => x"dfc4",
   804 => x"e582",
   805 => x"dfc2",
   806 => x"e280",
   807 => x"dfc0",
   808 => x"e489",
   809 => x"dfbe",
   810 => x"e583",
   811 => x"dfbc",
   812 => x"e580",
   813 => x"c0c3",
   814 => x"3480",
   815 => x"f421",
   816 => x"dfa2",
   817 => x"dfa1",
   818 => x"dfbe",
   819 => x"cfe2",
   820 => x"3481",
   821 => x"f469",
   822 => x"df9c",
   823 => x"3880",
   824 => x"f411",
   825 => x"e082",
   826 => x"c029",
   827 => x"3881",
   828 => x"f411",
   829 => x"e081",
   830 => x"c025",
   831 => x"3882",
   832 => x"f511",
   833 => x"e182",
   834 => x"c021",
   835 => x"3482",
   836 => x"f429",
   837 => x"e1c4",
   838 => x"df8c",
   839 => x"50c1",
   840 => x"f7e9",
   841 => x"cfe8",
   842 => x"3485",
   843 => x"f421",
   844 => x"df86",
   845 => x"df85",
   846 => x"df84",
   847 => x"cfe0",
   848 => x"eb90",
   849 => x"0f98",
   850 => x"3093",
   851 => x"f2f0",
   852 => x"3585",
   853 => x"f439",
   854 => x"df7c",
   855 => x"9380",
   856 => x"0063",
   857 => x"df79",
   858 => x"9380",
   859 => x"0064",
   860 => x"cfd5",
   861 => x"3586",
   862 => x"f439",
   863 => x"df73",
   864 => x"df72",
   865 => x"df71",
   866 => x"df70",
   867 => x"e080",
   868 => x"df94",
   869 => x"cfb0",
   870 => x"3684",
   871 => x"f009",
   872 => x"c039",
   873 => x"df69",
   874 => x"9380",
   875 => x"0062",
   876 => x"df66",
   877 => x"9380",
   878 => x"0061",
   879 => x"9210",
   880 => x"0060",
   881 => x"df61",
   882 => x"3485",
   883 => x"f419",
   884 => x"9310",
   885 => x"0060",
   886 => x"c00a",
   887 => x"9180",
   888 => x"0063",
   889 => x"9190",
   890 => x"0064",
   891 => x"0f88",
   892 => x"1f99",
   893 => x"9390",
   894 => x"0064",
   895 => x"9380",
   896 => x"0063",
   897 => x"e0c0",
   898 => x"e0d0",
   899 => x"9180",
   900 => x"0061",
   901 => x"9190",
   902 => x"0062",
   903 => x"17c8",
   904 => x"07d9",
   905 => x"f008",
   906 => x"cfa7",
   907 => x"df47",
   908 => x"2f08",
   909 => x"df45",
   910 => x"9190",
   911 => x"0060",
   912 => x"91e0",
   913 => x"0063",
   914 => x"91f0",
   915 => x"0064",
   916 => x"1191",
   917 => x"c005",
   918 => x"921f",
   919 => x"2e00",
   920 => x"2e18",
   921 => x"95e8",
   922 => x"901f",
   923 => x"9632",
   924 => x"93f0",
   925 => x"0064",
   926 => x"93e0",
   927 => x"0063",
   928 => x"9622",
   929 => x"cfe1",
   930 => x"3784",
   931 => x"f009",
   932 => x"c03f",
   933 => x"df2d",
   934 => x"9380",
   935 => x"0062",
   936 => x"df2a",
   937 => x"9380",
   938 => x"0061",
   939 => x"9210",
   940 => x"0060",
   941 => x"df25",
   942 => x"3485",
   943 => x"f419",
   944 => x"9310",
   945 => x"0060",
   946 => x"c00a",
   947 => x"9180",
   948 => x"0063",
   949 => x"9190",
   950 => x"0064",
   951 => x"0f88",
   952 => x"1f99",
   953 => x"9390",
   954 => x"0064",
   955 => x"9380",
   956 => x"0063",
   957 => x"df15",
   958 => x"3280",
   959 => x"f009",
   960 => x"cf55",
   961 => x"e184",
   962 => x"df25",
   963 => x"e0c0",
   964 => x"e0d0",
   965 => x"9180",
   966 => x"0061",
   967 => x"9190",
   968 => x"0062",
   969 => x"17c8",
   970 => x"07d9",
   971 => x"f530",
   972 => x"9180",
   973 => x"0060",
   974 => x"2388",
   975 => x"f011",
   976 => x"e080",
   977 => x"c006",
   978 => x"91e0",
   979 => x"0063",
   980 => x"91f0",
   981 => x"0064",
   982 => x"95c8",
   983 => x"2d80",
   984 => x"df0f",
   985 => x"9180",
   986 => x"0063",
   987 => x"9190",
   988 => x"0064",
   989 => x"9601",
   990 => x"9390",
   991 => x"0064",
   992 => x"9380",
   993 => x"0063",
   994 => x"9621",
   995 => x"cfe1",
   996 => x"3785",
   997 => x"f479",
   998 => x"deec",
   999 => x"3280",
  1000 => x"f009",
  1001 => x"cf2c",
  1002 => x"e184",
  1003 => x"defc",
  1004 => x"e18e",
  1005 => x"defa",
  1006 => x"e981",
  1007 => x"def8",
  1008 => x"e089",
  1009 => x"def6",
  1010 => x"e180",
  1011 => x"def4",
  1012 => x"cf21",
  1013 => x"3786",
  1014 => x"f009",
  1015 => x"cf1e",
  1016 => x"cf6a",
  1017 => x"94f8",
  1018 => x"cfff",
others => x"0000"

);
begin

   use_rising_edge:
   if not FALL_EDGE generate
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
  if FALL_EDGE generate
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

end architecture Xilinx; -- Entity: lattuino_1_blPM_2S

