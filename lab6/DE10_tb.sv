`timescale 1ns/1ps
module DE10_tb;

    // 1. Khai báo các tín hiệu kết nối với kit DE10
    logic       CLOCK_50;   // Xung clock 50MHz
    logic [0:0] KEY;        // KEY[0] là Resetn
    logic [9:9] SW;         // SW[9] là Run
    logic [8:0] LEDR;       // Ngõ ra hiển thị LED

    // 2. Gọi module Top-level (DUT - Device Under Test)
    DE10 dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR)
    );

    // 3. Tạo xung Clock 50MHz )
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // 4. Mo phong
    initial begin
        // --- Trạng thái 1: Reset hệ thống ---
        KEY[0] = 0; 
        SW[9]  = 0; 
        #100;
        
        // --- Trạng thái 2: Chuẩn bị chạy ---
        KEY[0] = 1; 
        #100;
        
        // --- Trạng thái 3: Kích hoạt Run ---
        SW[9] = 1; 

        // Cấp thời gian mô phỏng 5 triệu ns. 
        // Đủ để bất kỳ file .mif nào có vòng lặp trễ nhỏ (delay = 2) chạy được ~150+ vòng lặp.
        #500000;
        
        // Dừng mô phỏng an toàn
        $stop; 
    end

    // 5. Theo dõi tín hiệu (Chỉ in ra khi LEDR thay đổi để log console không bị rác)
    initial begin
        $monitor("[%0t ns] LEDR (Bin): %b | LEDR (Hex): %h", $time, LEDR, LEDR);
    end

endmodule