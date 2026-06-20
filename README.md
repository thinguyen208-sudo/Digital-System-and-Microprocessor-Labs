# 🖥️ Digital System & Microprocessor Architecture Labs

## 📖 Giới thiệu (Overview)
Repository này lưu trữ toàn bộ mã nguồn và tài liệu mô phỏng của chuỗi thực hành môn Kỹ thuật số & Cơ sở máy tính tại Đại học Bách Khoa TP.HCM. Mục tiêu của dự án là thiết kế, tối ưu hóa và tích hợp thành công kiến trúc vi xử lý cơ bản (ALU) và bộ tính toán số thực dấu chấm động (FPU) từ các cổng logic nền tảng.

## 🛠 Công cụ & Công nghệ (Tools & Technologies)
*   **Ngôn ngữ Mô tả Phần cứng:** Verilog / SystemVerilog.
*   **Mô phỏng & Kiểm thử (Verification):** ModelSim / Questa.
*   **Tổng hợp mạch (Synthesis) & RTL Viewer:** Quartus Prime.
*   **Phần cứng đích:** Kit phát triển DE10-FPGA.

## 📂 Cấu trúc Repository (Repository Structure)
Dự án được tổ chức theo phương pháp thiết kế Bottom-Up (xây dựng từ module cơ sở lên hệ thống hoàn chỉnh), được chia thành 6 giai đoạn tương ứng với 6 thư mục:

* `Lab1/` & `Lab2/`: Thiết kế các cổng logic cơ sở, mạch tổ hợp (Bộ cộng, Bộ giải mã, Multiplexer) và mạch tuần tự (Flip-Flops, Thanh ghi).
* `Lab3/`: Xây dựng Bộ số học và Logic (ALU) 8-bit thực hiện các phép toán nền tảng.
* `Lab4/`: Thiết kế Kiến trúc Vi xử lý cốt lõi, kết hợp ALU và Máy trạng thái (FSM) để điều khiển luồng dữ liệu (Datapath).
* `Lab5/`: Khởi tạo IP Core và tích hợp hệ thống Bộ nhớ (RAM/ROM) vào vi xử lý.
* `Lab6/`: Thiết kế nâng cao - Xây dựng và tích hợp phân hệ tính toán số thực dấu chấm động (FPU - Floating Point Unit) chuẩn IEEE 754.

## 🚀 Tính năng Nổi bật (Key Highlights)
1.  **Thiết kế FSM:** Hiện thực hóa máy trạng thái hữu hạn để điều khiển các tín hiệu control cho ALU.
2.  **Tối ưu phần cứng:** Giảm thiểu độ trễ trên đường truyền (critical path) trong bộ nhân 8-bit.
3.  **Kiểm thử nghiêm ngặt:** 100% các module đều vượt qua testbench với các edge-cases (trường hợp biên) trên ModelSim.

## 📄 Báo cáo Kỹ thuật (Technical Reports)
Dưới đây là các tài liệu báo cáo chi tiết cho từng bài thực hành, bao gồm phân tích lý thuyết, sơ đồ khối (RTL schematic), thiết kế FSM và kết quả mô phỏng dạng sóng (Waveforms):

* [Báo cáo Lab 1: Giới thiệu Thiết kế số](./Report/2351016_2451165_2351007_Lab1_Digital_Design.pdf)
* [Báo cáo Lab 2: Mạch tổ hợp & Tuần tự](./Report/2351016_2451165_2351007_Lab2_Digital_Design.pdf)
* [Báo cáo Lab 3: Bộ số học và Logic (ALU)](./Report/2351016_2451165_2351007_Lab3_Digital_Design.pdf)
* [Báo cáo Lab 4: Kiến trúc Vi xử lý cơ bản](./Report/2351016_2451165_2351007_Lab4_Digital_Design.pdf)
* [Báo cáo Lab 5: Processor](./Report/2351016_2451165_2351007_Lab5_Digital_Design.pdf)
* [Báo cáo Lab 6: Processor + Bộ xử lý số thực (FPU)](./Report/2351016_2451165_2351007_Lab6_Digital_Design.pdf)
