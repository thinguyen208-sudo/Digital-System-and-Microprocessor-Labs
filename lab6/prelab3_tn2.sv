module prelab3_tn2(
	input logic  [3:0] Smaller_fract,
	input logic  [4:0] Exp_diff,
	output logic [5:0] Shifted_fract
);
//Because exp_diff can be positive or negative ==> change to positive

logic [4:0] shifted_val;

always_comb begin
	shifted_val = (Exp_diff[4] == 1)? - Exp_diff: Exp_diff;
	case (shifted_val)
		5'd0: Shifted_fract = {1'b0, 1'b1, Smaller_fract};
		5'd1: Shifted_fract = {2'b00, 1'b1, Smaller_fract[3:1]};
		5'd2: Shifted_fract = {3'b000, 1'b1, Smaller_fract[3:2]};
		5'd3: Shifted_fract = {4'b0000, 1'b1, Smaller_fract[3:3]};
		5'd4: Shifted_fract = {5'b00000, 1'b1};
		default: Shifted_fract = {6'b000000};
	endcase
end

endmodule