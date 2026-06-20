`timescale 1ns/1ps

module DE10_tb;

    // 1. Khai báo các tín hiệu ngoại vi của board DE10
    logic       CLOCK_50;
    logic [0:0] KEY;
    logic [9:9] SW;
    logic [8:0] LEDR;

    // 2. Gọi module Top-level (DUT)
    DE10 dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SW(SW),
        .LEDR(LEDR)
    );

    // 3. Tạo xung Clock 50MHz (Chu kỳ 20ns)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // 4. Kịch bản mô phỏng
    initial begin
        
        // Trạng thái tắt máy
        KEY[0] = 0; // Đè nút Reset
        SW[9]  = 0; // Tắt công tắc Run
        #50;
        
        // Nhả nút Reset
        KEY[0] = 1;
        #50;
        
        // Gạt công tắc Run lên để bắt đầu chạy chương trình trong RAM
        SW[9] = 1;

        // CHÚ Ý: Chạy mô phỏng trong thời gian DÀI (50,000 ns)
        // Để CPU có thời gian khởi tạo và chạy qua các vòng lặp trễ
        #100000;
        
        $stop;
    end

endmodule