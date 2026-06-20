// --- MODULE TOP-LEVEL CHÍNH THỨC ---
module lab4_tn2 (
    input  logic       MClock, PClock, Resetn, Run,
    output logic       Done,
    output logic [8:0] Bus
);
    // Các sợi dây nội bộ để nối các khối
    logic [4:0] address_wire;
    logic [8:0] data_wire;

    // 1. Cắm Counter
    counter my_counter (
        .MClock(MClock),
        .Resetn(Resetn),
        .Q(address_wire)
    );

    // 2. Cắm Memory (ROM)
    memory_block my_memory (
        .Clock(MClock),
		  .Resetn(Resetn),
        .Address(address_wire),
        .DataOut(data_wire)
    );

    // 3. Cắm Processor đã làm từ trước
    processor my_processor (
        .DIN(data_wire),
        .Resetn(Resetn),
        .Clock(PClock),       // LƯU Ý: Processor dùng PClock!
        .Run(Run),
        .Done(Done),
        .BusWires(Bus)        // Nối dây BusWires của processor ra cổng Bus
    );

endmodule

// --- MODULE MEMORY ---
module memory_block (
    input  logic       Clock, Resetn, // <--- Thêm chân Resetn vào đây
    input  logic [4:0] Address,
    output logic [8:0] DataOut
);
    logic [4:0] addr_reg; 
    logic [8:0] rom [0:31];

    initial begin
        $readmemb("lab4_tn2.mif", rom);
    end

    // Xóa thanh ghi về 0 khi Resetn = 0
    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            addr_reg <= 5'b00000;
        else
            addr_reg <= Address;
    end

    assign DataOut = rom[addr_reg];
endmodule

//D Flip-Flop
module d_ff (
    input  logic clk, resetn, D,
    output logic Q, Qn       // Qn là Q đảo (Not Q)
);
    assign Qn = ~Q; // Tạo dây Q đảo

    // Flip-flop hoạt động ở sườn lên của clock
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) 
            Q <= 1'b0;
        else         
            Q <= D;
    end
endmodule

//COUNTER
module counter (
    input  logic       MClock, Resetn,
    output logic [4:0] Q
);
    // Khai báo bó dây Qn để nối các chân Q đảo
    logic [4:0] Qn; 

    // FF0: Nhận Clock chính từ hệ thống (MClock). Chân D nối vòng lại từ Qn.
    d_ff ff0 (.clk(MClock), .resetn(Resetn), .D(Qn[0]), .Q(Q[0]), .Qn(Qn[0]));

    // FF1: Nhận Clock từ Qn của FF0. Chân D nối vòng lại từ Qn của chính nó.
    d_ff ff1 (.clk(Qn[0]),  .resetn(Resetn), .D(Qn[1]), .Q(Q[1]), .Qn(Qn[1]));

    // FF2: Nhận Clock từ Qn của FF1
    d_ff ff2 (.clk(Qn[1]),  .resetn(Resetn), .D(Qn[2]), .Q(Q[2]), .Qn(Qn[2]));

    // FF3: Nhận Clock từ Qn của FF2
    d_ff ff3 (.clk(Qn[2]),  .resetn(Resetn), .D(Qn[3]), .Q(Q[3]), .Qn(Qn[3]));

    // FF4: Nhận Clock từ Qn của FF3 (Để đủ 5 bit)
    d_ff ff4 (.clk(Qn[3]),  .resetn(Resetn), .D(Qn[4]), .Q(Q[4]), .Qn(Qn[4]));

endmodule

// --- MODULE CHÍNH (Processor) ---
module processor(
    input  logic [8:0] DIN,
    input  logic       Resetn, Clock, Run,
    output logic       Done,
    output logic [8:0] BusWires
);
    // Khai báo các dây nối nội bộ
    logic [8:0] IR;
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, A, G;
    logic [8:0] AddSub_Result;
    logic       IRin, DINout, Ain, Gin, Gout, AddSub;
    logic [7:0] Rin, Rout;

    // 1. Cắm khối Điều khiển (Control Unit)
    control_unit CU (
        .Clock(Clock), .Resetn(Resetn), .Run(Run), .IR(IR),
        .IRin(IRin), .DINout(DINout), .Ain(Ain), .Gin(Gin), 
        .Gout(Gout), .AddSub(AddSub), .Done(Done),
        .Rin(Rin), .Rout(Rout)
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
    regn reg_7 (.R(BusWires), .Rin(Rin[7]), .Resetn(Resetn), .Clock(Clock), .Q(R7));

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
    always_ff @(posedge Clock)
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
        BusWires = DIN;
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
    output logic       IRin, DINout, Ain, Gin, Gout, AddSub, Done,
    output logic [7:0] Rin, Rout
);
    typedef enum logic [1:0] {T0=2'b00, T1=2'b01, T2=2'b10, T3=2'b11} state_t;
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
            T1: if (Done) Tstep_D = T0; else Tstep_D = T2;
            T2: if (Done) Tstep_D = T0; else Tstep_D = T3;
            T3: Tstep_D = T0;
            default: Tstep_D = T0;
        endcase
    end

    // FSM Output Logic
    always_comb begin
        // Khởi tạo mặc định
        IRin = 0; DINout = 0; Ain = 0; Gin = 0; Gout = 0; 
        AddSub = 0; Rin = 8'b0; Rout = 8'b0; Done = 0;

        case (Tstep_Q)
            T0: IRin = 1'b1;
            T1: begin
                case (I)
                    3'b000: begin Rout = Yreg; Rin = Xreg; Done = 1; end // mv
                    3'b001: begin DINout = 1; Rin = Xreg; Done = 1; end  // mvi
                    3'b010, 3'b011: begin Rout = Xreg; Ain = 1; end      // add, sub
                endcase
            end
            T2: begin
                case (I)
                    3'b010: begin Rout = Yreg; Gin = 1; AddSub = 0; end  // add
                    3'b011: begin Rout = Yreg; Gin = 1; AddSub = 1; end  // sub
                endcase
            end
            T3: begin
                case (I)
                    3'b010, 3'b011: begin Gout = 1; Rin = Xreg; Done = 1; end
                endcase
            end
        endcase
    end
endmodule

