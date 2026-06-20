module lab1_tn4_tb();
    reg clk;
    reg rst;
    reg [2:0] Sel_op;
    reg En_A;
    reg En_B;
    reg [7:0] A;
    reg [7:0] B;
    wire [7:0] reg_A;
    wire [7:0] reg_B;
    wire [15:0] P;
    wire [15:0] reg_P;

    // Instantiate the DUT
    lab1_tn4 DUT (
        .clk (clk),
        .rst (rst),
        .Sel_op (Sel_op),
        .En_A (En_A),
        .En_B (En_B),
        .A (A),
        .B (B),
        .reg_A (reg_A),
        .reg_B (reg_B),
        .P (P),
        .reg_P (reg_P)
    );

    // Clock generation (10ns period -> 5ns high, 5ns low)
    always begin
        #5 clk = ~clk;
    end

    // Testbench procedure
    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        En_A = 0;
        En_B = 0;
        A = 0;
        B = 0;
        Sel_op = 3'b000;

        // Reset sequence
        #10 rst = 0;
        #10 rst = 1;
        #10;

        // Test Addition (5 + 10)
        @(posedge clk); En_A = 1; A = 8'd5;
        @(posedge clk); En_B = 1; B = 8'd10;
        @(posedge clk); Sel_op = 3'b000; En_A = 0; En_B = 0;
        #20;

        // Test Subtraction (20 - 15)
        @(posedge clk); En_A = 1; A = 8'd20;
        @(posedge clk); En_B = 1; B = 8'd15;
        @(posedge clk); Sel_op = 3'b001; En_A = 0; En_B = 0;
        #20;

        // Test Multiplication (8 * 4)
        @(posedge clk); En_A = 1; A = 8'd8;
        @(posedge clk); En_B = 1; B = 8'd4;
        @(posedge clk); Sel_op = 3'b010; En_A = 0; En_B = 0;
        #20;

        // Test Edge Case: Overflow in Addition (127 + 1)
        @(posedge clk); En_A = 1; A = 8'd127;
        @(posedge clk); En_B = 1; B = 8'd1;
        @(posedge clk); Sel_op = 3'b000; En_A = 0; En_B = 0;
        #20;

        // Test Edge Case: Underflow in Subtraction (-128 - 1)
        @(posedge clk); En_A = 1; A = -8'd128;
        @(posedge clk); En_B = 1; B = 8'd1;
        @(posedge clk); Sel_op = 3'b001; En_A = 0; En_B = 0;
        #20;

        // Test Large Multiplication (50 * 50)
        @(posedge clk); En_A = 1; A = 8'd50;
        @(posedge clk); En_B = 1; B = 8'd50;
        @(posedge clk); Sel_op = 3'b010; En_A = 0; En_B = 0;
        #20;

        // End of test
        $stop;
    end
endmodule
