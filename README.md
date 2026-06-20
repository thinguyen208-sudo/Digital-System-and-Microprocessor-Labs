# 🖥️ Digital System & Microprocessor Architecture Labs

## 📖 Giới thiệu (Overview)
Repository này lưu trữ toàn bộ mã nguồn và tài liệu mô phỏng của chuỗi thực hành môn Kỹ thuật số & Cơ sở máy tính tại Đại học Bách Khoa TP.HCM. Mục tiêu của dự án là thiết kế, tối ưu hóa và tích hợp thành công kiến trúc vi xử lý cơ bản (ALU) và bộ tính toán số thực dấu chấm động (FPU) từ các cổng logic nền tảng.

## 🛠 Công cụ & Công nghệ (Tools & Technologies)
*   **Ngôn ngữ Mô tả Phần cứng:** Verilog / SystemVerilog.
*   **Mô phỏng & Kiểm thử (Verification):** ModelSim / Questa.
*   **Tổng hợp mạch (Synthesis) & RTL Viewer:** Quartus Prime.
*   **Phần cứng đích:** Kit phát triển DE10-FPGA.

## 📂 Cấu trúc Repository (Repository Structure)
Dự án được phát triển theo phương pháp Bottom-Up (thiết kế từ module nhỏ ghép thành hệ thống lớn), bao gồm các phân hệ sau:

*   `lab1_tn1/` đến `lab3_tn.../`: Các module logic tổ hợp và tuần tự cơ bản (Bộ cộng, Bộ giải mã, Flip-Flops, Registers).
*   `lab4_tn7/`: Cấu trúc cốt lõi của vi xử lý bao gồm Bộ số học và logic (ALU) 8-bit và Máy trạng thái (FSM) điều khiển luồng dữ liệu.
*   `FPU_Module/`: Thiết kế và tích hợp bộ xử lý số thực dấu chấm động (Floating Point Unit) chuẩn IEEE 754.
*   `testbenches/`: Chứa toàn bộ các kịch bản kiểm thử (testbench) dùng trong ModelSim.

## 🚀 Tính năng Nổi bật (Key Highlights)
1.  **Thiết kế FSM:** Hiện thực hóa máy trạng thái hữu hạn để điều khiển các tín hiệu control cho ALU.
2.  **Tối ưu phần cứng:** Giảm thiểu độ trễ trên đường truyền (critical path) trong bộ nhân 8-bit.
3.  **Kiểm thử nghiêm ngặt:** 100% các module đều vượt qua testbench với các edge-cases (trường hợp biên) trên ModelSim.

## 📷 Hình ảnh Mô phỏng (Simulation & RTL Results)
*(Thêm hình ảnh bằng cách kéo thả ảnh vào file README trên GitHub)*

*   **1. Sơ đồ khối RTL (RTL Viewer từ Quartus):**
    `[Chèn hình ảnh kiến trúc tổng thể của ALU hoặc FPU tại đây]`
*   **2. Dạng sóng Dữ liệu (Waveform từ ModelSim):**
    `[Chèn hình ảnh Waveform chứng minh mạch chạy đúng các phép toán tại đây]`

## ⚙️ Hướng dẫn Chạy mô phỏng (How to Run)
1. Clone repository này về máy: `git clone [link_repo_của_bạn]`
2. Mở Quartus Prime, trỏ đường dẫn thư mục làm việc (working directory) vào file project `.qpf`.
3. Để xem dạng sóng: Chạy file script `.do` tương ứng trong thư mục `testbenches` bằng phần mềm ModelSim.
