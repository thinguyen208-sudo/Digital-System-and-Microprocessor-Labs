module my_ram #(
    parameter DATA_WIDTH = 9,
    parameter ADDR_WIDTH = 7
)(
    input  logic                  clock,
    input  logic                  wren,
    input  logic [ADDR_WIDTH-1:0] address,
    input  logic [DATA_WIDTH-1:0] data,
    output logic [DATA_WIDTH-1:0] q
);

   //(* ram_init_file = "lab5.mif" *) 
	logic [DATA_WIDTH-1:0] ram_block [0:(2**ADDR_WIDTH)-1];

	 initial begin
        $readmemb("lab5.txt", ram_block);
    end

    always_ff @(posedge clock) begin
        if (wren) begin
            ram_block[address] <= data;
        end
        // Luôn luôn đọc dữ liệu ra
        q <= ram_block[address];
    end

endmodule