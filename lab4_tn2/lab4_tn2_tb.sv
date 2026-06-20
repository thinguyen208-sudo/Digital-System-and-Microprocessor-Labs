`timescale 1ns/1ps

module lab4_tn2_tb;

    // --- Khai báo tín hiệu ---
    logic       MClock;
    logic       PClock;
    logic       Resetn;
    logic       Run;
    logic       Done;
    logic [8:0] Bus;

    // --- Khởi tạo Module cần test ---
    lab4_tn2 uut (
        .MClock(MClock),
        .PClock(PClock),
        .Resetn(Resetn),
        .Run(Run),
        .Done(Done),
        .Bus(Bus)
    );
	 
	task M();
        #5 MClock = 1; #5 MClock = 0;
    endtask

    task P();
        #5 PClock = 1; #5 PClock = 0;
    endtask
	 
    initial begin
	 
			MClock = 0; PClock = 0; Run = 0; Resetn = 0;
			M();
			P();
			#5 Resetn = 1; Run = 1;
		  
      //Lệnh 1 000 000 000
			M();
			P();
			P();
		//Lệnh 001 000 000
			M();
			P();
		//000000101
			M();
			P();
		//000001000
			M();
			P();
			#10
			P();
		//010000001
			M();
			P();
			P();
			#10
			P();
			#5
			P();
		//011000000
			M();
			P();
			P();
			P();
			P();
        $finish;
    end

endmodule



/*
module lab4_tn2_tb();

    // 1. Parameters and Signals
	 
    logic       MClock; 
	 logic PClock;
	 logic Resetn;
	 logic Run;
    logic       Done;
    logic [8:0] Bus;

    // 2. Instantiate the Design Under Test (DUT)
    lab4_tn2 dut (  // <-- Đổi tên gọi module cho khớp code cũ của bạn
			.MClock(MClock),
			.PClock(PClock),
			.Resetn(Resetn),
			.Run(Run),
			.Done(Done),
			.Bus(Bus)
);

    // 3. Clock Generation (10ns period)
    always #5 PClock = ~PClock;

    // 4. Stimulus Procedure
    initial begin
        // Initialize signals
		  
        PClock = 0;
        Resetn = 0;
        Run = 0;
		  MClock = 1;
        #1;
		  
		  PClock = 0;
        Resetn = 0;
        Run = 0;
		  MClock = 0;
        #9;
        
		  Resetn = 1;
        Run = 1;
        MClock = 1;
        #1;
		  
        Resetn = 1;
        Run = 1;
        MClock = 0;
        #9;
        
		  Run = 0;
        MClock = 1;
        #1;
        Run = 0;
        MClock = 0;
        #9;
        
		  
		  Run = 1;
        MClock = 1;
        #1;
        Run = 1;
        MClock = 0;
        #9;
		  
        Run = 0;
        #10;
		  
		  
		  Run = 1;
        MClock = 1;
        #1;
        Run = 1;
        MClock = 0;
        #9;
		  
        Run = 0;
        #30;
		  
        Run = 1;
        MClock = 1;
        #1;
		  Run = 1;
        MClock = 0;
        #9;
		  
		  
		  
        Run = 0;
        MClock = 1;
        
        $finish;
    end

endmodule
*/