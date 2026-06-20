module prelab3_tn5(
	input logic [4:0] Exp_diff,
	input logic [3:0] Fract_A,
	input logic [3:0] Fract_B,
	input logic  sign_A,
	input logic  sign_B,
	output logic Result_sign
);

always_comb begin
	if (Exp_diff[4] == 1'b1) begin
		Result_sign = sign_B;
	end
	else if(Exp_diff != 5'b0000) begin
		Result_sign = sign_A;
	end
	else begin
		if(Fract_B > Fract_A) begin
			 Result_sign = sign_B;
		end
		else begin
			Result_sign = sign_A;
		end
	end
end
endmodule
	

