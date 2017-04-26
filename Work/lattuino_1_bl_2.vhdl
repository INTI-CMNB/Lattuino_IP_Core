------------------------------------------------------------------------------
----                                                                      ----
----  Single Port RAM that maps to a Xilinx/Lattice BRAM                  ----
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

entity lattuino_1_blPM_2 is
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
end entity lattuino_1_blPM_2;

architecture Xilinx of lattuino_1_blPM_2 is
   constant ROM_SIZE : natural:=2**ADDR_W;
   type rom_t is array(natural range 0 to ROM_SIZE-1) of std_logic_vector(WORD_SIZE-1 downto 0);
   signal addr_r  : std_logic_vector(ADDR_W-1 downto 0);

   signal rom : rom_t :=
(
   696 => x"c00e",
   697 => x"c01b",
   698 => x"c01a",
   699 => x"c019",
   700 => x"c018",
   701 => x"c017",
   702 => x"c016",
   703 => x"c015",
   704 => x"c014",
   705 => x"c013",
   706 => x"c012",
   707 => x"c011",
   708 => x"c010",
   709 => x"c00f",
   710 => x"c00e",
   711 => x"2411",
   712 => x"be1f",
   713 => x"edcf",
   714 => x"bfcd",
   715 => x"e020",
   716 => x"e6a0",
   717 => x"e0b0",
   718 => x"c001",
   719 => x"921d",
   720 => x"36a5",
   721 => x"07b2",
   722 => x"f7e1",
   723 => x"d036",
   724 => x"c125",
   725 => x"cfe2",
   726 => x"e081",
   727 => x"bb8f",
   728 => x"e681",
   729 => x"ee93",
   730 => x"e1a6",
   731 => x"e0b0",
   732 => x"99f1",
   733 => x"c00a",
   734 => x"9701",
   735 => x"09a1",
   736 => x"09b1",
   737 => x"9700",
   738 => x"05a1",
   739 => x"05b1",
   740 => x"f7b9",
   741 => x"e0e0",
   742 => x"e0f0",
   743 => x"9509",
   744 => x"ba1f",
   745 => x"b38e",
   746 => x"9508",
   747 => x"e091",
   748 => x"bb9f",
   749 => x"9bf0",
   750 => x"cffe",
   751 => x"ba1f",
   752 => x"bb8e",
   753 => x"e080",
   754 => x"e090",
   755 => x"9508",
   756 => x"dfe1",
   757 => x"3280",
   758 => x"f421",
   759 => x"e184",
   760 => x"dff2",
   761 => x"e180",
   762 => x"cff0",
   763 => x"9508",
   764 => x"93cf",
   765 => x"2fc8",
   766 => x"dfd7",
   767 => x"3280",
   768 => x"f439",
   769 => x"e184",
   770 => x"dfe8",
   771 => x"2f8c",
   772 => x"dfe6",
   773 => x"e180",
   774 => x"91cf",
   775 => x"cfe3",
   776 => x"91cf",
   777 => x"9508",
   778 => x"9abe",
   779 => x"e044",
   780 => x"e450",
   781 => x"e020",
   782 => x"e030",
   783 => x"b388",
   784 => x"2785",
   785 => x"bb88",
   786 => x"01c9",
   787 => x"9701",
   788 => x"f7f1",
   789 => x"5041",
   790 => x"f7c1",
   791 => x"e011",
   792 => x"dfbd",
   793 => x"3380",
   794 => x"f0c9",
   795 => x"3381",
   796 => x"f499",
   797 => x"dfb8",
   798 => x"3280",
   799 => x"f7c1",
   800 => x"e184",
   801 => x"dfc9",
   802 => x"e481",
   803 => x"dfc7",
   804 => x"e586",
   805 => x"dfc5",
   806 => x"e582",
   807 => x"dfc3",
   808 => x"e280",
   809 => x"dfc1",
   810 => x"e489",
   811 => x"dfbf",
   812 => x"e583",
   813 => x"dfbd",
   814 => x"e580",
   815 => x"c0c2",
   816 => x"3480",
   817 => x"f421",
   818 => x"dfa3",
   819 => x"dfa2",
   820 => x"dfbf",
   821 => x"cfe2",
   822 => x"3481",
   823 => x"f469",
   824 => x"df9d",
   825 => x"3880",
   826 => x"f411",
   827 => x"e082",
   828 => x"c029",
   829 => x"3881",
   830 => x"f411",
   831 => x"e081",
   832 => x"c025",
   833 => x"3882",
   834 => x"f511",
   835 => x"e182",
   836 => x"c021",
   837 => x"3482",
   838 => x"f429",
   839 => x"e1c4",
   840 => x"df8d",
   841 => x"50c1",
   842 => x"f7e9",
   843 => x"cfe8",
   844 => x"3485",
   845 => x"f421",
   846 => x"df87",
   847 => x"df86",
   848 => x"df85",
   849 => x"cfe0",
   850 => x"eb90",
   851 => x"0f98",
   852 => x"3093",
   853 => x"f2f0",
   854 => x"3585",
   855 => x"f439",
   856 => x"df7d",
   857 => x"9380",
   858 => x"0063",
   859 => x"df7a",
   860 => x"9380",
   861 => x"0064",
   862 => x"cfd5",
   863 => x"3586",
   864 => x"f439",
   865 => x"df74",
   866 => x"df73",
   867 => x"df72",
   868 => x"df71",
   869 => x"e080",
   870 => x"df95",
   871 => x"cfb0",
   872 => x"3684",
   873 => x"f009",
   874 => x"c039",
   875 => x"df6a",
   876 => x"9380",
   877 => x"0062",
   878 => x"df67",
   879 => x"9380",
   880 => x"0061",
   881 => x"9210",
   882 => x"0060",
   883 => x"df62",
   884 => x"3485",
   885 => x"f419",
   886 => x"9310",
   887 => x"0060",
   888 => x"c00a",
   889 => x"9180",
   890 => x"0063",
   891 => x"9190",
   892 => x"0064",
   893 => x"0f88",
   894 => x"1f99",
   895 => x"9390",
   896 => x"0064",
   897 => x"9380",
   898 => x"0063",
   899 => x"e0c0",
   900 => x"e0d0",
   901 => x"9180",
   902 => x"0061",
   903 => x"9190",
   904 => x"0062",
   905 => x"17c8",
   906 => x"07d9",
   907 => x"f008",
   908 => x"cfa7",
   909 => x"df48",
   910 => x"2f08",
   911 => x"df46",
   912 => x"9190",
   913 => x"0060",
   914 => x"91e0",
   915 => x"0063",
   916 => x"91f0",
   917 => x"0064",
   918 => x"1191",
   919 => x"c005",
   920 => x"921f",
   921 => x"2e00",
   922 => x"2e18",
   923 => x"95e8",
   924 => x"901f",
   925 => x"9632",
   926 => x"93f0",
   927 => x"0064",
   928 => x"93e0",
   929 => x"0063",
   930 => x"9622",
   931 => x"cfe1",
   932 => x"3784",
   933 => x"f009",
   934 => x"c03e",
   935 => x"df2e",
   936 => x"9380",
   937 => x"0062",
   938 => x"df2b",
   939 => x"9380",
   940 => x"0061",
   941 => x"9210",
   942 => x"0060",
   943 => x"df26",
   944 => x"3485",
   945 => x"f419",
   946 => x"9310",
   947 => x"0060",
   948 => x"c00a",
   949 => x"9180",
   950 => x"0063",
   951 => x"9190",
   952 => x"0064",
   953 => x"0f88",
   954 => x"1f99",
   955 => x"9390",
   956 => x"0064",
   957 => x"9380",
   958 => x"0063",
   959 => x"df16",
   960 => x"3280",
   961 => x"f009",
   962 => x"cf55",
   963 => x"e184",
   964 => x"df26",
   965 => x"e0c0",
   966 => x"e0d0",
   967 => x"9180",
   968 => x"0061",
   969 => x"9190",
   970 => x"0062",
   971 => x"17c8",
   972 => x"07d9",
   973 => x"f528",
   974 => x"9180",
   975 => x"0060",
   976 => x"2388",
   977 => x"f011",
   978 => x"e080",
   979 => x"c005",
   980 => x"91e0",
   981 => x"0063",
   982 => x"91f0",
   983 => x"0064",
   984 => x"9184",
   985 => x"df11",
   986 => x"9180",
   987 => x"0063",
   988 => x"9190",
   989 => x"0064",
   990 => x"9601",
   991 => x"9390",
   992 => x"0064",
   993 => x"9380",
   994 => x"0063",
   995 => x"9621",
   996 => x"cfe2",
   997 => x"3785",
   998 => x"f479",
   999 => x"deee",
  1000 => x"3280",
  1001 => x"f009",
  1002 => x"cf2d",
  1003 => x"e184",
  1004 => x"defe",
  1005 => x"e18e",
  1006 => x"defc",
  1007 => x"e981",
  1008 => x"defa",
  1009 => x"e088",
  1010 => x"def8",
  1011 => x"e180",
  1012 => x"def6",
  1013 => x"cf22",
  1014 => x"3786",
  1015 => x"f009",
  1016 => x"cf1f",
  1017 => x"cf6b",
  1018 => x"94f8",
  1019 => x"cfff",
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

end architecture Xilinx; -- Entity: lattuino_1_blPM_2

