module prelab3_tn3(
	input logic [3:0] Fract_A,
	input logic [3:0] Fract_B,
	input logic [4:0] Exp_diff,
	output logic [3:0] Bigger_fract,
	output logic [3:0] Smaller_fract
);
always_comb begin
	if (Exp_diff == 5'b0000) begin
		if(Fract_A >= Fract_B) begin
			Bigger_fract = Fract_A; 
			Smaller_fract = Fract_B;
		end
		else begin
			Bigger_fract = Fract_B; 
			Smaller_fract = Fract_A;
		end
	end
	else begin
		if(Exp_diff[4] == 1'b1) begin
				Bigger_fract = Fract_B; 
				Smaller_fract = Fract_A;
		end
		else begin
				Bigger_fract = Fract_A; 
				Smaller_fract = Fract_B;
		end
	end
end
endmodule
