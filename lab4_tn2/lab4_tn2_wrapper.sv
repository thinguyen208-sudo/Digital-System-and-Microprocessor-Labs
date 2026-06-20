// --- MODULE WRAPPER CHO DE10 BOARD (HỆ THỐNG CÓ ROM & COUNTER) ---
module lab4_tn2_wrapper (
    input  logic [9:0] SW,   // 10 Công tắc gạt
    input  logic [2:0] KEY,  // 3 Nút nhấn (Dùng KEY0, KEY1, KEY2)
    output logic [9:0] LEDR, // 10 Đèn LED đỏ
    output logic [6:0] HEX0  // 1 Cụm LED 7 đoạn (Hiện chữ 'd')
);
    logic Done_wire;   
    // Cắm trực tiếp các chân cứng vào hệ thống lab4_tn2
    lab4_tn2 my_system (
        .Run      (SW[9]),     // Gạt SW[9] lên 1 để cho phép chạy       
        .Resetn   (KEY[0]),    // Nút KEY[0] làm Reset (Bấm để reset về 0)        
        // --- HAI XUNG CLOCK ĐỘC LẬP ---
        .MClock   (~KEY[1]),   // Nút KEY[1] cấp xung cho Counter & ROM
        .PClock   (~KEY[2]),   // Nút KEY[2] cấp xung cho Vi xử lý (Processor)
        .Bus      (LEDR[8:0]), // Xuất kết quả đường truyền Bus ra 9 LED đầu tiên
        .Done     (Done_wire)
    );
     
    // Hiện chữ 'd' (0100001) nếu lệnh chạy xong, ngược lại tắt hết
    assign HEX0 = Done_wire ? 7'b0100001 : 7'b1111111;
	 assign LEDR[9] = 0;

endmodule