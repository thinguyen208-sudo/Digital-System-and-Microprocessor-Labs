module prelab3_tn1(
	input logic [3:0] Exp_A,
	input logic [3:0] Exp_B,
	output logic [4:0] Exp_diff,
	output logic [3:0] Final_exp
);

assign Exp_diff = {1'b0, Exp_A} - {1'b0, Exp_B};

assign Final_exp = (Exp_diff[4] == 1'b1) ? Exp_B: Exp_A;

endmodule