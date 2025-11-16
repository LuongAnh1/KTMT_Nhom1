# Di chuyển đến thư mục RegisterFile
cd RegisterFile

# Compile VHDL files
ghdl -a --std=08 RegisterFile.vhd
ghdl -a --std=08 RegisterFile_tb.vhd

# Elaborate
ghdl -e --std=08 RegisterFile_tb

# Chạy simulation và tạo VCD
ghdl -r --std=08 RegisterFile_tb --vcd=register_file.vcd --stop-time=200ns