module d_ff(
	input rst, clk, D,
	output logic Q
);
 always_ff @(posedge clk)
	begin
	if (~rst)
	Q <= 0;
	else
	Q <= D;
	end
endmodule

module shift_register
(
	input i, clk, rst,
	output L1, L2, L3, L4
);
d_ff D1 (
	.clk(clk),
	.rst(rst),
	.D(i),
	.Q(L1)
);
d_ff D2 (
	.clk(clk),
	.rst(rst),
	.D(L1),
	.Q(L2)
);
d_ff D3 (
	.clk(clk),
	.rst(rst),
	.D(L2),
	.Q(L3)
);
d_ff D4 (
	.clk(clk),
	.rst(rst),
	.D(L3),
	.Q(L4)
);
endmodule

module sequence_detect(
	input [1:0] SW,
	input [0:0] KEY,
	output [8:0] LEDR
);
logic [3:0] a;
logic [3:0] b;
logic c, d;
shift_register SR1 (
	.clk(KEY[0]),
	.rst(SW[0]),
	.i(SW[1]),
	.L1(a[0]),
	.L2(a[1]),
	.L3(a[2]),
	.L4(a[3])

);
shift_register SR2 (
	.clk(KEY[0]),
	.rst(SW[0]),
	.i(~SW[1]),
	.L1(b[0]),
	.L2(b[1]),
	.L3(b[2]),
	.L4(b[3])

);
assign c= a[0] & a[1] & a[2] & a[3];
assign d= b[0] & b[1] & b[2] & b[3];
assign LEDR [8] = c | d;
assign LEDR [3:0] =a;
assign LEDR [7:4] =b;
endmodule