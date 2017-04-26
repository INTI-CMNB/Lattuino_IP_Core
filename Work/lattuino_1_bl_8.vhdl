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

entity lattuino_1_blPM_8 is
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
end entity lattuino_1_blPM_8;

architecture Xilinx of lattuino_1_blPM_8 is
   constant ROM_SIZE : natural:=2**ADDR_W;
   type rom_t is array(natural range 0 to ROM_SIZE-1) of std_logic_vector(WORD_SIZE-1 downto 0);
   signal addr_r  : std_logic_vector(ADDR_W-1 downto 0);

   signal rom : rom_t :=
(
  3768 => x"c00e",
  3769 => x"c01d",
  3770 => x"c01c",
  3771 => x"c01b",
  3772 => x"c01a",
  3773 => x"c019",
  3774 => x"c018",
  3775 => x"c017",
  3776 => x"c016",
  3777 => x"c015",
  3778 => x"c014",
  3779 => x"c013",
  3780 => x"c012",
  3781 => x"c011",
  3782 => x"c010",
  3783 => x"2411",
  3784 => x"be1f",
  3785 => x"e5cf",
  3786 => x"e0d2",
  3787 => x"bfde",
  3788 => x"bfcd",
  3789 => x"e020",
  3790 => x"e6a0",
  3791 => x"e0b0",
  3792 => x"c001",
  3793 => x"921d",
  3794 => x"36a5",
  3795 => x"07b2",
  3796 => x"f7e1",
  3797 => x"d036",
  3798 => x"c125",
  3799 => x"cfe0",
  3800 => x"e081",
  3801 => x"bb8f",
  3802 => x"e681",
  3803 => x"ee93",
  3804 => x"e1a6",
  3805 => x"e0b0",
  3806 => x"99f1",
  3807 => x"c00a",
  3808 => x"9701",
  3809 => x"09a1",
  3810 => x"09b1",
  3811 => x"9700",
  3812 => x"05a1",
  3813 => x"05b1",
  3814 => x"f7b9",
  3815 => x"e0e0",
  3816 => x"e0f0",
  3817 => x"9509",
  3818 => x"ba1f",
  3819 => x"b38e",
  3820 => x"9508",
  3821 => x"e091",
  3822 => x"bb9f",
  3823 => x"9bf0",
  3824 => x"cffe",
  3825 => x"ba1f",
  3826 => x"bb8e",
  3827 => x"e080",
  3828 => x"e090",
  3829 => x"9508",
  3830 => x"dfe1",
  3831 => x"3280",
  3832 => x"f421",
  3833 => x"e184",
  3834 => x"dff2",
  3835 => x"e180",
  3836 => x"cff0",
  3837 => x"9508",
  3838 => x"93cf",
  3839 => x"2fc8",
  3840 => x"dfd7",
  3841 => x"3280",
  3842 => x"f439",
  3843 => x"e184",
  3844 => x"dfe8",
  3845 => x"2f8c",
  3846 => x"dfe6",
  3847 => x"e180",
  3848 => x"91cf",
  3849 => x"cfe3",
  3850 => x"91cf",
  3851 => x"9508",
  3852 => x"9abe",
  3853 => x"e044",
  3854 => x"e450",
  3855 => x"e020",
  3856 => x"e030",
  3857 => x"b388",
  3858 => x"2785",
  3859 => x"bb88",
  3860 => x"01c9",
  3861 => x"9701",
  3862 => x"f7f1",
  3863 => x"5041",
  3864 => x"f7c1",
  3865 => x"e011",
  3866 => x"dfbd",
  3867 => x"3380",
  3868 => x"f0c9",
  3869 => x"3381",
  3870 => x"f499",
  3871 => x"dfb8",
  3872 => x"3280",
  3873 => x"f7c1",
  3874 => x"e184",
  3875 => x"dfc9",
  3876 => x"e481",
  3877 => x"dfc7",
  3878 => x"e586",
  3879 => x"dfc5",
  3880 => x"e582",
  3881 => x"dfc3",
  3882 => x"e280",
  3883 => x"dfc1",
  3884 => x"e489",
  3885 => x"dfbf",
  3886 => x"e583",
  3887 => x"dfbd",
  3888 => x"e580",
  3889 => x"c0c2",
  3890 => x"3480",
  3891 => x"f421",
  3892 => x"dfa3",
  3893 => x"dfa2",
  3894 => x"dfbf",
  3895 => x"cfe2",
  3896 => x"3481",
  3897 => x"f469",
  3898 => x"df9d",
  3899 => x"3880",
  3900 => x"f411",
  3901 => x"e082",
  3902 => x"c029",
  3903 => x"3881",
  3904 => x"f411",
  3905 => x"e081",
  3906 => x"c025",
  3907 => x"3882",
  3908 => x"f511",
  3909 => x"e182",
  3910 => x"c021",
  3911 => x"3482",
  3912 => x"f429",
  3913 => x"e1c4",
  3914 => x"df8d",
  3915 => x"50c1",
  3916 => x"f7e9",
  3917 => x"cfe8",
  3918 => x"3485",
  3919 => x"f421",
  3920 => x"df87",
  3921 => x"df86",
  3922 => x"df85",
  3923 => x"cfe0",
  3924 => x"eb90",
  3925 => x"0f98",
  3926 => x"3093",
  3927 => x"f2f0",
  3928 => x"3585",
  3929 => x"f439",
  3930 => x"df7d",
  3931 => x"9380",
  3932 => x"0063",
  3933 => x"df7a",
  3934 => x"9380",
  3935 => x"0064",
  3936 => x"cfd5",
  3937 => x"3586",
  3938 => x"f439",
  3939 => x"df74",
  3940 => x"df73",
  3941 => x"df72",
  3942 => x"df71",
  3943 => x"e080",
  3944 => x"df95",
  3945 => x"cfb0",
  3946 => x"3684",
  3947 => x"f009",
  3948 => x"c039",
  3949 => x"df6a",
  3950 => x"9380",
  3951 => x"0062",
  3952 => x"df67",
  3953 => x"9380",
  3954 => x"0061",
  3955 => x"9210",
  3956 => x"0060",
  3957 => x"df62",
  3958 => x"3485",
  3959 => x"f419",
  3960 => x"9310",
  3961 => x"0060",
  3962 => x"c00a",
  3963 => x"9180",
  3964 => x"0063",
  3965 => x"9190",
  3966 => x"0064",
  3967 => x"0f88",
  3968 => x"1f99",
  3969 => x"9390",
  3970 => x"0064",
  3971 => x"9380",
  3972 => x"0063",
  3973 => x"e0c0",
  3974 => x"e0d0",
  3975 => x"9180",
  3976 => x"0061",
  3977 => x"9190",
  3978 => x"0062",
  3979 => x"17c8",
  3980 => x"07d9",
  3981 => x"f008",
  3982 => x"cfa7",
  3983 => x"df48",
  3984 => x"2f08",
  3985 => x"df46",
  3986 => x"9190",
  3987 => x"0060",
  3988 => x"91e0",
  3989 => x"0063",
  3990 => x"91f0",
  3991 => x"0064",
  3992 => x"1191",
  3993 => x"c005",
  3994 => x"921f",
  3995 => x"2e00",
  3996 => x"2e18",
  3997 => x"95e8",
  3998 => x"901f",
  3999 => x"9632",
  4000 => x"93f0",
  4001 => x"0064",
  4002 => x"93e0",
  4003 => x"0063",
  4004 => x"9622",
  4005 => x"cfe1",
  4006 => x"3784",
  4007 => x"f009",
  4008 => x"c03e",
  4009 => x"df2e",
  4010 => x"9380",
  4011 => x"0062",
  4012 => x"df2b",
  4013 => x"9380",
  4014 => x"0061",
  4015 => x"9210",
  4016 => x"0060",
  4017 => x"df26",
  4018 => x"3485",
  4019 => x"f419",
  4020 => x"9310",
  4021 => x"0060",
  4022 => x"c00a",
  4023 => x"9180",
  4024 => x"0063",
  4025 => x"9190",
  4026 => x"0064",
  4027 => x"0f88",
  4028 => x"1f99",
  4029 => x"9390",
  4030 => x"0064",
  4031 => x"9380",
  4032 => x"0063",
  4033 => x"df16",
  4034 => x"3280",
  4035 => x"f009",
  4036 => x"cf55",
  4037 => x"e184",
  4038 => x"df26",
  4039 => x"e0c0",
  4040 => x"e0d0",
  4041 => x"9180",
  4042 => x"0061",
  4043 => x"9190",
  4044 => x"0062",
  4045 => x"17c8",
  4046 => x"07d9",
  4047 => x"f528",
  4048 => x"9180",
  4049 => x"0060",
  4050 => x"2388",
  4051 => x"f011",
  4052 => x"e080",
  4053 => x"c005",
  4054 => x"91e0",
  4055 => x"0063",
  4056 => x"91f0",
  4057 => x"0064",
  4058 => x"9184",
  4059 => x"df11",
  4060 => x"9180",
  4061 => x"0063",
  4062 => x"9190",
  4063 => x"0064",
  4064 => x"9601",
  4065 => x"9390",
  4066 => x"0064",
  4067 => x"9380",
  4068 => x"0063",
  4069 => x"9621",
  4070 => x"cfe2",
  4071 => x"3785",
  4072 => x"f479",
  4073 => x"deee",
  4074 => x"3280",
  4075 => x"f009",
  4076 => x"cf2d",
  4077 => x"e184",
  4078 => x"defe",
  4079 => x"e18e",
  4080 => x"defc",
  4081 => x"e983",
  4082 => x"defa",
  4083 => x"e08b",
  4084 => x"def8",
  4085 => x"e180",
  4086 => x"def6",
  4087 => x"cf22",
  4088 => x"3786",
  4089 => x"f009",
  4090 => x"cf1f",
  4091 => x"cf6b",
  4092 => x"94f8",
  4093 => x"cfff",
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

end architecture Xilinx; -- Entity: lattuino_1_blPM_8

