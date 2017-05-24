------------------------------------------------------------------------------
----                                                                      ----
----  Lattuino program memories and peripherals package                   ----
----                                                                      ----
----  This file is part FPGA Libre project http://fpgalibre.sf.net/       ----
----                                                                      ----
----  Description:                                                        ----
----  This is a package with the PMs used for Lattuino.                   ----
----  It also includes the Lattuino peripherals.                          ----
----                                                                      ----
----  To Do:                                                              ----
----  -                                                                   ----
----                                                                      ----
----  Author:                                                             ----
----    - Salvador E. Tropea, salvador inti.gob.ar                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Copyright (c) 2017 Salvador E. Tropea <salvador inti.gob.ar>         ----
---- Copyright (c) 2017 Instituto Nacional de Tecnología Industrial       ----
----                                                                      ----
---- Distributed under the GPL v2 or newer license                        ----
----                                                                      ----
------------------------------------------------------------------------------
----                                                                      ----
---- Design unit:      PrgMems (Package)                                  ----
---- File name:        pm_pkg.in.vhdl (template used)                     ----
---- Note:             None                                               ----
---- Limitations:      None known                                         ----
---- Errors:           None known                                         ----
---- Library:          lattuino                                           ----
---- Dependencies:     IEEE.std_logic_1164                                ----
----                   IEEE.numeric_std                                   ----
---- Target FPGA:      iCE40HX4K-TQ144                                    ----
---- Language:         VHDL                                               ----
---- Wishbone:         No                                                 ----
---- Synthesis tools:  Lattice iCECube2 2016.02.27810                     ----
---- Simulation tools: GHDL [Sokcho edition] (0.2x)                       ----
---- Text editor:      SETEdit 0.5.x                                      ----
----                                                                      ----
------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package PrgMems is
   @component:../Work/lattuino_1_bl_8.vhdl@

   @component:../Work/lattuino_1_bl_4.vhdl@

   @component:../Work/lattuino_1_bl_2.vhdl@

   @component:../Work/lattuino_1_bl_2s.vhdl@

   @component:../devices/tmcounter.vhdl@

   @component:../devices/tm16b.vhdl@

   @component:../devices/ad_conv.vhdl@
end package PrgMems;

