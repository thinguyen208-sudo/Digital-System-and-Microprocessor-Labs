`timescale 1ns/1ps

module lab5_tb;

    // 1. Khai báo các tín hiệu kết nối với Processor
    logic [8:0] DIN;
    logic       Resetn, Clock, Run;
    logic       Done;
    logic [8:0] BusWires;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic       W;

    // 2. Gọi module (DUT - Design Under Test)
    lab5 cpu (
        .DIN(DIN),
        .Resetn(Resetn),
        .Clock(Clock),
        .Run(Run),
        .Done(Done),
        .BusWires(BusWires),
        .ADDR(ADDR),
        .DOUT(DOUT),
        .W(W)
    );

    // 3. Tạo xung Clock (Chu kỳ 20ns -> Tần số 50MHz giống mạch DE-10)
    initial Clock = 0;
    always #10 Clock = ~Clock;

    // 4. Giả lập một cục RAM đồng bộ nhỏ (32 ô nhớ x 9 bit)
    logic [8:0] ram [0:31];
    
    // RAM trả về dữ liệu sau 1 nhịp clock (Khớp với nhịp chờ T1 và T4 của FSM)
    always_ff @(posedge Clock) begin
        DIN <= ram[ADDR]; 
    end

    // 5. Kịch bản mô phỏng
    initial begin
        // --- NẠP CHƯƠNG TRÌNH VÀO RAM ẢO ---
        // Cấu trúc lệnh: III_XXX_YYY
        // Trong đó: III = Mã lệnh, XXX = Rx, YYY = Ry

        // Lệnh 1: mvi R0, #5 (III=001, Rx=000)
        ram[0] = 9'b001_000_000; 
        ram[1] = 9'd5;           // Giá trị tức thời đi kèm

        // Lệnh 2: mvi R1, #3 (III=001, Rx=001)
        ram[2] = 9'b001_001_000; 
        ram[3] = 9'd3;           // Giá trị tức thời đi kèm

        // Lệnh 3: add R0, R1 (III=010, Rx=000, Ry=001)
        // Lấy R0 + R1 cất vào R0 (5 + 3 = 8)
        ram[4] = 9'b010_000_001;

        // Lệnh 4: st R0, [R1] (III=101, Rx=000, Ry=001)
        // Lấy dữ liệu từ R0 (đang là 8) ghi ra bộ nhớ ngoài tại địa chỉ R1 (đang là 3)
        ram[5] = 9'b101_000_001;

        // Dừng lại ở đây bằng một lệnh nhảy tại chỗ (mvnz hoặc một lệnh rác) 
        // để vi xử lý không chạy lan sang các vùng nhớ trống.
        ram[6] = 9'b000_000_000; 

        // --- BẮT ĐẦU CHẠY THỰC TẾ ---
        // Bước 1: Khởi động và Reset hệ thống
        Resetn = 0; 
        Run = 0;
        #25; // Giữ reset một chút để hệ thống ổn định
        
        // Bước 2: Bật máy
        Resetn = 1;
        #20;
        
        // Bước 3: Gạt công tắc Run lên 1 để Vi xử lý bắt đầu kéo lệnh từ địa chỉ 0
        Run = 1;

        // Đợi vi xử lý chạy khoảng 500ns (đủ thời gian chạy hết 4 lệnh trên)
        #500;
        
        // Dừng mô phỏng
        $stop;
    end

endmodule