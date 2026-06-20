// --- Module giải mã 7-segment (Giữ nguyên) ---
module hex_7seg (
    input  logic [3:0] hex,
    output logic [6:0] seg
);
    always_comb begin
        case (hex)
            4'h0: seg = 7'b1000000; 4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100; 4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001; 4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010; 4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000; 4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000; 4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110; 4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110; 4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule

// --- Khối D-Flip Flop (Giữ nguyên) ---
module dff_en (
    input  logic d, clk, rst_n, en,
    output logic q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            q <= 1'b0;
        else if (en) 
            q <= d;
    end
endmodule

// --- Thanh ghi 8-bit (Giữ nguyên) ---
module reg_8bit_struct (
    input  logic [7:0] D,
    input  logic clk, rst_n, en,
    output logic [7:0] Q
);
    dff_en bit0 (D[0], clk, rst_n, en, Q[0]);
    dff_en bit1 (D[1], clk, rst_n, en, Q[1]);
    dff_en bit2 (D[2], clk, rst_n, en, Q[2]);
    dff_en bit3 (D[3], clk, rst_n, en, Q[3]);
    dff_en bit4 (D[4], clk, rst_n, en, Q[4]);
    dff_en bit5 (D[5], clk, rst_n, en, Q[5]);
    dff_en bit6 (D[6], clk, rst_n, en, Q[6]);
    dff_en bit7 (D[7], clk, rst_n, en, Q[7]);
endmodule

// --- Full Adder (Giữ nguyên) ---
module full_adder (
    input  logic a, b, cin,
    output logic s, cout
);
    assign s    = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);
endmodule

// --- Module Adder/Subtractor 8-bit ---
// Triển khai theo cấu trúc Figure trên trang 6 
module adder_subtractor_8bit (
    input  logic [7:0] a, b,
    input  logic add_sub,     // Tín hiệu điều khiển M [cite: 151]
    output logic [7:0] sum,
    output logic cout,        // C8
    output logic c7_out       // Carry vào bit dấu để tính Overflow
);
    logic [7:1] c;
    logic [7:0] b_xor;

    // Nếu add_sub = 1, đảo bit của b và cin = 1 để thực hiện bù 2 
    assign b_xor = b ^ {8{add_sub}}; 

    full_adder fa0 (a[0], b_xor[0], add_sub, sum[0], c[1]);
    full_adder fa1 (a[1], b_xor[1], c[1],    sum[1], c[2]);
    full_adder fa2 (a[2], b_xor[2], c[2],    sum[2], c[3]);
    full_adder fa3 (a[3], b_xor[3], c[3],    sum[3], c[4]);
    full_adder fa4 (a[4], b_xor[4], c[4],    sum[4], c[5]);
    full_adder fa5 (a[5], b_xor[5], c[5],    sum[5], c[6]);
    full_adder fa6 (a[6], b_xor[6], c[6],    sum[6], c[7]);
    full_adder fa7 (a[7], b_xor[7], c[7],    sum[7], cout);

    assign c7_out = c[7];
endmodule

// --- MODULE CHÍNH CHO EXPERIMENT 2 (CẬP NHẬT HIỂN THỊ TỨC THÌ) ---
module lab1_tn2 (
    input  logic [9:0] SW,      // SW7-0: A, SW9: add_sub [cite: 175]
    input  logic [1:0] KEY,     // KEY0: rst_n, KEY1: clock [cite: 175, 176]
    output logic [9:0] LEDR,    // LEDR7-0: S, LEDR8: Carry, LEDR9: Overflow [cite: 181]
    output logic [6:0] HEX0, HEX1, HEX2, HEX3 // HEX3-2: A, HEX1-0: S [cite: 182]
);
    // Tín hiệu nội bộ
    logic [7:0] A_reg, S_accumulator, next_res;
    logic c7_sig, c8_sig, v_sig;
    logic add_sub_ctrl;

    assign add_sub_ctrl = SW[9]; 

    // 1. Thanh ghi lưu giá trị A (Register R trong Figure 2) [cite: 110]
    // Giá trị này chỉ thay đổi khi nhấn KEY1 [cite: 176]
    reg_8bit_struct regA (
        .D(SW[7:0]), 
        .clk(KEY[1]), 
        .rst_n(KEY[0]), 
        .en(1'b1), 
        .Q(A_reg)
    );

    // 2. Bộ Cộng/Trừ 8-bit (S = S +/- A) [cite: 104, 106]
    adder_subtractor_8bit adder_sub_inst (
        .a(S_accumulator), 
        .b(A_reg), 
        .add_sub(add_sub_ctrl), 
        .sum(next_res), 
        .cout(c8_sig), 
        .c7_out(c7_sig)
    );

    // 3. Phát hiện lỗi tràn (V = C7 ^ C8) [cite: 45, 146]
    assign v_sig = c7_sig ^ c8_sig;

    // 4. Thanh ghi tích lũy S [cite: 116]
    reg_8bit_struct regS (
        .D(next_res), 
        .clk(KEY[1]), 
        .rst_n(KEY[0]), 
        .en(1'b1), 
        .Q(S_accumulator)
    );

    // 5. Chốt Carry và Overflow vào LEDR8 và LEDR9 [cite: 181]
    dff_en carry_ff     (c8_sig, KEY[1], KEY[0], 1'b1, LEDR[8]);
    dff_en overflow_ff  (v_sig,  KEY[1], KEY[0], 1'b1, LEDR[9]);

    assign LEDR[7:0] = S_accumulator;

    // 6. HIỂN THỊ (ĐÃ CHỈNH SỬA)
    // HEX3-2: Kết nối TRỰC TIẾP với SW[7:0] để sáng ngay khi gạt [Thay đổi ở đây]
    hex_7seg h3(SW[7:4], HEX3); 
    hex_7seg h2(SW[3:0], HEX2); 
    
    // HEX1-0: Hiển thị giá trị Tổng S (Chỉ thay đổi khi nhấn KEY1) [cite: 182]
    hex_7seg h1(S_accumulator[7:4], HEX1);
    hex_7seg h0(S_accumulator[3:0], HEX0);

endmodule