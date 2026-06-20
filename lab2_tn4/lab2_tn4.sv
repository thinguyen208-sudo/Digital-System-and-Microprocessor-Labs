module lab2_tn4 (
    input  logic [2:0] SW,       // SW[2:0] chọn chữ cái (A-H)
    input  logic       CLOCK_50, // Xung clock 50MHz của Kit
    input  logic [1:0] KEY,      // KEY[1] để Start, KEY[0] làm Async Reset
    output logic [9:0] LEDR      // LEDR0 (dot), LEDR1 (dash)
);
	 assign LEDR[9:2] = 8'h0;
    /****************************************************************/
    /**** DECLARATIONS                    ****/
    /****************************************************************/
    logic reset_n;
    assign reset_n = KEY[0]; // Reset bất đồng bộ, tích cực mức thấp theo yêu cầu

    logic [3:0] morse_code;
    logic [2:0] morse_length;
    logic [3:0] data;
    logic [2:0] size;
    logic       enable; // Xung kích hoạt mỗi nửa giây (0.5s)

    // Khai báo các tín hiệu điều khiển từ FSM
    logic light_on, load_regs, shift_and_count;

    // Khai báo trạng thái FSM
    typedef enum logic [2:0] {
        IDLE,       // Chờ nhấn nút KEY1
        LOAD,       // Nạp dữ liệu mã Morse vào thanh ghi
        ON_STATE,   // Bật LED trong 0.5s
        OFF_STATE,  // Tắt LED trong 0.5s (khoảng cách giữa các Dấu)
        SHIFT_STATE // Dịch bit để chuẩn bị phát Dấu tiếp theo
    } state_t;
    
    state_t present_state, next_state;


    /****************************************************************/
    // FSM State Table
    always_comb begin: state_table
        next_state = present_state; // Mặc định giữ nguyên trạng thái
        case (present_state)
            IDLE: 
                if (~KEY[1]) next_state = LOAD; // Nhấn KEY1 (mức 0) thì bắt đầu
            
            LOAD: 
                next_state = ON_STATE;
            
            ON_STATE: 
                if (enable) next_state = OFF_STATE; // Đủ 0.5s thì chuyển sang Tắt
            
            OFF_STATE: 
                if (enable) begin
                    // Nếu kích thước chỉ còn 1, nghĩa là đã phát xong bit cuối cùng
                    if (size == 3'd1) next_state = IDLE; 
                    else next_state = SHIFT_STATE;
                end
                
            SHIFT_STATE: 
                next_state = ON_STATE;
                
            default: next_state = IDLE;
        endcase
    end // state_table


    /****************************************************************/
    // FSM State flip-flops
    always_ff @(posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n)
            present_state <= IDLE;
        else
            present_state <= next_state;
    end


    /****************************************************************/
    // FSM outputs
    // Bật đèn khi đang ở trạng thái ON
    assign light_on = (present_state == ON_STATE);
    
    // Nạp dữ liệu khi ở trạng thái LOAD
    assign load_regs = (present_state == LOAD);
    
    // Dịch bit khi ở trạng thái SHIFT
    assign shift_and_count = (present_state == SHIFT_STATE);

    // Xử lý ngõ ra LED theo yêu cầu:
    // "LEDR0 to represent dots, and LEDR1 to represent dashes"
    // Dấu chấm (0) bật LEDR0, Dấu gạch (1) bật LEDR1
    assign LEDR[0] = light_on & ~data[0];
    assign LEDR[1] = light_on & data[0];


    /****************************************************************/
    /* Letter selection logic (Dựa trên Bảng mã từ Pre-Lab 2) */
    always_comb begin
        case (SW[2:0])
            3'b000: begin morse_code = 4'b0010; morse_length = 3'd2; end // A: .- 
            3'b001: begin morse_code = 4'b0001; morse_length = 3'd4; end // B: -...
            3'b010: begin morse_code = 4'b0101; morse_length = 3'd4; end // C: -.-.
            3'b011: begin morse_code = 4'b0001; morse_length = 3'd3; end // D: -..
            3'b100: begin morse_code = 4'b0000; morse_length = 3'd1; end // E: .
            3'b101: begin morse_code = 4'b0100; morse_length = 3'd4; end // F: ..-.
            3'b110: begin morse_code = 4'b0011; morse_length = 3'd3; end // G: --.
            3'b111: begin morse_code = 4'b0000; morse_length = 3'd4; end // H: ....
            default:begin morse_code = 4'b0000; morse_length = 3'd0; end
        endcase
    end


    /****************************************************************/
    /* Store the Morse code to be sent in a shift register, and its length in a counter */
    always_ff @ (posedge CLOCK_50 or negedge reset_n) begin
        if (!reset_n) begin
            data <= 4'b0000;
            size <= 3'd0;
        end
        else if (load_regs) begin
            data <= morse_code;
            size <= morse_length;
        end
        else if (shift_and_count) begin
            data <= {1'b0, data[3:1]}; // Dịch phải 1 bit, chèn số 0 vào MSB
            size <= size - 3'd1;       // Giảm kích thước đi 1
        end
    end

    /****************************************************************/
    /* Create an enable signal that is asserted once every HALF second */
    // Tính toán: Tần số 50MHz (50,000,000 chu kỳ/s) -> 0.5s = 25,000,000 chu kỳ
    modulo_counter #(.MAX_COUNT(25_000_000)) half_sec_cnt (
        .clk(CLOCK_50),
        .rst_n(reset_n),
        .enable(enable)
    );

endmodule


// --- Module đếm nhịp (Modulo Counter) ---
module modulo_counter #(
    parameter MAX_COUNT = 25_000_000 // Có thể chỉnh sửa parameter này trong Testbench để mô phỏng nhanh hơn
)(
    input  logic clk,
    input  logic rst_n,
    output logic enable
);
    logic [24:0] count;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 25'd0;
            enable <= 1'b0;
        end else begin
            if (count == MAX_COUNT - 1) begin
                count <= 25'd0;
                enable <= 1'b1;
            end else begin
                count <= count + 1'b1;
                enable <= 1'b0;
            end
        end
    end
endmodule