# NGUYEN VAN THUC - 24161421
# FPGA V0.1.0-LUT-ONLY: matched post-synthesis comparison, DSP48 forbidden.
# Target board: Digilent Zybo Z-7010 (xc7z010clg400-1).

set top_name "lutalm_mul_s8"
if {[info exists ::env(TOP)]} { set top_name $::env(TOP) }
set part_name "xc7z010clg400-1"
if {[info exists ::env(PART)]} { set part_name $::env(PART) }
set low_w 3
if {[info exists ::env(LOW_W)]} { set low_w $::env(LOW_W) }
set period 10.0
if {[info exists ::env(CLOCK_NS)]} { set period $::env(CLOCK_NS) }
set io_delay 2.0
if {[info exists ::env(IO_DELAY_NS)]} { set io_delay $::env(IO_DELAY_NS) }

if {$top_name ni {exact_mul_s8 lutalm_mul_s8 lutalm_mul_u8}} {
    error "Invalid TOP=$top_name"
}
if {$low_w ni {3 4}} {
    error "Invalid LOW_W=$low_w; supported 3 or 4"
}

file mkdir reports
file mkdir build
read_verilog [lsort [glob rtl/*.v]]

# IMPORTANT: -max_dsp 0 for EXACT and LUT-ALM. No DSP48 macro may appear.
if {$top_name eq "exact_mul_s8"} {
    synth_design -top $top_name -part $part_name -no_iobuf \
        -flatten_hierarchy rebuilt -max_dsp 0
} else {
    synth_design -top $top_name -part $part_name -no_iobuf \
        -flatten_hierarchy rebuilt -max_dsp 0 -generic LOW_W=$low_w
}

# Hard gate: report a failure even if Vivado maps to DSP despite the limit.
set dsp_cells [get_cells -hier -quiet -filter {REF_NAME =~ DSP48*}]
set dsp_count [llength $dsp_cells]
if {$dsp_count != 0} {
    error "LUT-ONLY POLICY VIOLATED: $dsp_count DSP48 cells found: $dsp_cells"
}
puts "[format {PASS: LUT-only netlist; DSP48 cell count = %d} $dsp_count]"

# Virtual clock is necessary as this is a fully combinational 8x8 IP.
create_clock -name vclk -period $period
set_input_delay  -clock vclk $io_delay [get_ports {a_i[*]}]
set_input_delay  -clock vclk $io_delay [get_ports {b_i[*]}]
set_output_delay -clock vclk $io_delay [get_ports {p_o[*]}]
update_timing

set suffix "${top_name}_low${low_w}"
report_utilization -hierarchical -file "reports/fpga_util_hier_${suffix}.rpt"
report_utilization    -file "reports/fpga_util_${suffix}.rpt"
report_timing_summary -file "reports/fpga_timing_${suffix}.rpt"
report_timing -delay_type max -max_paths 10 -file "reports/fpga_paths_${suffix}.rpt"
report_power -file "reports/fpga_power_${suffix}.rpt"
write_checkpoint -force "build/${suffix}_synth.dcp"
puts "DONE: $top_name LOW_W=$low_w PART=$part_name DSP48=$dsp_count"
