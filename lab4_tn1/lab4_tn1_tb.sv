module lab4_tn1_tb();

    // 1. Parameters and Signals
    logic [8:0] DIN;
    logic Resetn; 
    logic Clock; 
    logic Run;
    logic Done;
    logic [8:0] BusWires;

    // 2. Instantiate the Design Under Test (DUT)
    lab4_tn1 dut (  // <-- Đổi tên gọi module cho khớp code cũ của bạn
        .DIN(DIN),
        .Resetn(Resetn), 
        .Clock(Clock), 
        .Run(Run),
        .Done(Done),
        .BusWires (BusWires)
    );

    // 3. Clock Generation (10ns period)
    always #5 Clock = ~Clock;

    // 4. Stimulus Procedure
    initial begin
        // Initialize signals
        Clock = 0;
        Resetn = 0;
        Run = 0;
        DIN = 9'b0;
        #10;
        
        Resetn = 1;
        Run = 1;
        DIN = 9'b001000000;
        #10;
        
        Run = 0;
        DIN = 9'b000000101;
        #10;
        
        Run = 1;
        DIN = 9'b000001000;
        #10;
        Run = 0;
        #10;
        Run = 1;
        DIN = 9'b010000001;
        #10;
        Run = 0;
        #30;
        Run = 1;
        DIN = 9'b011000000;
        #10;
        Run = 0;
        DIN = 9'b0;
        
        $finish;
    end

endmodule