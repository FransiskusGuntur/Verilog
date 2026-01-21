`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/03/2024 02:28:30 AM
// Design Name: 
// Module Name: Lab5_Team27_Vending_Machine_fpga
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////



module Lab5_Team27_Vending_Machine_fpga(display, digit, LED, PS2_DATA, PS2_CLK, clk, rst_n, left, right, middle, cancel);
input wire clk;
input wire rst_n;
input wire left;
input wire right;
input wire middle;
input wire cancel;
output wire [6:0] display;
output wire [3:0] digit;
output wire [3:0] LED;
inout wire PS2_DATA;
inout wire PS2_CLK;

parameter [8:0]KEY_CODES_a = 9'd28;  // a --- coffee (NTD 80)
parameter [8:0] KEY_CODES_s = 9'd27;  // s --- coke (NTD 30)
parameter [8:0] KEY_CODES_d = 9'd35;  // d --- oolong (NTD 25)
parameter [8:0] KEY_CODES_f = 9'd43;  // f --- water (NTD 20)
parameter state_INSERT = 1'b0;
parameter state_RETURN = 1'b1;

wire [511:0]key_down;   //--------//
wire [8:0]last_change;  //keyboard//
wire key_valid;         //--------//
    

wire rst_debounced, left_debounced, right_debounced, middle_debounced, cancel_debounced;
wire rst_onepulse, left_onepulse, right_onepulse, middle_onepulse, cancel_onepulse;

reg count_max, count_max_buff;
reg [26:0] counter, counter_buff;

reg curr_state, next_state;
reg [6:0] money, money_buff;

debound_circuit db_reset(rst_debounced, clk, rst_n);
onepulse pulse_rst(rst_onepulse, rst_debounced, clk);

debound_circuit db_left(left_debounced, clk, left);
onepulse pulse_left(left_onepulse, left_debounced, clk);

debound_circuit db_right(right_debounced, clk, right);
onepulse pulse_right(right_onepulse, right_debounced, clk);

debound_circuit db_middle(middle_debounced, clk, middle);
onepulse pulse_middle(middle_onepulse, middle_debounced, clk);

debound_circuit db_cancel(cancel_debounced, clk, cancel);
onepulse pulse_cancel(cancel_onepulse, cancel_debounced, clk);

KeyboardDecoder kb_dec(
    .key_down(key_down),
    .last_change(last_change),
    .key_valid(key_valid),
    .PS2_DATA(PS2_DATA),
    .PS2_CLK(PS2_CLK),
    .rst(rst_onepulse),
    .clk(clk)
);



//7seg multiplexing : pake code sebelumny
reg [19:0] counter_seg; 
wire [1:0] enable_seg;   

always @(posedge clk or posedge rst_n) begin
if (rst_n)
    counter_seg <= 20'd0;
else 
    counter_seg <= counter_seg + 20'd1;
end
assign enable_seg = counter_seg[19:18];

disp7Seg disp(
    .display(display),
    .digit(digit),
    .nums(money),
    .rst(rst_onepulse),
    .clk(clk),
    .enable_seg(enable_seg)  
);



LEDIndicator led_handle (money, LED);


// STATE HANDLING : main physical comp: insert money stage, --> LED turn on based on money, -->keyboard select ---> RETURN CHANGE STAGE
always @(*) begin
    money_buff = money;
    next_state = curr_state;
    case (curr_state)

    state_INSERT: begin
        if (left_onepulse) begin
            money_buff = (money + 8'd5 <= 8'd100) ? money + 8'd5 : money;
            next_state = state_INSERT;
        end
        else if (middle_onepulse) begin 
            money_buff = (money + 8'd10 <= 8'd100) ? money + 8'd10 : money;
            next_state = state_INSERT;
        end

        else if (right_onepulse) begin
            money_buff = (money + 8'd50 <= 8'd100) ? money + 8'd50 : money;
            next_state = state_INSERT;
        end
        else if (cancel_onepulse) begin
        next_state = (money != 8'd0) ? state_RETURN : state_INSERT;
        end

        // USED KEYBOARD MODULE PROVIDED 
        else if (key_valid && key_down[last_change] == 1'b1) begin
            case (last_change)
                KEY_CODES_a: begin
                    if (money >= 8'd80) begin
                        money_buff = money - 8'd80;
                        next_state = state_RETURN;
                    end
                end
                KEY_CODES_s: begin 
                    if (money >= 8'd30) begin
                        money_buff = money - 8'd30;
                        next_state = state_RETURN;
                    end
                end
                KEY_CODES_d: begin  
                    if (money >= 8'd25) begin
                        money_buff = money - 8'd25;
                        next_state = state_RETURN;
                    end
                end
                KEY_CODES_f: begin
                    if (money >= 8'd20) begin
                        money_buff = money - 8'd20;
                        next_state = state_RETURN;
                    end
                end
                default: next_state = state_INSERT;
            endcase
        end
    end


    state_RETURN: begin
        if (money > 0) begin
            next_state = state_RETURN;
            money_buff = money - 8'd5;
        end else begin
            next_state = state_INSERT;
            money_buff = 8'd0;
        end
    end
    endcase
end


wire pulse_1s;
clk_divide timer (
    .clk(clk),
    .rst(rst_n),
    .pulse_1s(pulse_1s)
);

always @(posedge clk) begin
    if (rst_n) begin
        // reset conditions
        money <= 8'd0;
        curr_state <= state_INSERT;
        counter <= 27'd0;
        count_max <= 1'b0;
    end
    
     else begin
        curr_state <= next_state;
        if (curr_state == state_RETURN) begin
            counter <= counter_buff;
            count_max <= count_max_buff;
            if (pulse_1s)
                money <= money_buff;
            else
                money <= money;  
        end else begin
            counter <= 27'd0;
            count_max <= 1'b0;
            money <= money_buff;
        end
    end
end

endmodule













module LEDIndicator(
input wire [7:0] money,
output reg [3:0] LED
);
always @(*) begin
    if (money >= 8'd80)
        LED = 4'b1111; // All drinks available
    else if (money >= 8'd30)
        LED = 4'b0111; // Coke, Oolong, and Water available
    else if (money >= 8'd25)
        LED = 4'b0011; // Oolong and Water available
    else if (money >= 8'd20)
        LED = 4'b0001; // Only Water available
    else
        LED = 4'b0000; // None available
end
endmodule






//DIVIDE 1s clk
module clk_divide(
input wire clk,        // System clock input
input wire rst,        // Reset signal
output reg pulse_1s    // 1-second pulse output
);

reg [26:0] counter;    

always @(posedge clk or posedge rst) begin
    if (rst) begin
        counter <= 27'd0;
        pulse_1s <= 1'b0;
    end else if (counter == 27'd99999999) begin
        counter <= 27'd0;
        pulse_1s <= 1'b1; 
    end else begin
        counter <= counter + 27'd1;
        pulse_1s <= 1'b0; 
    end
end

endmodule


module debound_circuit(
output wire debounced,
input wire clk,
input wire pb
);
reg [3:0]debound_signal;

always @(posedge clk) begin
    debound_signal[3:1] <= debound_signal[2:0];
    debound_signal[0] <= pb;
end


assign debounced = (debound_signal==4'b1111) ? 1'b1 : 1'b0;
endmodule 






 







//GIVEN IN BASIC LAB
module disp7Seg(
output reg [6:0] display,
output reg [3:0] digit,
input wire [6:0] nums,
input wire rst,
input wire clk,
input wire [1:0] enable_seg  
);
reg [3:0] display_seg;  

always @(*) begin
case (enable_seg)

    2'b00: begin
        digit = 4'b1110;                        
        display_seg = nums % 10;                
    end

    2'b01: begin
        digit = 4'b1101;                        
        if (nums < 10)
            display_seg = 4'b1010;              
        else
            display_seg = (nums / 10) % 10;     
    end
    2'b10: begin
        digit = 4'b1011;                        
        if (nums < 100)
            display_seg = 4'b1010;              
        else
            display_seg = (nums / 100);        
    end
    2'b11: begin
        digit = 4'b1111;                        
        display_seg = 4'b1010;                  
    end
    default: begin
        digit = 4'b1111;
        display_seg = 4'b1010;
    end
endcase
end

// 7-segment display pattern for digits 0-9 and blank
always @(*) begin
    case (display_seg)
        4'd0: display = 7'b1000000;    // Display "0"
        4'd1: display = 7'b1111001;    // Display "1"
        4'd2: display = 7'b0100100;    // Display "2"
        4'd3: display = 7'b0110000;    // Display "3"
        4'd4: display = 7'b0011001;    // Display "4"
        4'd5: display = 7'b0010010;    // Display "5"
        4'd6: display = 7'b0000010;    // Display "6"
        4'd7: display = 7'b1111000;    // Display "7"
        4'd8: display = 7'b0000000;    // Display "8"
        4'd9: display = 7'b0010000;    // Display "9"
        default: display = 7'b1111111; // Display nothing (blank)
    endcase
end
endmodule










module onepulse(
output reg signal_single_pulse,
input wire signal,
input wire clock
);
    
reg signal_delay;

always @(posedge clock) begin
if(signal == 1'b1 & signal_delay == 1'b0)
    signal_single_pulse <= 1'b1;
else
    signal_single_pulse <= 1'b0;
signal_delay <= signal;
end
endmodule
   

module KeyboardDecoder(
    output reg [511:0] key_down,
    output wire [8:0] last_change,
    output reg key_valid,
    inout wire PS2_DATA,
    inout wire PS2_CLK,
    input wire rst,
    input wire clk
);
    parameter [1:0] INIT			= 2'b00;
    parameter [1:0] WAIT_FOR_SIGNAL = 2'b01;
    parameter [1:0] GET_SIGNAL_DOWN = 2'b10;
    parameter [1:0] WAIT_RELEASE    = 2'b11;
    
    parameter [7:0] IS_INIT			= 8'hAA;
    parameter [7:0] IS_EXTEND		= 8'hE0;
    parameter [7:0] IS_BREAK		= 8'hF0;
    
    reg [9:0] key, next_key;		// key = {been_extend, been_break, key_in}
    reg [1:0] state, next_state;
    reg been_ready, been_extend, been_break;
    reg next_been_ready, next_been_extend, next_been_break;
    
    wire [7:0] key_in;
    wire is_extend;
    wire is_break;
    wire valid;
    wire err;
    
    wire [511:0] key_decode = 1 << last_change;
    assign last_change = {key[9], key[7:0]};
    
    KeyboardCtrl_0 inst (
        .key_in(key_in),
        .is_extend(is_extend),
        .is_break(is_break),
        .valid(valid),
        .err(err),
        .PS2_DATA(PS2_DATA),
        .PS2_CLK(PS2_CLK),
        .rst(rst),
        .clk(clk)
    );
    
    onepulse op(
        .signal_single_pulse(pulse_been_ready),
        .signal(been_ready),
        .clock(clk)
    );
    
     always @ (posedge clk, posedge rst) begin
        if (rst) begin
            state <= INIT;
            been_ready  <= 1'b0;
            been_extend <= 1'b0;
            been_break  <= 1'b0;
            key <= 10'b0_0_0000_0000;
        end else begin
            state <= next_state;
            been_ready  <= next_been_ready;
            been_extend <= next_been_extend;
            been_break  <= next_been_break;
            key <= next_key;
        end
    end
    
    always @ (*) begin
        case (state)
            INIT:            next_state = (key_in == IS_INIT) ? WAIT_FOR_SIGNAL : INIT;
            WAIT_FOR_SIGNAL: next_state = (valid == 1'b0) ? WAIT_FOR_SIGNAL : GET_SIGNAL_DOWN;
            GET_SIGNAL_DOWN: next_state = WAIT_RELEASE;
            WAIT_RELEASE:    next_state = (valid == 1'b1) ? WAIT_RELEASE : WAIT_FOR_SIGNAL;
            default:         next_state = INIT;
        endcase
    end
    always @ (*) begin
        next_been_ready = been_ready;
        case (state)
            INIT:            next_been_ready = (key_in == IS_INIT) ? 1'b0 : next_been_ready;
            WAIT_FOR_SIGNAL: next_been_ready = (valid == 1'b0) ? 1'b0 : next_been_ready;
            GET_SIGNAL_DOWN: next_been_ready = 1'b1;
            WAIT_RELEASE:    next_been_ready = next_been_ready;
            default:         next_been_ready = 1'b0;
        endcase
    end
    always @ (*) begin
        next_been_extend = (is_extend) ? 1'b1 : been_extend;
        case (state)
            INIT:            next_been_extend = (key_in == IS_INIT) ? 1'b0 : next_been_extend;
            WAIT_FOR_SIGNAL: next_been_extend = next_been_extend;
            GET_SIGNAL_DOWN: next_been_extend = next_been_extend;
            WAIT_RELEASE:    next_been_extend = (valid == 1'b1) ? next_been_extend : 1'b0;
            default:         next_been_extend = 1'b0;
        endcase
    end
    always @ (*) begin
        next_been_break = (is_break) ? 1'b1 : been_break;
        case (state)
            INIT:            next_been_break = (key_in == IS_INIT) ? 1'b0 : next_been_break;
            WAIT_FOR_SIGNAL: next_been_break = next_been_break;
            GET_SIGNAL_DOWN: next_been_break = next_been_break;
            WAIT_RELEASE:    next_been_break = (valid == 1'b1) ? next_been_break : 1'b0;
            default:         next_been_break = 1'b0;
        endcase
    end
    always @ (*) begin
        next_key = key;
        case (state)
            INIT:            next_key = (key_in == IS_INIT) ? 10'b0_0_0000_0000 : next_key;
            WAIT_FOR_SIGNAL: next_key = next_key;
            GET_SIGNAL_DOWN: next_key = {been_extend, been_break, key_in};
            WAIT_RELEASE:    next_key = next_key;
            default:         next_key = 10'b0_0_0000_0000;
        endcase
    end

    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            key_valid <= 1'b0;
            key_down <= 511'b0;
        end else if (key_decode[last_change] && pulse_been_ready) begin
            key_valid <= 1'b1;
            if (key[8] == 0) begin
                key_down <= key_down | key_decode;
            end else begin
                key_down <= key_down & (~key_decode);
            end
        end else begin
            key_valid <= 1'b0;
            key_down <= key_down;
        end
    end
    
endmodule










































































