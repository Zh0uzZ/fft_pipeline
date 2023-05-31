# 创建工程
create_project my_project ./my_project -part xc7k325tffg900-2

# 添加设计文件
add_files ./rtl/my_design.v

# 设置顶层模块
set_property top my_design [current_fileset]


# simulation
add_files -fileset sim_1 -norecurse -scan_for_includes /home/hank/workspace/repos/fft32/fft_pipeline/testbench/2dffttb.sv
set_property top fft2d_tb [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
launch_simulation

set curr_wave [current_wave_config]
if { [string length $curr_wave] == 0 } {
  if { [llength [get_objects]] > 0} {
    add_wave /
    set_property needs_save false [current_wave_config]
  } else {
     send_msg_id Add_Wave-1 WARNING "No top level signals found. Simulator will start without a wave window. If you want to open a wave window go to 'File->New Waveform Configuration' or type 'create_wave_config' in the TCL console."
  }
}

run 1000ns


set_param general.message.detailLevel "Detailed"
set_param general.message.verbosity HIGH
set_param general.message.fileName "/home/hank/workspace/repos/fft32/fft_pipeline/work/result.txt"


# 运行综合
synth_design -top my_design

# 实现设计
impl_design -top my_design -strategy Speed

# 生成比特流文件
write_bitstream -force ./output/my_design.bit

# 关闭 Vivado
close_project
