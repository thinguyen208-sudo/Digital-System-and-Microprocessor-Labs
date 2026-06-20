// --- MODULE CHÍNH (Processor) ---
module lab5 #(parameter n = 9)(
    input  logic [8:0] DIN,
    input  logic       Resetn, Clock, Run,
    output logic       Done,
    output logic [8:0] BusWires, // Giữ lại đây để xem waveform
    output logic [n-1:0] ADDR,
    output logic [n-1:0] DOUT,
    output logic       W
);
    // Khai báo TẤT CẢ dây nối nội bộ lên TRÊN CÙNG
    logic [8:0] IR;
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G;
    logic [8:0] AddSub_Result;
    logic       IRin, DINout, Ain, Gin, Gout, AddSub;
    logic [7:0] Rin, Rout;
    logic       ADDRin, DOUTin, W_D, incr_pc;
    logic       G_not_zero;

    // Logic kiểm tra G
    assign G_not_zero = (G != 9'b000000000);
	 
	 // Thêm mạch đồng bộ 2 tầng cho chân Run
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
	 
    // 1. Cắm khối Điều khiển (Control Unit)
    control_unit CU (
        .Clock(Clock), 
		  .Resetn(Resetn), 
		  .Run(run_sync_2), 
		  .IR(IR),
        .IRin(IRin), 
		  .DINout(DINout), 
		  .Ain(Ain), 
		  .Gin(Gin), 
        .Gout(Gout), 
		  .AddSub(AddSub), 
		  .Done(Done),
        .Rin(Rin), 
		  .Rout(Rout),
        .ADDRin(ADDRin),
        .DOUTin(DOUTin),
        .W_D(W_D),
        .G_not_zero(G_not_zero),
        .incr_pc(incr_pc) // Đã sửa lỗi chính tả incrpc
    );
	 

    // 2. Cắm thanh ghi IR
    regn reg_IR (.R(DIN), .Rin(IRin), .Resetn(Resetn), .Clock(Clock), .Q(IR));

    // 3. Cắm 8 thanh ghi đa dụng R0 -> R7
    regn reg_0 (.R(BusWires), .Rin(Rin[0]), .Resetn(Resetn), .Clock(Clock), .Q(R0));
    regn reg_1 (.R(BusWires), .Rin(Rin[1]), .Resetn(Resetn), .Clock(Clock), .Q(R1));
    regn reg_2 (.R(BusWires), .Rin(Rin[2]), .Resetn(Resetn), .Clock(Clock), .Q(R2));
    regn reg_3 (.R(BusWires), .Rin(Rin[3]), .Resetn(Resetn), .Clock(Clock), .Q(R3));
    regn reg_4 (.R(BusWires), .Rin(Rin[4]), .Resetn(Resetn), .Clock(Clock), .Q(R4));
    regn reg_5 (.R(BusWires), .Rin(Rin[5]), .Resetn(Resetn), .Clock(Clock), .Q(R5));
    regn reg_6 (.R(BusWires), .Rin(Rin[6]), .Resetn(Resetn), .Clock(Clock), .Q(R6));
   
    
    pc_register pc_reg_7 (
        .R(BusWires), 
        .R7in(Rin[7]),     
        .incr_pc(incr_pc),  // count wire
        .Clock(Clock), 
        .Resetn(Resetn), 
        .Q(R7)
    );
	 
	 
	 // Thanh ghi ADDR: Chốt địa chỉ từ Bus ra ngoài
    regn reg_ADDR (
        .R(BusWires), 
        .Rin(ADDRin), 
        .Resetn(Resetn), 
        .Clock(Clock), 
        .Q(ADDR)
    );

    // Thanh ghi DOUT: Chốt dữ liệu từ Bus ra ngoài
    regn reg_DOUT (
        .R(BusWires), 
        .Rin(DOUTin), 
        .Resetn(Resetn), 
        .Clock(Clock), 
        .Q(DOUT)
    );

    // Flip-flop W: Chốt cờ Write (1 bit)
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            W <= 1'b0;  // Vừa bật máy là không cho ghi lung tung
        else
            W <= W_D;   // Lấy lệnh từ khối FSM cất vào
    end

    // 4. Cắm thanh ghi A và G
    regn reg_A (.R(BusWires),      .Rin(Ain), .Resetn(Resetn), .Clock(Clock), .Q(A));
    regn reg_G (.R(AddSub_Result), .Rin(Gin), .Resetn(Resetn), .Clock(Clock), .Q(G));

    // 5. Cắm bộ Tính toán (ALU)
    alu ALU_unit (
        .A(A), .BusWires(BusWires), .AddSub(AddSub), .Result(AddSub_Result)
    );

    // 6. Cắm bộ Dồn kênh (Multiplexer) để tạo ra Bus
    multiplexer MUX_unit (
        .R0(R0), .R1(R1), .R2(R2), .R3(R3), .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .G(G), .DIN(DIN),
        .Rout(Rout), .Gout(Gout), .DINout(DINout),
        .BusWires(BusWires)
    );

endmodule


// --- MODULE PROGRAM COUNTER (R7) ---
module pc_register #(parameter n = 9)(
    input  logic [n-1:0] R,         // Dữ liệu từ Bus (để nạp địa chỉ khi nhảy/lặp)
    input  logic         R7in,      // Cờ cho phép nạp dữ liệu từ Bus vào R7
    input  logic         incr_pc,   // Cờ cho phép R7 tự đếm lên 1
    input  logic         Clock, Resetn,
    output logic [n-1:0] Q          // Đầu ra (chứa địa chỉ hiện tại)
);
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn) 
            Q <= '0;                // Mới bật máy lên, PC tự động chỉ về dòng số 0
        else if (R7in) 
            Q <= R;                 // Ưu tiên 1: Lệnh nhảy! Nạp địa chỉ mới từ Bus vào
        else if (incr_pc) 
            Q <= Q + 1'b1;          // Ưu tiên 2: Không có lệnh nhảy thì tự động nhích xuống 1 dòng
    end
endmodule


// --- MODULE GIẢI MÃ ĐÃ SỬA LỖI NGƯỢC BIT ---
module dec3to8(
    input  logic [2:0] W,
    input  logic       En,
    output logic [7:0] Y  
);
    always_comb begin
        if (En == 1)
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
        else Y = 8'b00000000;
    end
endmodule

// --- MODULE THANH GHI (Register) ---
module regn #(parameter n = 9)(
    input  logic [n-1:0] R,
    input  logic         Rin, Clock, Resetn,
    output logic [n-1:0] Q
);
    always_ff @(posedge Clock or negedge Resetn)
	 if (!Resetn) 
            Q <= '0;			
    else if (Rin) 
				Q <= R;
endmodule

// --- MODULE ALU ---
module alu (
    input  logic [8:0] A,
    input  logic [8:0] BusWires,
    input  logic       AddSub,
    output logic [8:0] Result
);
    always_comb begin
        if (AddSub)
            Result = A - BusWires; // AddSub = 1 thì trừ
        else
            Result = A + BusWires; // AddSub = 0 thì cộng
    end
endmodule


// --- MODULE MULTIPLEXER ---
module multiplexer (
    input  logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7,
    input  logic [8:0] G, DIN,
    input  logic [7:0] Rout,
    input  logic       Gout, DINout,
    output logic [8:0] BusWires
);
    always_comb begin
		  BusWires = 9'b000000000;
      //BusWires = 9'b0; // Mặc định để tránh sinh ra Latch
        if (DINout)       BusWires = DIN;
        else if (Gout)    BusWires = G;
        else if (Rout[0]) BusWires = R0;
        else if (Rout[1]) BusWires = R1;
        else if (Rout[2]) BusWires = R2;
        else if (Rout[3]) BusWires = R3;
        else if (Rout[4]) BusWires = R4;
        else if (Rout[5]) BusWires = R5;
        else if (Rout[6]) BusWires = R6;
        else if (Rout[7]) BusWires = R7;
    end
endmodule

//---CONTROL UNIT---
module control_unit (
	 input  logic       Clock, Resetn, Run,
    input  logic [8:0] IR,
    input  logic       G_not_zero,     // NEW: Cờ báo G != 0 (từ bên ngoài truyền vào)
    output logic       IRin, DINout, Ain, Gin, Gout, AddSub, Done,
    output logic [7:0] Rin, Rout,
    // NEW
    output logic       ADDRin, DOUTin, W_D, incr_pc
);
	 //Tăng lên 3-bit để chứa đủ 7 trạng thái (T0 đến T6)
    typedef enum logic [2:0] {T0=3'd0, T1=3'd1, T2=3'd2, T3=3'd3, T4=3'd4, T5=3'd5, T6=3'd6} state_t;
    state_t Tstep_Q, Tstep_D;

    // Phân rã mã lệnh
    logic [2:0] I;
    logic [7:0] Xreg, Yreg;
    assign I = IR[8:6];
    
    // Gọi module Decoder giải mã Rx và Ry
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
		  IRin = 0; DINout = 0; Ain = 0; Gin = 0; Gout = 0; 
        AddSub = 0; Rin = 8'b0; Rout = 8'b0; Done = 0;
        ADDRin = 0; DOUTin = 0; W_D = 0; incr_pc = 0;

case (Tstep_Q)

            // ---------------------------------------------------------
            // QUY TRÌNH ĐỌC LỆNH (FETCH) - 3 NHỊP
            // ---------------------------------------------------------
            T0: begin 
                Rout[7] = 1'b1;  // Mở cửa R7 (PC) đẩy địa chỉ ra Bus
                ADDRin  = 1'b1;  // Chốt vào ADDR gửi cho RAM
            end
            T1: begin
                // NHỊP CHỜ (WAIT STATE): Để cục RAM đồng bộ kịp nuốt địa chỉ 
            end
            T2: begin
                IRin    = 1'b1;  // RAM nhả dữ liệu, hút mã lệnh vào IR
                incr_pc = 1'b1;  // Lấy xong thì PC đếm lên 1
            end

            // ---------------------------------------------------------
            // QUY TRÌNH THỰC THI (EXECUTE)
            // ---------------------------------------------------------
            T3: begin
                case (I)
                    3'b000: begin Rout = Yreg; Rin = Xreg; Done = 1; end // mv Rx, Ry
                    3'b001: begin Rout[7] = 1'b1; ADDRin = 1'b1; end     // mvi: Đưa PC ra ADDR để lấy Dữ liệu
                    3'b010, 3'b011: begin Rout = Xreg; Ain = 1; end      // add, sub: Đưa Rx vào A
                    3'b100: begin Rout = Yreg; ADDRin = 1'b1; end        // ld Rx, [Ry]: Đưa Ry (địa chỉ) ra ADDR
                    3'b101: begin Rout = Yreg; ADDRin = 1'b1; end        // st Rx, [Ry]: Đưa Ry (địa chỉ) ra ADDR
                    3'b110: begin // mvnz Rz, Ry
                        if (G_not_zero) begin 
                            Rout = Yreg; 
                            Rin = Xreg; // Bộ giải mã sẽ tự lo việc bật đúng R7in
                        end
                        Done = 1;
                    end
                endcase
            end

            T4: begin
                case (I)
                    3'b001: ; // mvi: NHỊP CHỜ RAM
                    3'b010: begin Rout = Yreg; Gin = 1; AddSub = 0; end  // add
                    3'b011: begin Rout = Yreg; Gin = 1; AddSub = 1; end  // sub
                    3'b100: ; // ld: NHỊP CHỜ RAM
                    3'b101: begin Rout = Xreg; DOUTin = 1'b1; end        // st: Đưa Rx (dữ liệu) vào DOUT
                endcase
            end

            T5: begin
                case (I)
                    3'b001: begin DINout = 1; Rin = Xreg; incr_pc = 1; Done = 1; end // mvi: Hút Data, TĂNG PC LẦN 2!
                    3'b010, 3'b011: begin Gout = 1; Rin = Xreg; Done = 1; end        // add, sub
                    3'b100: begin DINout = 1; Rin = Xreg; Done = 1; end              // ld: Hút Data từ RAM vào Rx
                    3'b101: begin W_D = 1'b1; end                                    // st: Bật cờ W lên 1
                endcase
            end

            T6: begin
                case (I)
                    // st: Kéo dài thêm 1 nhịp để RAM kịp thấy cờ W=1 rồi mới kết thúc lệnh
                    3'b101: begin Done = 1; end 
                endcase
            end
        endcase
    end
endmodule

