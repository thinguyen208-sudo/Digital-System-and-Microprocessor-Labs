// ==============================================================================
// MODULE TOP: Gắn kết các khối lại với nhau giống như sơ đồ mạch
// ==============================================================================
module lab2_tn4_ver2(
    input  logic [2:0] SW,       // Pushbuttons and switches
    input  logic       CLOCK_50, // Xung clock 50MHz
    input  logic [1:0] KEY,      // Pushbuttons and switches
    output logic [9:0] LEDR      // LED outputs
);
    // Tắt các LED không sử dụng
    assign LEDR[9:2] = 8'h0;

    logic reset_n, start;
    assign reset_n = KEY[0]; 
    assign start   = ~KEY[1];

    // --- CÁC ĐƯỜNG DÂY TÍN HIỆU KẾT NỐI GIỮA CÁC KHỐI (Dây nối trong hình) ---
    logic [3:0] w_morse_data;   // Từ Letter Selection -> Shift Register
    logic [2:0] w_morse_length; // Từ Letter Selection -> Length Counter
    
    logic w_fsm_load;           // Từ FSM -> Load của các thanh ghi
    logic w_fsm_enable;         // Từ FSM -> Enable của các thanh ghi
    logic w_half_sec_tick;      // Từ Half-second counter -> FSM
    
    logic [2:0] w_current_size; // Từ Length Counter -> FSM
    logic w_current_bit;        // Từ Shift Register -> FSM (Bit LSB)

    // --------------------------------------------------------------------------
    // KHỐI 1: Letter selection logic
    // --------------------------------------------------------------------------
    letter_selection_logic letter_logic_inst (
        .SW(SW),
        .morse_code(w_morse_data),
        .morse_length(w_morse_length)
    );

    // --------------------------------------------------------------------------
    // KHỐI 2: Morse code length counter
    // --------------------------------------------------------------------------
    morse_code_length_counter length_counter_inst (
        .clk(CLOCK_50),
        .rst_n(reset_n),
        .data(w_morse_length),
        .load(w_fsm_load),
        .enable(w_fsm_enable),
        .count_out(w_current_size)
    );

    // --------------------------------------------------------------------------
    // KHỐI 3: Morse code shift register
    // --------------------------------------------------------------------------
    morse_code_shift_register shift_register_inst (
        .clk(CLOCK_50),
        .rst_n(reset_n),
        .data(w_morse_data),
        .load(w_fsm_load),
        .enable(w_fsm_enable),
        .bit_out(w_current_bit)
    );

    // --------------------------------------------------------------------------
    // KHỐI 4: Half-second counter
    // --------------------------------------------------------------------------
    half_second_counter #(.MAX_COUNT(25_000_000)) half_sec_cnt(
        .clk(CLOCK_50),
        .rst_n(reset_n),
        .tick(w_half_sec_tick)
    );

    // --------------------------------------------------------------------------
    // KHỐI 5: FSM (Finite State Machine)
    // --------------------------------------------------------------------------
    fsm_controller fsm_inst (
        .clk(CLOCK_50),
        .rst_n(reset_n),
        .start(start),
        .tick(w_half_sec_tick),
        .current_size(w_current_size),
        .current_bit(w_current_bit),
        .fsm_load(w_fsm_load),
        .fsm_enable(w_fsm_enable),
        .ledr0(LEDR[0]),
        .ledr1(LEDR[1])
    );

endmodule


// ==============================================================================
// CHI TIẾT CÁC SUB-MODULES
// ==============================================================================

// --- KHỐI 1: Letter selection logic ---

module letter_selection_logic (
    input  logic [2:0] SW,
    output logic [3:0] morse_code,
    output logic [2:0] morse_length
);
    always_comb begin
        case (SW)
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
endmodule

// --- KHỐI 2: Morse code length counter ---
module morse_code_length_counter (
    input  logic clk,
    input  logic rst_n,
    input  logic [2:0] data,
    input  logic load,
    input  logic enable,
    output logic [2:0] count_out
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            count_out <= 3'd0;
        else if (load) 
            count_out <= data;
        else if (enable) 
            count_out <= count_out - 3'd1;
    end
endmodule

// --- KHỐI 3: Morse code shift register ---
module morse_code_shift_register (
    input  logic clk,
    input  logic rst_n,
    input  logic [3:0] data,
    input  logic load,
    input  logic enable,
    output logic bit_out
);
    logic [3:0] shift_reg;
    assign bit_out = shift_reg[0]; // Bit đang xét luôn nằm ở LSB

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            shift_reg <= 4'd0;
        else if (load) 
            shift_reg <= data;
        else if (enable) 
            shift_reg <= {1'b0, shift_reg[3:1]}; // Dịch phải
    end
endmodule

// --- KHỐI 4: Half-second counter ---
module half_second_counter #(
    parameter MAX_COUNT = 25_000_000
)(
    input  logic clk,
    input  logic rst_n,
    output logic tick
);
    logic [24:0] count;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 25'd0;
            tick <= 1'b0;
        end else begin
            if (count == MAX_COUNT - 1) begin
                count <= 25'd0;
                tick <= 1'b1;
            end else begin
                count <= count + 1'b1;
                tick <= 1'b0;
            end
        end
    end
endmodule

// --- KHỐI 5: FSM (Tối ưu 3 Trạng thái) ---
module fsm_controller (
    input  logic clk,
    input  logic rst_n,
    input  logic start,
    input  logic tick,
    input  logic [2:0] current_size,
    input  logic current_bit,
    
    output logic fsm_load,
    output logic fsm_enable,
    output logic ledr0,
    output logic ledr1
);
    // Khai báo 3 trạng thái theo phương pháp Parameter
    parameter IDLE     = 2'b00,
              SENT_ON  = 2'b01,
              SENT_OFF = 2'b10;
              
    logic [1:0] present_state, next_state;

    // 1. Logic chuyển trạng thái (Next State Logic)
    always_comb begin
        next_state = present_state; // Mặc định giữ nguyên trạng thái
        case (present_state)
            IDLE: begin
                if (start) next_state = SENT_ON;
            end
            SENT_ON: begin
                if (tick)  next_state = SENT_OFF;
            end
            SENT_OFF: begin
                if (tick) begin
                    // Nếu còn 1 bit cuối cùng thì quay về IDLE, ngược lại tiếp tục sáng
                    if (current_size <= 3'd1) next_state = IDLE; 
                    else next_state = SENT_ON;
                end
            end
            default: next_state = IDLE;
        endcase
    end

    // 2. Thanh ghi trạng thái (State Register)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) present_state <= IDLE;
        else        present_state <= next_state;
    end

    // --- ĐIỂM MẤU CHỐT GỘP TRẠNG THÁI ---
    
    // Kích hoạt LOAD ngay khi đang ở IDLE và có người bấm start
    assign fsm_load = (present_state == IDLE) && start;

    // Kích hoạt SHIFT (enable) khi đang ở chu kỳ tắt (SENT_OFF), hết nửa giây (tick) và vẫn còn bit để gửi
    assign fsm_enable = (present_state == SENT_OFF) && tick && (current_size > 3'd1);

    // Điều khiển LED tương ứng với bit truyền (0: dấu chấm, 1: dấu gạch)
	 assign ledr0 = (present_state == SENT_ON) & ~current_bit; 
    assign ledr1 = (present_state == SENT_ON) & current_bit;

endmodule