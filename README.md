# KTMT_Nhom1

## Các loại lệnh hỗ trợ

R-Type: add, sub, and, or, xor, nor, sll, srl, sra, slt

I-Type: addi, andi, ori, slti, lw, sw, bne, beq

J-Type: j, jal

## Khai thác, sử dụng code

Thông tin về mã nguồn:
- CPU.vhd: Mã mô phỏng top CPU
- Folder Run: Chứa toàn bộ mã (gồm mã các khối, top CPU, testbench) để chạy kết nối toàn bộ khối
- Các Folder khác: Chức mã và các Module con của khối (tên folder ứng với tên khối) và testbench cho từng khối

Khai thác và sử dụng: 
- Công cụ hỗ trợ: Visual Studio Code (cần cài Modern VHDL), GtkWave
- Chạy testbench toàn bộ CPU: trên Terminal cd đến Folder Run => Mở file InstructionMemory.vhd để sửa lại mã MIPS chạy CPU nếu cần => Mở file CPU.vhd và thực hiện lệnh trên Terminal như mô tả đầu file CPU.vhd
- Chạy testbench cho từng khối: trên Terminal cd đến Folder có tên khối cần kiểm thử => sửa file <Tên khối>_tb.vhd => mở file <Tên khối>.vhd và thực hiện lệnh trên Terminal như mô tả đầu file CPU.vhd
