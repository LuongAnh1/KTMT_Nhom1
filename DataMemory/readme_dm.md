# Di chuyển đến thư mục DataMemory
cd DataMemory

# Compile VHDL files
ghdl -a --std=08 DataMemory.vhd
ghdl -a --std=08 DataMemory_tb.vhd

# Elaborate
ghdl -e --std=08 DataMemory_tb

# Chạy simulation và tạo VCD
ghdl -r --std=08 DataMemory_tb --vcd=data_memory.vcd --stop-time=200ns

