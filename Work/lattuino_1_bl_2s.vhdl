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
   696 => x"c002",
   697 => x"c00f",
   698 => x"c00e",
   699 => x"2411",
   700 => x"be1f",
   701 => x"edcf",
   702 => x"bfcd",
   703 => x"e020",
   704 => x"e6a0",
   705 => x"e0b0",
   706 => x"c001",
   707 => x"921d",
   708 => x"36a5",
   709 => x"07b2",
   710 => x"f7e1",
   711 => x"d036",
   712 => x"c127",
   713 => x"cfee",
   714 => x"e081",
   715 => x"bb8f",
   716 => x"e681",
   717 => x"ee93",
   718 => x"e1a6",
   719 => x"e0b0",
   720 => x"99f1",
   721 => x"c00a",
   722 => x"9701",
   723 => x"09a1",
   724 => x"09b1",
   725 => x"9700",
   726 => x"05a1",
   727 => x"05b1",
   728 => x"f7b9",
   729 => x"e0e0",
   730 => x"e0f0",
   731 => x"9509",
   732 => x"ba1f",
   733 => x"b38e",
   734 => x"9508",
   735 => x"e091",
   736 => x"bb9f",
   737 => x"9bf0",
   738 => x"cffe",
   739 => x"ba1f",
   740 => x"bb8e",
   741 => x"e080",
   742 => x"e090",
   743 => x"9508",
   744 => x"dfe1",
   745 => x"3280",
   746 => x"f421",
   747 => x"e184",
   748 => x"dff2",
   749 => x"e180",
   750 => x"cff0",
   751 => x"9508",
   752 => x"93cf",
   753 => x"2fc8",
   754 => x"dfd7",
   755 => x"3280",
   756 => x"f439",
   757 => x"e184",
   758 => x"dfe8",
   759 => x"2f8c",
   760 => x"dfe6",
   761 => x"e180",
   762 => x"91cf",
   763 => x"cfe3",
   764 => x"91cf",
   765 => x"9508",
   766 => x"9abe",
   767 => x"e044",
   768 => x"e450",
   769 => x"e020",
   770 => x"e030",
   771 => x"b388",
   772 => x"2785",
   773 => x"bb88",
   774 => x"2f82",
   775 => x"2f93",
   776 => x"9701",
   777 => x"f7f1",
   778 => x"5041",
   779 => x"f7b9",
   780 => x"e011",
   781 => x"dfbc",
   782 => x"3380",
   783 => x"f0c9",
   784 => x"3381",
   785 => x"f499",
   786 => x"dfb7",
   787 => x"3280",
   788 => x"f7c1",
   789 => x"e184",
   790 => x"dfc8",
   791 => x"e481",
   792 => x"dfc6",
   793 => x"e586",
   794 => x"dfc4",
   795 => x"e582",
   796 => x"dfc2",
   797 => x"e280",
   798 => x"dfc0",
   799 => x"e489",
   800 => x"dfbe",
   801 => x"e583",
   802 => x"dfbc",
   803 => x"e580",
   804 => x"c0c3",
   805 => x"3480",
   806 => x"f421",
   807 => x"dfa2",
   808 => x"dfa1",
   809 => x"dfbe",
   810 => x"cfe2",
   811 => x"3481",
   812 => x"f469",
   813 => x"df9c",
   814 => x"3880",
   815 => x"f411",
   816 => x"e082",
   817 => x"c029",
   818 => x"3881",
   819 => x"f411",
   820 => x"e081",
   821 => x"c025",
   822 => x"3882",
   823 => x"f511",
   824 => x"e182",
   825 => x"c021",
   826 => x"3482",
   827 => x"f429",
   828 => x"e1c4",
   829 => x"df8c",
   830 => x"50c1",
   831 => x"f7e9",
   832 => x"cfe8",
   833 => x"3485",
   834 => x"f421",
   835 => x"df86",
   836 => x"df85",
   837 => x"df84",
   838 => x"cfe0",
   839 => x"eb90",
   840 => x"0f98",
   841 => x"3093",
   842 => x"f2f0",
   843 => x"3585",
   844 => x"f439",
   845 => x"df7c",
   846 => x"9380",
   847 => x"0063",
   848 => x"df79",
   849 => x"9380",
   850 => x"0064",
   851 => x"cfd5",
   852 => x"3586",
   853 => x"f439",
   854 => x"df73",
   855 => x"df72",
   856 => x"df71",
   857 => x"df70",
   858 => x"e080",
   859 => x"df94",
   860 => x"cfb0",
   861 => x"3684",
   862 => x"f009",
   863 => x"c039",
   864 => x"df69",
   865 => x"9380",
   866 => x"0062",
   867 => x"df66",
   868 => x"9380",
   869 => x"0061",
   870 => x"9210",
   871 => x"0060",
   872 => x"df61",
   873 => x"3485",
   874 => x"f419",
   875 => x"9310",
   876 => x"0060",
   877 => x"c00a",
   878 => x"9180",
   879 => x"0063",
   880 => x"9190",
   881 => x"0064",
   882 => x"0f88",
   883 => x"1f99",
   884 => x"9390",
   885 => x"0064",
   886 => x"9380",
   887 => x"0063",
   888 => x"e0c0",
   889 => x"e0d0",
   890 => x"9180",
   891 => x"0061",
   892 => x"9190",
   893 => x"0062",
   894 => x"17c8",
   895 => x"07d9",
   896 => x"f008",
   897 => x"cfa7",
   898 => x"df47",
   899 => x"2f08",
   900 => x"df45",
   901 => x"9190",
   902 => x"0060",
   903 => x"91e0",
   904 => x"0063",
   905 => x"91f0",
   906 => x"0064",
   907 => x"1191",
   908 => x"c005",
   909 => x"921f",
   910 => x"2e00",
   911 => x"2e18",
   912 => x"95e8",
   913 => x"901f",
   914 => x"9632",
   915 => x"93f0",
   916 => x"0064",
   917 => x"93e0",
   918 => x"0063",
   919 => x"9622",
   920 => x"cfe1",
   921 => x"3784",
   922 => x"f009",
   923 => x"c03f",
   924 => x"df2d",
   925 => x"9380",
   926 => x"0062",
   927 => x"df2a",
   928 => x"9380",
   929 => x"0061",
   930 => x"9210",
   931 => x"0060",
   932 => x"df25",
   933 => x"3485",
   934 => x"f419",
   935 => x"9310",
   936 => x"0060",
   937 => x"c00a",
   938 => x"9180",
   939 => x"0063",
   940 => x"9190",
   941 => x"0064",
   942 => x"0f88",
   943 => x"1f99",
   944 => x"9390",
   945 => x"0064",
   946 => x"9380",
   947 => x"0063",
   948 => x"df15",
   949 => x"3280",
   950 => x"f009",
   951 => x"cf55",
   952 => x"e184",
   953 => x"df25",
   954 => x"e0c0",
   955 => x"e0d0",
   956 => x"9180",
   957 => x"0061",
   958 => x"9190",
   959 => x"0062",
   960 => x"17c8",
   961 => x"07d9",
   962 => x"f530",
   963 => x"9180",
   964 => x"0060",
   965 => x"2388",
   966 => x"f011",
   967 => x"e080",
   968 => x"c006",
   969 => x"91e0",
   970 => x"0063",
   971 => x"91f0",
   972 => x"0064",
   973 => x"95c8",
   974 => x"2d80",
   975 => x"df0f",
   976 => x"9180",
   977 => x"0063",
   978 => x"9190",
   979 => x"0064",
   980 => x"9601",
   981 => x"9390",
   982 => x"0064",
   983 => x"9380",
   984 => x"0063",
   985 => x"9621",
   986 => x"cfe1",
   987 => x"3785",
   988 => x"f479",
   989 => x"deec",
   990 => x"3280",
   991 => x"f009",
   992 => x"cf2c",
   993 => x"e184",
   994 => x"defc",
   995 => x"e18e",
   996 => x"defa",
   997 => x"e981",
   998 => x"def8",
   999 => x"e086",
  1000 => x"def6",
  1001 => x"e180",
  1002 => x"def4",
  1003 => x"cf21",
  1004 => x"3786",
  1005 => x"f009",
  1006 => x"cf1e",
  1007 => x"cf6a",
  1008 => x"94f8",
  1009 => x"cfff",
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

