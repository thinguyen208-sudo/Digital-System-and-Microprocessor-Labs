`timescale 1ns / 1ps

module lab2_tn3_tb();

    // Khai báo các tín hiệu kết nối với module cần test (DUT)
    logic clk;
    logic rst; // Reset tích cực mức thấp (dựa theo hình ảnh)
    logic w;
    logic z;
    logic [7:0] state; // Dùng để quan sát trạng thái (Y)
	 
	 // 2. Khai báo biến 10-bit để hứng toàn bộ ngõ ra từ mạch
    logic [9:0] LEDR_tb;
	 assign z = LEDR_tb[9];       // Lấy bit 9 gán cho z
    assign state = LEDR_tb[7:0]; // Lấy 8 bit thấp gán cho state
    
    // Gọi module (DUT - Device Under Test)
    // Lưu ý: Thay "prelab2_tn1" bằng tên module thực tế của bạn nếu khác
	lab2_tn3 DUT (
        .KEY(clk),         // Nối tín hiệu clk của testbench vào KEY[0]
        .SW({w, rst}),     // Nối w vào SW[1] và rst vào SW[0]
        .LEDR(LEDR_tb)  // Nối ngõ ra z vào LEDR[9] và trạng thái vào LEDR[7:0]
    );

    // Tạo xung Clock (Chu kỳ 10ns -> Tần số 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Khối tạo tín hiệu kích thích (Stimulus)
    initial begin
        // 1. Khởi tạo ban đầu
        rst = 1'b0; 
        w = 1'b0;
        
        // 2. Kích hoạt Reset (Active-low) ở đầu mô phỏng
        @(negedge clk); // Đợi cạnh xuống của clock
        rst = 1'b1;     // Kéo rst xuống 0 để reset về trạng thái A
        
        @(negedge clk); 
        rst = 1'b1;     // Nhả reset (lên 1), FSM bắt đầu hoạt động
        
        // 3. w = 0 trong khoảng 2 chu kỳ tiếp theo (tổng là 3 chu kỳ đầu)
        @(negedge clk);
        @(negedge clk);
        
        // 4. w = 1 trong 1 chu kỳ
        w = 1'b1;
        @(negedge clk);
        
        // 5. w = 0 trong 3 chu kỳ
        w = 1'b0;
        @(negedge clk);
        @(negedge clk);
        @(negedge clk);
	@(negedge clk);
        
        // 6. w = 1 trong 5 chu kỳ liên tiếp
        // Đủ 4 chu kỳ thì z sẽ nhảy lên 1, chu kỳ thứ 5 z vẫn giữ mức 1
        w = 1'b1;
        @(negedge clk); // 1
        @(negedge clk); // 2
        @(negedge clk); // 3
        @(negedge clk); // 4 -> Sau cạnh lên tiếp theo z sẽ = 1
        @(negedge clk); // 5 -> z tiếp tục giữ 1
        
        // 7. w = 0 trở lại, ngắt chuỗi 1 -> z sẽ rớt xuống 0
        w = 1'b0;
        @(negedge clk);
		  rst = 1'b0;     // Kéo rst xuống 0
        @(negedge clk);
        rst = 1'b1;     // Nhả reset
        @(negedge clk);
        @(negedge clk);
        
        // 8. Test thử reset giữa chừng

        
        // Đợi thêm vài chu kỳ rồi kết thúc mô phỏng
        @(negedge clk);
        @(negedge clk);
        $stop;          // Dừng mô phỏng
    end

endmodule