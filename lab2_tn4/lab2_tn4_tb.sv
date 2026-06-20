`timescale 1ns / 1ps

module lab2_tn4_tb();

    // 1. Declare connection signals
    logic [2:0] SW;
    logic       CLOCK_50;
    logic [1:0] KEY;
    logic [9:0] LEDR;

    // Auxiliary signals for easier waveform viewing
    logic led_dot, led_dash;
    assign led_dot  = LEDR[0]; 
    assign led_dash = LEDR[1]; 

    // 2. Instantiate the design module
    lab2_tn4_ver2 DUT (
        .SW(SW),
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .LEDR(LEDR)
    );

    // Scale down the counter for simulation purposes
    defparam DUT.half_sec_cnt.MAX_COUNT = 50;

    // 3. Generate Clock (20ns period)
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50; 
    end

    // 4. Simulation scenario: Sequential transmission from A to H
    initial begin
        // --- INITIALIZATION ---
        SW  = 3'b000;   
        KEY = 2'b11;    
        
        // Wait a few clock cycles for the system to stabilize
        repeat(5) @(posedge CLOCK_50);
        
        // --- SYSTEM STARTUP RESET ---
        $display("--- SYSTEM STARTUP ---");
        @(negedge CLOCK_50) KEY[0] = 1'b0;  // Press Reset 
        repeat(2) @(posedge CLOCK_50);      // Hold Reset for 2 cycles
        @(negedge CLOCK_50) KEY[0] = 1'b1;  // Release Reset
        repeat(5) @(posedge CLOCK_50);

        // ==========================================
        // CONTINUOUS TRANSMISSION FROM A TO H
        // ==========================================

        // --- LETTER A (.-) ---
        $display("Transmitting letter A (.-)");
        @(negedge CLOCK_50) SW = 3'b000; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(250) @(posedge CLOCK_50); 

        // --- LETTER B (-...) ---
        $display("Transmitting letter B (-...)");
        @(negedge CLOCK_50) SW = 3'b001; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(450) @(posedge CLOCK_50);

        // --- LETTER C (-.-.) ---
        $display("Transmitting letter C (-.-.)");
        @(negedge CLOCK_50) SW = 3'b010; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(450) @(posedge CLOCK_50);

        // --- LETTER D (-..) ---
        $display("Transmitting letter D (-..)");
        @(negedge CLOCK_50) SW = 3'b011; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(350) @(posedge CLOCK_50);

        // --- LETTER E (.) ---
        $display("Transmitting letter E (.)");
        @(negedge CLOCK_50) SW = 3'b100; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(150) @(posedge CLOCK_50);

        // --- LETTER F (..-.) ---
        $display("Transmitting letter F (..-.)");
        @(negedge CLOCK_50) SW = 3'b101; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(450) @(posedge CLOCK_50);

        // --- LETTER G (--.) ---
        $display("Transmitting letter G (--.)");
        @(negedge CLOCK_50) SW = 3'b110; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(350) @(posedge CLOCK_50);

        // --- LETTER H (....) ---
        $display("Transmitting letter H (....)");
        @(negedge CLOCK_50) SW = 3'b111; KEY[1] = 1'b0;  
        repeat(2) @(posedge CLOCK_50);
        @(negedge CLOCK_50) KEY[1] = 1'b1;  
        repeat(450) @(posedge CLOCK_50);
        
        // --- REST AND FINISH ---
        repeat(100) @(posedge CLOCK_50);     
        $display("--- END OF SIMULATION ---");
        $stop;
    end

endmodule