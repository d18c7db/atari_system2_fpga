@ECHO OFF
MD D:\Users\Zero\github\atari_system2_fpga\tb\sim
CD D:\Users\Zero\github\atari_system2_fpga\tb\sim
COPY /Y D:\Modeltech64_10.7\modelsim.ini
REM ECHO `define BUILD_DATE "000000">build_id.v
vlib rtl_work

REM ECHO #>files_vlog.txt
REM ECHO ../../rtl/pll.v>>files_vlog.txt
REM ECHO ../../rtl/pll/pll_0002.v>>files_vlog.txt
REM vlog -work work -f D:\Users\Zero\github\atari_system2_fpga\tb\sim\files_vlog.txt -define MODELSIM
REM if %ERRORLEVEL% NEQ 0 goto EXIT

ECHO #>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_A06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_B06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_C06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_D06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_H06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_J06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_K06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_L06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_M06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_N06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_P06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_S06.VHD>>files_vhdl.txt
ECHO ../ROMs/source/paperboy/ROM_VID_T06.VHD>>files_vhdl.txt
ECHO ../../rtl/lib/bitmap/bmp_pkg.vhd>>files_vhdl.txt
ECHO ../../rtl/lib/bitmap/bmp_out.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/RAM_256x16.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/RAM_2K8.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/RAM_8K16.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/MOLB.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/PFHS.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/RGBI.vhd>>files_vhdl.txt
ECHO ../../rtl/atarisys2/VIDEO.vhd>>files_vhdl.txt
ECHO ../tb_video.vhd>>files_vhdl.txt

vcom -work work -f D:/Users/Zero/github/atari_system2_fpga/tb/sim/files_vhdl.txt
if %ERRORLEVEL% NEQ 0 goto EXIT

PAUSE
vsim tb_video -voptargs="+acc" -t 1ps

:EXIT
cd ..
