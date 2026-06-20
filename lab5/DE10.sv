module DE10 (
    input  logic       CLOCK_50, // Xung clock 50MHz của mạch
    input  logic [0:0] KEY,      // KEY[0] dùng làm nút bấm Resetn
    input  logic [9:9] SW,       // SW[9] dùng làm công tắc Run
    output logic [8:0] LEDR      // LEDR[8:0] nối ra 9 bóng đèn LED đỏ
);

    // --- 1. KHAI BÁO DÂY NỐI NỘI BỘ ---
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic [8:0] DIN;
    logic       W;
    logic       Done;
    logic [8:0] BusWires; // Giữ lại để debug nếu cần
	 

    // Tín hiệu giải mã địa chỉ (Address Decoding)
    logic ram_wr_en;
    logic led_en;

    // --- 2. MẠCH GIẢI MÃ ĐỊA CHỈ (Dựa trên Hình 2) ---
    // RAM được ghi khi 2 bit địa chỉ cao nhất A8, A7 = 00 VÀ có cờ Write (W=1)
    assign ram_wr_en = ~(ADDR[8] | ADDR[7]) & W;
    
    // LED được cập nhật khi A8, A7 = 01 VÀ có cờ Write (W=1)
    // Phép AND ở cổng dưới cùng của Hình 2: A7 đưa thẳng vào, A8 qua cổng NOT
    assign led_en    = ~(ADDR[8] | ~ADDR[7]) & W;
	

    // --- 3. CẮM CÁC THÀNH PHẦN VÀO HỆ THỐNG ---

    // A. Lõi Vi xử lý (Processor)
    lab5 cpu (
        .DIN(DIN),
        .Resetn(KEY[0]),
        .Clock(CLOCK_50),
        .Run(SW[9]),
        .Done(Done),
        .BusWires(BusWires),
        .ADDR(ADDR),
        .DOUT(DOUT),
        .W(W)
    );

    // B. Bộ nhớ RAM (Memory 128 words x 9 bits)
    // Lưu ý: Module này KHÔNG tự có sẵn, bạn phải tạo bằng Quartus IP Catalog!
    my_ram ram (
        .address (ADDR[6:0]),  // Chỉ lấy 7 bit thấp (A6 -> A0) để quét 128 ô nhớ
        .clock   (CLOCK_50),   // RAM đồng bộ dùng chung xung clock
        .data    (DOUT),       // Dữ liệu từ CPU đẩy ra chờ ghi vào RAM
        .wren    (ram_wr_en),  // Cờ báo hiệu ghi vào RAM
        .q       (DIN)         // Dữ liệu RAM nhả ra để CPU đọc (lệnh hoặc data)
    );

    // C. Thanh ghi LED (Output Register)
    always_ff @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0]) begin
            LEDR <= 9'b000000000; // Reset tắt hết bóng đèn
        end else if (led_en) begin
            LEDR <= DOUT;         // Chốt dữ liệu từ DOUT ra đèn LED
        end
    end

endmodule