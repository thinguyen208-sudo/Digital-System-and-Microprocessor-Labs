module processor_tb();

  // 1. Khai báo các tín hiệu kết nối
  logic       Clock, Resetn, Run;
  logic       Done;
  logic [8:0] BusWires;

  // 2. Gọi module Top-Level (chứa cả Processor và ROM)
  processor_top uut (
    .Clock(Clock),
    .Resetn(Resetn),
    .Run(Run),
    .Done(Done),
    .BusWires(BusWires)
  );

  // 3. Tạo xung Clock chung (Chu kỳ = 20)
  initial begin
    Clock = 0;
    forever #10 Clock = ~Clock; 
  end

  // 4. Kịch bản mô phỏng (Stimulus)
  initial begin
    // Trạng thái ban đầu
    Resetn = 0;
    Run = 0;
    #100;         // Đợi hệ thống ổn định

    Resetn = 1;   // Kéo Resetn lên 1 để thoát chế độ reset
    #20;
  
    // Bắt đầu cấp xung Run để thực thi từng lệnh trong ROM
    Run = 1; #20; Run = 0;
    #160;
    Run = 1; #20; Run = 0;
    #160;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #60;
    Run = 1; #20; Run = 0;
    #160;
    Run = 1; #20; Run = 0;
    #160;
    
    Run = 0;
 
    // Đợi thêm một khoảng thời gian rồi kết thúc mô phỏng
    #500;
    $finish;
  end

endmodule