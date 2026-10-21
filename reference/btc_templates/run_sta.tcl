# --- Cấu hình ---
set lib_file "normal.lib"
set ver_file "<...>.v" 
set sdc_file "constraints.sdc"
set top_module "<...>"

# --- Chạy OpenSTA ---
read_liberty $lib_file
read_verilog $ver_file

link_design $top_module

# Đọc file constraint SDC
read_sdc $sdc_file

# --- BÁO CÁO KẾT QUẢ ---

# 1. Báo cáo chi tiết top 5 đường dẫn chậm nhất để phân tích
puts "\n--- WORST-CASE TIMING PATHS ---"
report_checks -path_delay max -group_count 1 -fields {slew cap input_pins nets fanout} -digits 4

# 2. Báo cáo công suất (quan trọng với Approximate Multiplier)
puts "\n--- POWER ANALYSIS ---"
report_power

exit
