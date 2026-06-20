// --- Bước 1: Khối D-Flip-Flop cơ bản (Giữ nguyên) ---
module dff_ff (
    input  logic d,
    input  logic clk,
    input  logic rst, // Reset bất đồng bộ
    input  logic en,  // Enable đồng bộ
    output logic q
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) 
            q <= 1'b0;
        else if (en) 
            q <= d;    
    end
endmodule


// --- Bước 2: Register N-bit sử dụng vòng lặp Generate ---
module register #(parameter N = 8) (
    input  logic [N-1:0] D,
    input  logic         clk,
    input  logic         RST,
    input  logic         EN,
    output logic [N-1:0] Q
);
    // Khai báo biến genvar để chạy vòng lặp sinh phần cứng
    genvar i;
    // Khối generate để tự động nhân bản D-Flip-Flop
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_dff
            // Tạo ra N khối dff_ff, mỗi khối xử lý bit thứ i
            dff_ff dff_inst (
                .d(D[i]), 
                .clk(clk), 
                .rst(RST), 
                .en(EN), 
                .q(Q[i])
            );
        end
    endgenerate

endmodule