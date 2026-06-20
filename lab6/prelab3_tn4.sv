module prelab3_tn4 (
    input  logic [5:0] Temp_fract,  // 6-bit intermediate fraction
    input  logic [3:0] Final_exp,   // Original exponent from larger operand
    output logic [3:0] Result_fract, // 4-bit normalized fraction
    output logic [3:0] Result_exp    // 4-bit normalized exponent
);

    // Use a priority logic to find the leading '1'
    // This structure helps RTL Viewer create a cleaner Encoder block
    always_comb begin
        if (Temp_fract[5]) begin 
            // CASE: Overflow (Carry-out) -> Shift right, Exponent + 1
            Result_fract = Temp_fract[4:1];
            Result_exp   = Final_exp + 4'd1;
        end
        else if (Temp_fract[4]) begin 
            // CASE: Already Normalized -> No shift, Exponent stays same
            Result_fract = Temp_fract[3:0];
            Result_exp   = Final_exp;
        end
        else if (Temp_fract[3]) begin 
            // CASE: Shift left 1, Exponent - 1
            Result_fract = {Temp_fract[2:0], 1'b0};
            Result_exp   = Final_exp - 4'd1;
        end
        else if (Temp_fract[2]) begin 
            // CASE: Shift left 2, Exponent - 2
            Result_fract = {Temp_fract[1:0], 2'b00};
            Result_exp   = Final_exp - 4'd2;
        end
        else if (Temp_fract[1]) begin 
            // CASE: Shift left 3, Exponent - 3
            Result_fract = {Temp_fract[0], 3'b000};
            Result_exp   = Final_exp - 4'd3;
        end
        else if (Temp_fract[0]) begin 
            // CASE: Shift left 4, Result fraction becomes 0
            Result_fract = 4'b0000;
            Result_exp   = Final_exp - 4'd4;
        end
        else begin 
            // CASE: Default/Zero -> Reset output
            Result_fract = 4'b0000;
            Result_exp   = 4'd0;
        end
    end

endmodule