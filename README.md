# Digital System & Microprocessor Architecture Labs

## Giới thiệu (Overview)
Repository này lưu trữ toàn bộ mã nguồn và tài liệu mô phỏng của chuỗi thực hành môn Kỹ thuật số & Cơ sở máy tính tại Đại học Bách Khoa TP.HCM. Mục tiêu của dự án là thiết kế, tối ưu hóa và tích hợp thành công kiến trúc vi xử lý cơ bản (ALU) và bộ tính toán số thực dấu chấm động (FPU) từ các cổng logic nền tảng.

## Công cụ & Công nghệ (Tools & Technologies)
*   **Ngôn ngữ Mô tả Phần cứng:** Verilog / SystemVerilog.
*   **Mô phỏng & Kiểm thử (Verification):** ModelSim / Questa.
*   **Tổng hợp mạch (Synthesis) & RTL Viewer:** Quartus Prime.
*   **Phần cứng đích:** Kit phát triển DE10-FPGA.

## Cấu trúc Repository (Repository Structure)
Dự án được tổ chức theo phương pháp thiết kế Bottom-Up (xây dựng từ module cơ sở lên hệ thống hoàn chỉnh), được chia thành 6 giai đoạn tương ứng với 6 thư mục:

* `Lab1/`: Thiết kế các bộ cộng đặc biệt và áp dụng để xây dựng bộ nhân.
* `Lab2/`: Thiết kế máy trạng thái (FSM).
* `Lab3/`: Thiết kế bộ cộng trừ số thực dấu chấm động ALU.
* `Lab4/`: Thiết kế Kiến trúc Vi xử lý cốt lõi, kết hợp ALU và Máy trạng thái (FSM) để điều khiển luồng dữ liệu (Datapath).
* `Lab5/`: Khởi tạo IP Core và tích hợp hệ thống Bộ nhớ (RAM/ROM) vào vi xử lý.
* `Lab6/`: Thiết kế nâng cao - Xây dựng và tích hợp phân hệ tính toán số thực dấu chấm động (FPU - Floating Point Unit) chuẩn IEEE 754.

## Tính năng Nổi bật (Key Highlights)
1.  **Làm chủ phương pháp Bottom-Up:** Tích hợp thành công các module logic đơn lẻ (bộ cộng, giải mã, thanh ghi) thành một hệ thống Datapath hoàn chỉnh có khả năng thực thi tính toán.
2.  **Thiết kế Điều khiển (Control Unit):** Hiện thực hóa Máy trạng thái hữu hạn (FSM) để đồng bộ và cấp phát chính xác các tín hiệu điều khiển cho ALU thao tác với dữ liệu.
3.  **Tích hợp IP Core & Toán hạng phức tạp:** Khởi tạo thành công bộ nhớ RAM/ROM qua Quartus và tích hợp bộ xử lý số thực dấu chấm động (FPU) vào hệ thống.
4.  **Kiểm thử chức năng (Functional Verification):** Xây dựng các testbench cơ bản trên ModelSim để xác minh tính đúng đắn của dạng sóng (waveform) và biên dịch mạch thành công trên phần cứng Quartus.

## Báo cáo Kỹ thuật (Technical Reports)
Dưới đây là các tài liệu báo cáo chi tiết cho từng bài thực hành, bao gồm sơ đồ khối (RTL schematic), code thiết kế, kết quả mô phỏng dạng sóng (Waveforms), và hình ảnh nạp kit DE10 thực tế:

* [Báo cáo Lab 1: Giới thiệu Thiết kế số](./Report/2351016_2451165_2351007_Lab1_Digital_Design.pdf)
* [Báo cáo Lab 2: Mạch tổ hợp & Tuần tự](./Report/2351016_2451165_2351007_Lab2_Digital_Design.pdf)
* [Báo cáo Lab 3: Bộ số học và Logic (ALU)](./Report/2351016_2451165_2351007_Lab3_Digital_Design.pdf)
* [Báo cáo Lab 4: Kiến trúc Vi xử lý cơ bản](./Report/2351016_2451165_2351007_Lab4_Digital_Design.pdf)
* [Báo cáo Lab 5: Processor](./Report/2351016_2451165_2351007_Lab5_Digital_Design.pdf)
* [Báo cáo Lab 6: Processor + Bộ xử lý số thực (FPU)](./Report/2351016_2451165_2351007_Lab6_Digital_Design.pdf)
