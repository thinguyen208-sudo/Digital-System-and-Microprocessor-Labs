// ==============================================================================
// MODULE 1: TOP LEVEL PROCESSOR (lab6)
// ==============================================================================
module lab6 #(parameter n = 9)(
    input  logic [8:0] DIN,
    input  logic       Resetn, Clock, Run,
    output logic       Done,
    output logic [8:0] BusWires, // Giữ lại để xem waveform
    output logic [n-1:0] ADDR,
    output logic [n-1:0] DOUT,
    output logic       W
);
    // --------------------------------------------------------------------------
    // Khai báo dây nối nội bộ
    // --------------------------------------------------------------------------
    logic [8:0] IR;
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G;
    logic [8:0] AddSub_Result;
    logic       IRin, DINout, Ain, Gin, AddSub;
    logic [7:0] Rin, Rout;
    logic       ADDRin, DOUTin, W_D, incr_pc;
    logic       G_not_zero;

    // FPU Signals
    logic [8:0] AF, GF;              // Thanh ghi cho FPU
    logic       AFin, GFin, AddSubF; // Tín hiệu điều khiển FPU
    logic [1:0] Gout;                // Nâng cấp Gout lên 2-bit
    logic [8:0] AddSub_Result_F;

    // --------------------------------------------------------------------------
    // Logic phụ trợ
    // --------------------------------------------------------------------------
    // Kiểm tra G != 0 cho lệnh mvnz
    assign G_not_zero = (G != 9'b000000000);
    
    // Mạch đồng bộ 2 tầng cho chân Run (Chống Metastability)
    logic run_sync_1, run_sync_2;
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn) begin
            run_sync_1 <= 1'b0;
            run_sync_2 <= 1'b0;
        end else begin
            run_sync_1 <= Run;
            run_sync_2 <= run_sync_1;
        end
    end
    
    // Flip-flop W: Chốt cờ Write (1 bit)
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            W <= 1'b0;  
        else
            W <= W_D;   
    end

    // --------------------------------------------------------------------------
    // Kết nối các khối (Instantiations)
    // --------------------------------------------------------------------------
    // 1. Khối Điều khiển (Control Unit)
    control_unit CU (
        .Clock(Clock), 
        .Resetn(Resetn), 
        .Run(run_sync_2), 
        .IR(IR),
        .G_not_zero(G_not_zero),
        .IRin(IRin), 
        .DINout(DINout), 
        .Ain(Ain), 
        .Gin(Gin), 
        .AFin(AFin), 
        .GFin(GFin), 
        .Gout(Gout), 
        .AddSub(AddSub), 
        .AddSubF(AddSubF), 
        .Done(Done),
        .Rin(Rin), 
        .Rout(Rout),
        .ADDRin(ADDRin),
        .DOUTin(DOUTin),
        .W_D(W_D),
        .incr_pc(incr_pc)
    );
    
    // 2. Các thanh ghi cơ bản & Memory
    regn reg_IR   (.R(DIN),      .Rin(IRin),   .Resetn(Resetn), .Clock(Clock), .Q(IR));
    regn reg_ADDR (.R(BusWires), .Rin(ADDRin), .Resetn(Resetn), .Clock(Clock), .Q(ADDR));
    regn reg_DOUT (.R(BusWires), .Rin(DOUTin), .Resetn(Resetn), .Clock(Clock), .Q(DOUT));

    // 3. Thanh ghi đa dụng (R0 - R6)
    regn reg_0 (.R(BusWires), .Rin(Rin[0]), .Resetn(Resetn), .Clock(Clock), .Q(R0));
    regn reg_1 (.R(BusWires), .Rin(Rin[1]), .Resetn(Resetn), .Clock(Clock), .Q(R1));
    regn reg_2 (.R(BusWires), .Rin(Rin[2]), .Resetn(Resetn), .Clock(Clock), .Q(R2));
    regn reg_3 (.R(BusWires), .Rin(Rin[3]), .Resetn(Resetn), .Clock(Clock), .Q(R3));
    regn reg_4 (.R(BusWires), .Rin(Rin[4]), .Resetn(Resetn), .Clock(Clock), .Q(R4));
    regn reg_5 (.R(BusWires), .Rin(Rin[5]), .Resetn(Resetn), .Clock(Clock), .Q(R5));
    regn reg_6 (.R(BusWires), .Rin(Rin[6]), .Resetn(Resetn), .Clock(Clock), .Q(R6));
    
    // Program Counter (R7)
    pc_register pc_reg_7 (
        .R(BusWires), 
        .R7in(Rin[7]),     
        .incr_pc(incr_pc),  
        .Clock(Clock), 
        .Resetn(Resetn), 
        .Q(R7)
    );

    // 4. Thanh ghi cho ALU & FPU
    regn reg_A  (.R(BusWires),      .Rin(Ain),  .Resetn(Resetn), .Clock(Clock), .Q(A));
    regn reg_G  (.R(AddSub_Result), .Rin(Gin),  .Resetn(Resetn), .Clock(Clock), .Q(G));
    regn reg_AF (.R(BusWires),      .Rin(AFin), .Resetn(Resetn), .Clock(Clock), .Q(AF));
    regn reg_GF (.R(AddSub_Result_F), .Rin(GFin), .Resetn(Resetn), .Clock(Clock), .Q(GF));

    // 5. Khối tính toán (ALU & FPU)
    alu ALU_unit (
        .A(A), .BusWires(BusWires), .AddSub(AddSub), .Result(AddSub_Result)
    );

    lab3_r FPU_unit (
        .A(AF), 
        .B(BusWires), 
        .S(AddSubF), 
        .Result(AddSub_Result_F),
        .z(),   
        .OV()   
    );
    
    // 6. Bộ Dồn kênh (Multiplexer)
    multiplexer MUX_unit (
        .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .G(G), .GF(GF), .DIN(DIN),
        .Rout(Rout), .DINout(DINout), .Gout(Gout),
        .BusWires(BusWires)
    );

endmodule

// ==============================================================================
// MODULE 2: PROGRAM COUNTER (R7)
// ==============================================================================
module pc_register #(parameter n = 9)(
    input  logic [n-1:0] R,         
    input  logic         R7in,      
    input  logic         incr_pc,   
    input  logic         Clock, Resetn,
    output logic [n-1:0] Q          
);
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn) 
            Q <= '0;                
        else if (R7in) 
            Q <= R;                 
        else if (incr_pc) 
            Q <= Q + 1'b1;          
    end
endmodule

// ==============================================================================
// MODULE 3: DECODER 3-TO-8
// ==============================================================================
module dec3to8(
    input  logic [2:0] W,
    input  logic       En,
    output logic [7:0] Y  
);
    always_comb begin
        if (En == 1'b1)
            case (W)
                3'b000: Y = 8'b00000001;
                3'b001: Y = 8'b00000010;
                3'b010: Y = 8'b00000100;
                3'b011: Y = 8'b00001000;
                3'b100: Y = 8'b00010000;
                3'b101: Y = 8'b00100000;
                3'b110: Y = 8'b01000000;
                3'b111: Y = 8'b10000000;
            endcase
        else 
            Y = 8'b00000000;
    end
endmodule

// ==============================================================================
// MODULE 4: N-BIT REGISTER
// ==============================================================================
module regn #(parameter n = 9)(
    input  logic [n-1:0] R,
    input  logic         Rin, Clock, Resetn,
    output logic [n-1:0] Q
);
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn) 
            Q <= '0;            
        else if (Rin) 
            Q <= R;
    end
endmodule

// ==============================================================================
// MODULE 5: ALU
// ==============================================================================
module alu (
    input  logic [8:0] A,
    input  logic [8:0] BusWires,
    input  logic       AddSub,
    output logic [8:0] Result
);
    always_comb begin
        if (AddSub)
            Result = A - BusWires; 
        else
            Result = A + BusWires; 
    end
endmodule

// ==============================================================================
// MODULE 6: MULTIPLEXER
// ==============================================================================
module multiplexer (
    input  logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7,
    input  logic [8:0] G, GF, DIN,
    input  logic [7:0] Rout,
    input  logic       DINout,
    input  logic [1:0] Gout,
    output logic [8:0] BusWires
);
    always_comb begin
        BusWires = 9'b000000000; // Mặc định
        
        if (DINout)             BusWires = DIN;
        else if (Gout == 2'b10) BusWires = G;  
        else if (Gout == 2'b01) BusWires = GF; 
        else if (Rout[0])       BusWires = R0;
        else if (Rout[1])       BusWires = R1;
        else if (Rout[2])       BusWires = R2;
        else if (Rout[3])       BusWires = R3;
        else if (Rout[4])       BusWires = R4;
        else if (Rout[5])       BusWires = R5;
        else if (Rout[6])       BusWires = R6;
        else if (Rout[7])       BusWires = R7;
    end
endmodule

// ==============================================================================
// MODULE 7: CONTROL UNIT (FSM)
// ==============================================================================
module control_unit (
    input  logic       Clock, Resetn, Run,
    input  logic [8:0] IR,
    input  logic       G_not_zero,
    output logic       IRin, DINout, Ain, Gin, GFin, AFin, AddSub, AddSubF, Done,
    output logic [1:0] Gout, 
    output logic [7:0] Rin, Rout,
    output logic       ADDRin, DOUTin, W_D, incr_pc
);
    typedef enum logic [2:0] {T0=3'd0, T1=3'd1, T2=3'd2, T3=3'd3, T4=3'd4, T5=3'd5, T6=3'd6} state_t;
    state_t Tstep_Q, Tstep_D;

    // Phân rã mã lệnh
    logic [2:0] I;
    logic [7:0] Xreg, Yreg;
    assign I = IR[8:6];
    
    dec3to8 decX (.W(IR[5:3]), .En(1'b1), .Y(Xreg));
    dec3to8 decY (.W(IR[2:0]), .En(1'b1), .Y(Yreg));

    // FSM State Register
    always_ff @(posedge Clock, negedge Resetn) begin
        if (!Resetn) Tstep_Q <= T0;
        else         Tstep_Q <= Tstep_D;
    end

    // FSM Next State Logic
    always_comb begin
        case (Tstep_Q)
            T0: if (!Run) Tstep_D = T0; else Tstep_D = T1;
            T1: Tstep_D = T2;
            T2: Tstep_D = T3;
            T3: if (Done) Tstep_D = T0; else Tstep_D = T4;
            T4: if (Done) Tstep_D = T0; else Tstep_D = T5; 
            T5: if (Done) Tstep_D = T0; else Tstep_D = T6;
            T6: Tstep_D = T0;
            default: Tstep_D = T0;
        endcase
    end

    // FSM Output Logic
    always_comb begin
        // Khởi tạo mặc định
        IRin = 0; DINout = 0; Ain = 0; Gin = 0; Gout = 2'b00; 
        AFin = 0; GFin = 0; AddSub = 0; AddSubF = 0;
        Rin = 8'b0; Rout = 8'b0; Done = 0;
        ADDRin = 0; DOUTin = 0; W_D = 0; incr_pc = 0;

        case (Tstep_Q)
            T0: begin 
                Rout[7] = 1'b1;  
                ADDRin  = 1'b1;  
            end
            T1: begin
                // NHỊP CHỜ RAM
            end
            T2: begin
                IRin    = 1'b1;  
                incr_pc = 1'b1;  
            end

            T3: begin
                case (I)
                    3'b000: begin Rout = Yreg; Rin = Xreg; Done = 1; end 
                    3'b001: begin Rout[7] = 1'b1; ADDRin = 1'b1; end     
                    3'b010, 
                    3'b011: begin Rout = Xreg; Ain = 1; end              
                    3'b111: begin Rout = Xreg; AFin = 1; end             
                    3'b100: begin Rout = Yreg; ADDRin = 1'b1; end        
                    3'b101: begin Rout = Yreg; ADDRin = 1'b1; end        
                    3'b110: begin 
                        if (G_not_zero) begin 
                            Rout = Yreg; 
                            Rin = Xreg; 
                        end
                        Done = 1;
                    end
                endcase
            end

            T4: begin
                case (I)
                    3'b001: ; 
                    3'b010: begin Rout = Yreg; Gin = 1; AddSub = 0; end  
                    3'b011: begin Rout = Yreg; Gin = 1; AddSub = 1; end  
                    3'b111: begin Rout = Yreg; GFin = 1; AddSubF = 0; end 
                    3'b100: ; 
                    3'b101: begin Rout = Xreg; DOUTin = 1'b1; end        
                endcase
            end

            T5: begin
                case (I)
                    3'b001: begin DINout = 1; Rin = Xreg; incr_pc = 1; Done = 1; end 
                    3'b010, 
                    3'b011: begin Gout = 2'b10; Rin = Xreg; Done = 1; end        
                    3'b111: begin Gout = 2'b01; Rin = Xreg; Done = 1; end            
                    3'b100: begin DINout = 1; Rin = Xreg; Done = 1; end              
                    3'b101: begin W_D = 1'b1; end                                    
                endcase
            end

            T6: begin
                case (I)
                    3'b101: begin Done = 1; end 
                endcase
            end
        endcase
    end
endmodule