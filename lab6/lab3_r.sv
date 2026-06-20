module lab3_r(
	input logic [8:0] A,
	input logic [8:0] B,
	input logic 		S,
	output logic [8:0] Result,
	output logic z,
	output logic OV
);
	//Tách làm 3 phần là sign, frac, exp
	logic sign_A;
	logic [3:0] exp_A;
	logic [3:0] frac_A;
	
	logic sign_B;
	logic [3:0] exp_B;
	logic [3:0] frac_B;
	
	assign sign_A = A[8];
	assign sign_B = B[8];
	assign exp_A  = A[7:4];
	assign exp_B  = B[7:4];
	assign frac_A = A[3:0];
	assign frac_B = B[3:0];

	// --- BƯỚC 2: Xử lý phép Trừ --- 
    // Nếu S=1 (Trừ), đảo dấu của B. Nếu S=0 (Cộng), giữ nguyên dấu của B.
   logic eff_sign_B;
   assign eff_sign_B = sign_B ^ S;
	
	logic [4:0] w_exp_diff; //Thêm 1 bit
	// logic [2:0] w_Smaller_exp;
   logic [3:0] w_final_exp_temp;//Thêm 1 bit
   logic [3:0] w_bigger_frac;
   logic [3:0] w_smaller_frac;
   logic [5:0] w_shifted_frac;
   logic [3:0] w_result_frac;
   logic [3:0] w_result_exp;//Thêm 1 bit
   logic       w_result_sign;
	
	prelab3_tn1 u1(
		.Exp_A(exp_A),
		.Exp_B(exp_B),
		.Exp_diff(w_exp_diff),
		// .Smaller_exp(w_Smaller_exp),
		.Final_exp(w_final_exp_temp)
);
	prelab3_tn3 u3(
		.Fract_A(frac_A),
		.Fract_B(frac_B),
		.Exp_diff(w_exp_diff),
		.Bigger_fract(w_bigger_frac),
		.Smaller_fract(w_smaller_frac)
);

	prelab3_tn2 u2 (
       .Smaller_fract(w_smaller_frac),
		 //.Smaller_exp(w_Smaller_exp),
       .Exp_diff(w_exp_diff), 
       .Shifted_fract(w_shifted_frac)
);
	//	Put the + - of the S into the sign of the B
	logic  eff_sign;
	assign eff_sign = sign_A ^ eff_sign_B;
	
	//Extent the bigger_frac to 6 bit. to match with the shifter_frac
	logic  [5:0] bigger_frac_6b;
	assign bigger_frac_6b = {1'b0, 1'b1, w_bigger_frac};
	
	logic [5:0] w_Temp_fract;
	assign w_Temp_fract = (eff_sign == 1'b1)? (bigger_frac_6b - w_shifted_frac) : (bigger_frac_6b + w_shifted_frac);
	
	prelab3_tn4 u4(
		.Temp_fract(w_Temp_fract),
		.Final_exp(w_final_exp_temp),
		.Result_fract(w_result_frac),
		.Result_exp(w_result_exp)
	);
	
	prelab3_tn5 u5(
		.Exp_diff(w_exp_diff),
		.Fract_A(frac_A),
		.Fract_B(frac_B),
		.sign_A(sign_A),
		.sign_B(eff_sign_B),
		.Result_sign(w_result_sign)
	);
	
	//Assign the 0 result
	assign z = (w_Temp_fract == 6'b000000) ? 1'b1: 1'b0;
	
	//Assign the overflow result
	assign OV = (w_final_exp_temp == 3'd7) || (w_final_exp_temp == 3'd6 && w_Temp_fract[5] == 1'b1) ? 1'b1 : 1'b0;
	
	assign Result = (z == 1'b1) ? 8'b00000000 : {w_result_sign, w_result_exp, w_result_frac};

endmodule
	
	
	