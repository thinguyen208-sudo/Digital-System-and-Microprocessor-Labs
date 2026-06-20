//MODULE CHÍNH
module lab1_tn4(
    input logic clk, // xung clock
    input logic rst, // Nút reset
    input logic [2:0] Sel_op, // Sel nhằm lựa chọn cộng trừ nhân chia
    input logic En_A, // 
    input logic En_B, //
    input logic [7:0] A,
    input logic [7:0] B,
    output logic [7:0] reg_A,
    output logic [7:0] reg_B,
    output logic [15:0] P,
    output logic [15:0] reg_P
);

eight_bit_register Register_A(
    .clk (clk),
    .rst (rst),
    .D (En_A ? A : reg_A),
    .Q (reg_A)
);

eight_bit_register Register_B(
    .clk (clk),
    .rst (rst),
    .D (En_B ? B : reg_B),
    .Q (reg_B)
);

alu ALU(
    .A (reg_A),
    .B (reg_B),
    .Sel_op (Sel_op),
    .P (P)
);

register_16_bit Register_P(
    .clk (clk),
    .rst (rst),
    .D (P),
    .Q (reg_P)
);

endmodule

//CÁC MODULE PHỤ
module alu(
    input logic [7:0] A,
    input logic [7:0] B, 
    input logic [2:0] Sel_op,
    output logic [15:0] P
);

    logic [15:0] p_mult;
    logic [7:0] s_res;
    logic cout_res, v_res;

    // Chỉ dùng 1 bộ cộng/trừ duy nhất
    eight_bit_adder Adder_Unit(
        .A(A),
        .B(B),
        .C_in(Sel_op[0]), // 0 cho cộng, 1 cho trừ
        .S(s_res),
        .C_out(cout_res),
        .V(v_res)
    );

    eight_bit_multiplier Multiplier_Unit(
        .A(A), .B(B), .P(p_mult)
    );

    always_comb begin
        case(Sel_op)
            3'b000, 3'b001: P = {{8{s_res[7]}}, s_res}; // Sign extension
            3'b010:         P = p_mult;
            default:        P = 16'b0;
        endcase
    end
endmodule

module eight_bit_register(
    input logic clk,
    input logic rst,
    input logic [7:0] D,
    output logic [7:0] Q
);

always_ff @( posedge clk or negedge rst ) begin
    if(!rst)
        Q <= 8'b0;
    else 
        Q <= D;   
end
endmodule
module register_16_bit(
    input logic clk,
    input logic rst,
    input logic [15:0] D,
    output logic [15:0] Q
);
always_ff @( posedge clk or negedge rst ) begin
    if(!rst)
        Q <= 16'b0;
    else
        Q <= D;
end
endmodule
module eight_bit_adder(
    input logic [7:0] A,
    input logic [7:0] B,
    input logic C_in,
    output logic [7:0] S,
    output logic C_out,
    output logic V
);

logic [8:0] carry;

full_adder add0(
    .a (A[0]),
    .b (B[0]^C_in),
    .Cin (carry[0]),
    .s (S[0]),
    .Cout (carry[1])
);

full_adder add1(
    .a (A[1]),
    .b (B[1]^C_in),
    .Cin (carry[1]),
    .s (S[1]),
    .Cout (carry[2])
);

full_adder add2(
    .a (A[2]),
    .b (B[2]^C_in),
    .Cin (carry[2]),
    .s (S[2]),
    .Cout (carry[3])
);

full_adder add3(
    .a (A[3]),
    .b (B[3]^C_in),
    .Cin (carry[3]),
    .s (S[3]),
    .Cout (carry[4])
);

full_adder add4(
    .a (A[4]),
    .b (B[4]^C_in),
    .Cin (carry[4]),
    .s (S[4]),
    .Cout (carry[5])
);

full_adder add5(
    .a (A[5]),
    .b (B[5]^C_in),
    .Cin (carry[5]),
    .s (S[5]),
    .Cout (carry[6])
);

full_adder add6(
    .a (A[6]),
    .b (B[6]^C_in),
    .Cin (carry[6]),
    .s (S[6]),
    .Cout (carry[7])
);

full_adder add7(
    .a (A[7]),
    .b (B[7]^C_in),
    .Cin (carry[7]),
    .s (S[7]),
    .Cout (carry[8])
);

assign carry[0] = C_in;
assign C_out = carry[8];
assign V = carry[8] ^ carry[7];

endmodule
module full_adder(
    input a, b, Cin,
    output s, Cout
);
assign s = a^b^Cin;
assign Cout = a&b | (a^b)&Cin;
endmodule
module eight_bit_multiplier(
    input logic [7:0] A,
    input logic [7:0] B,
    output logic [15:0] P 
);

logic [7:0] sub_Sum0;
logic [7:0] sub_Sum1;
logic [7:0] sub_Sum2;
logic [7:0] sub_Sum3;
logic [7:0] sub_Sum4;
logic [7:0] sub_Sum5;
logic [7:0] sub_Sum6;

logic Cout0;
logic Cout1;
logic Cout2;
logic Cout3;
logic Cout4;
logic Cout5;
logic Cout6;

logic V0;
logic V1;
logic V2;
logic V3;
logic V4;
logic V5;
logic V6;

eight_bit_adder sub_add0(
    .A (A[7:1] & {8{B[0]}}),
    .B (A[7:0] & {8{B[1]}}),
    .C_in (0),
    .S (sub_Sum0),
    .C_out (Cout0),
    .V (V0)
);
assign P[0] = A[0] & B[0];
assign P[1] = sub_Sum0[0];

eight_bit_adder sub_add1(
    .A ({Cout0, sub_Sum0[7:1]}),
    .B (A[7:0] & {8{B[2]}}),
    .C_in (0),
    .S (sub_Sum1),
    .C_out (Cout1),
    .V (V1)
);
assign P[2] = sub_Sum1[0];

eight_bit_adder sub_add2(
    .A ({Cout1, sub_Sum1[7:1]}),
    .B (A[7:0] & {8{B[3]}}),
    .C_in (0),
    .S (sub_Sum2),
    .C_out (Cout2),
    .V (V2)
);
assign P[3] = sub_Sum2[0];

eight_bit_adder sub_add3(
    .A ({Cout2, sub_Sum2[7:1]}),
    .B (A[7:0] & {8{B[4]}}),
    .C_in (0),
    .S (sub_Sum3),
    .C_out (Cout3),
    .V (V3)
);
assign P[4] = sub_Sum3[0];

eight_bit_adder sub_add4(
    .A ({Cout3, sub_Sum3[7:1]}),
    .B (A[7:0] & {8{B[5]}}),
    .C_in (0),
    .S (sub_Sum4),
    .C_out (Cout4),
    .V (V4)
);
assign P[5] = sub_Sum4[0];

eight_bit_adder sub_add5(
    .A ({Cout4, sub_Sum4[7:1]}),
    .B (A[7:0] & {8{B[6]}}),
    .C_in (0),
    .S (sub_Sum5),
    .C_out (Cout5),
    .V (V5)
);
assign P[6] = sub_Sum5[0];

eight_bit_adder sub_add6(
    .A ({Cout5, sub_Sum5[7:1]}),
    .B (A[7:0] & {8{B[7]}}),
    .C_in (0),
    .S (sub_Sum6),
    .C_out (Cout6),
    .V (V6)
);
assign P[15:7] = {Cout6, sub_Sum6};

endmodule



