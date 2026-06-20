// --- MODULE WRAPPER CHO DE10 BOARD ---
module lab4_tn1_wrapper (
    input  logic [9:0] SW,   // 10 Công tắc gạt
    input  logic [1:0] KEY,  // 2 Nút nhấn
    output logic [8:0] LEDR, // 9 Đèn LED đỏ (Hiển thị Bus)
    output logic [6:0] HEX0  // THÊM DÒNG NÀY: Khai báo 1 cụm LED 7 đoạn
);

    logic Done_wire;
    
    // Cắm trực tiếp các chân cứng vào module Processor
    lab4_tn1 my_cpu (
        .DIN      (SW[8:0]),   // First 9 switch for command/value input
        .Run      (SW[9]),     // 10th SW for run command       
        .Resetn   (KEY[0]),    // (Active Low)
        .Clock    (~KEY[1]),   // Nút KEY[1] làm Xung Clock (Đảo bit để bắt sườn lên khi bấm)
        .BusWires (LEDR[8:0]), // Xuất kết quả Bus ra 9 LED đầu tiên
        .Done     (Done_wire)
    );
     
    // Hiện chữ 'd' (0100001) nếu Done_wire = 1, tắt hết (1111111) nếu Done_wire = 0
    assign HEX0 = Done_wire ? 7'b0100001 : 7'b1111111;

endmodule