`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/05/2024 04:43:16 PM
// Design Name: 
// Module Name: mosf
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


`timescale 1ns / 1ps


module MyA2D_SingleChannel_05_ContinousMode(
    input clk,                 // FPGA clock
    input reset,               // Reset signal
    output reg mosfet_out,     // Output to MOSFET gate
    output reg [6:0] seg,          // 7-segment display
    output reg [3:0] an,           // 7-segment anodes
    input [15:0] sw,           // Switches
    output [15:0] led,         // LEDs
    input [7:0] JA             // Analog input pins
    );
    
    // --------------------- XADC Configuration ---------------------
    
    // ADC channel assignments (AUXP5/AUXN5)
    wire analog_pos_in, analog_neg_in;
    assign analog_pos_in = JA[4];
    assign analog_neg_in = JA[0];
    
    wire [15:0] do_out;              // ADC output
    wire [4:0] channel_out;
    //assign led[4:0] = channel_out;
    
    wire eoc_out;
    //assign led[5] = eoc_out;
    
    // Define the ADC_ADDRESS for AUXP5/AUXN5
    parameter ADC_ADDRESS = 7'd21; // 15h in hexadecimal
    
    // Instantiate the XADC wizard with the correct address
    xadc_wiz_0 CoolADCd (
        .daddr_in(ADC_ADDRESS),    // Fixed address for AUXP5/AUXN5
        .den_in(1'b1),
        .dwe_in(1'b0),
        .do_out(do_out),
        .dclk_in(clk),
        .reset_in(sw[14]),
        .vauxp5(analog_pos_in),
        .vauxn5(analog_neg_in),
        .channel_out(channel_out),
        .eoc_out(eoc_out),
        //.alarm_out(led[6]),
        .alarm_out(),
        //.eos_out(led[7]),
        .eos_out(),
        //.busy_out(led[8]),
        .busy_out()

    );
    
    // --------------------- Clock Divider for Half-Second Tick ---------------------
    
    // This clock divider generates a tick every half second.
    // Assuming clk is 100 MHz, divide by 50,000,000 to get 2 Hz.
    reg [25:0] clk_div_half_sec = 0;
    wire half_sec_tick;
    
    always @(posedge clk or posedge sw[15]) begin
        if (sw[15]) begin
            clk_div_half_sec <= 0;
        end else begin
            if (clk_div_half_sec >= 26'd29999999) begin
                clk_div_half_sec <= 0;
            end else begin
                clk_div_half_sec <= clk_div_half_sec + 1;
            end
        end
    end
    
    assign half_sec_tick = (clk_div_half_sec == 26'd29999999) ? 1'b1 : 1'b0;
    
    // --------------------- Latch XADC Value Every Half Second ---------------------
    
    reg [11:0] latched_value = 0;
    
    always @(posedge clk or posedge sw[15]) begin
        if (sw[15]) begin
            latched_value <= 12'd0;
        end else if (half_sec_tick) begin
            latched_value <= do_out[15:4]; // Capture the upper 12 bits
        end
    end
    
    // --------------------- BCD Conversion ---------------------
    
    wire [15:0] BCD_out;
    wire busy;
    
    Hex2BCD converter (
        .sys_clk(clk),
        .HexIn(latched_value), // 12 bits
        .BCD_out(BCD_out),
        .busy(busy)
    );
    
    // --------------------- Refresh Counter for 7-Segment Multiplexing ---------------------
    
    reg [19:0] refresh_counter = 0;
    wire [1:0] sel; // Selection lines for multiplexing
    
    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
    end
    
    assign sel = refresh_counter[19:18]; // Use the two MSBs for digit selection
    
    // --------------------- 7-Segment Display Logic ---------------------
    
    reg [3:0] digit;
    reg [6:0] seg_reg;
    reg [3:0] an_reg;
    
    // Select which digit to display based on the refresh counter
    always @(*) begin
        case(sel)
            2'b00: begin
                an_reg = 4'b1110; // Enable first digit
                digit = BCD_out[3:0];
            end
            2'b01: begin
                an_reg = 4'b1101; // Enable second digit
                digit = BCD_out[7:4];
            end
            2'b10: begin
                an_reg = 4'b1011; // Enable third digit
                digit = BCD_out[11:8];
            end
            2'b11: begin
                an_reg = 4'b0111; // Enable fourth digit
                digit = BCD_out[15:12];
            end
            default: begin
                an_reg = 4'b1111; // All off
                digit = 4'b0000;
            end
        endcase
    end
    
    // 7-Segment Decoder
    always @(*) begin
        case(digit)
            4'd0: seg_reg = 7'b0000001;
            4'd1: seg_reg = 7'b1001111;
            4'd2: seg_reg = 7'b0010010;
            4'd3: seg_reg = 7'b0000110;
            4'd4: seg_reg = 7'b1001100;
            4'd5: seg_reg = 7'b0100100;
            4'd6: seg_reg = 7'b0100000;
            4'd7: seg_reg = 7'b0001111;
            4'd8: seg_reg = 7'b0000000;
            4'd9: seg_reg = 7'b0000100;
            4'd10: seg_reg = 7'b0001000; // A
            4'd11: seg_reg = 7'b1100000; // B
            4'd12: seg_reg = 7'b0110001; // C
            4'd13: seg_reg = 7'b1000010; // D
            4'd14: seg_reg = 7'b0110000; // E
            4'd15: seg_reg = 7'b0111000; // F
            default: seg_reg = 7'b1111111; // All segments off
        endcase
    end
    
    // Assign the anodes and segments to outputs
    always @(posedge clk) begin
        an <= an_reg;
        seg <= seg_reg;
    end
    
    
    
    //LED CHASER
    
    wire clk_div;  // Divided clock signal

    // Instantiate clock divider
    clk_divider clk_div_inst (
        .clk(clk),
        .clkout(clk_div)
    );

    // Instantiate LED chaser
    led_chaser led_chaser_inst (
        .clk(clk_div),
        .adc_value(do_out),
        .leds(led)
    );
    
    
/*
    
    // --------------------- PWM Control Logic with Smooth Transitions ---------------------
parameter PWM_BITS = 8;         // 8-bit resolution for PWM
reg [PWM_BITS-1:0] pwm_counter = 0; // PWM counter
reg [PWM_BITS-1:0] duty_cycle = 0;  // Current duty cycle
reg [PWM_BITS-1:0] target_duty_cycle = 0; // Target duty cycle from ADC

// Clock divider for smoothing updates
reg [19:0] clock_divider = 0; // Adjust for desired smoothing rate
wire smooth_clk;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        clock_divider <= 0;
    end else begin
        if (clock_divider == 20'd999999) begin // Divide by 1,000,000 for ~100Hz (adjust as needed)
            clock_divider <= 0;
        end else begin
            clock_divider <= clock_divider + 1;
        end
    end
end

assign smooth_clk = (clock_divider == 20'd999999);

// Update the target duty cycle based on ADC value
always @(posedge clk or posedge reset) begin
    if (reset) begin
        target_duty_cycle <= 0;
    end else begin
        target_duty_cycle <= latched_value[11:4]; // Scale 12-bit ADC to 8-bit
    end
end

// Smoothly transition to the target duty cycle
always @(posedge smooth_clk or posedge reset) begin
    if (reset) begin
        duty_cycle <= 0;
    end else if (duty_cycle < target_duty_cycle) begin
        duty_cycle <= duty_cycle + 1; // Increment towards the target
    end else if (duty_cycle > target_duty_cycle) begin
        duty_cycle <= duty_cycle - 1; // Decrement towards the target
    end
end

// PWM Counter Logic
always @(posedge clk or posedge reset) begin
    if (reset) begin
        pwm_counter <= 0;
    end else begin
        pwm_counter <= pwm_counter + 1;
    end
end

// Generate PWM Signal for MOSFET
always @(posedge clk or posedge reset) begin
    if (reset) begin
        mosfet_out <= 0;
    end else begin
        mosfet_out <= (pwm_counter < duty_cycle) ? 1'b1 : 1'b0;
    end
end


*/




 
    // --------------------- PWM Control Logic ---------------------
    parameter PWM_BITS = 8;         // 8-bit resolution for PWM
    reg [PWM_BITS-1:0] pwm_counter = 0; // PWM counter
    reg [PWM_BITS-1:0] duty_cycle = 0;  // Duty cycle from ADC value

    // Scale ADC value to 8-bit for PWM
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            duty_cycle <= 0;
        end else begin
            duty_cycle <= latched_value[11:4]; // Scale 12-bit to 8-bit
        end
    end

    // PWM Counter Logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pwm_counter <= 0;
        end else begin
            pwm_counter <= pwm_counter + 1;
        end
    end

    // Generate PWM Signal for MOSFET
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mosfet_out <= 0;
        end else begin
            mosfet_out <= (pwm_counter < duty_cycle) ? 1'b1 : 1'b0;
        end
    end
    
    
endmodule



module Hex2BCD(
    input sys_clk,            // System clock
    input [11:0] HexIn,       // 12-bit input from XADC
    output reg [15:0] BCD_out,// BCD output for 4 digits
    output reg busy           // Busy flag
);
    // BCD conversion is based on shift-register technique with carry depending on whether value >= 5

    reg [3:0] digit0, digit1, digit2, digit3;
    wire carry0, carry1, carry2;
    reg [4:0] counter = 0;
        
    assign carry0 = (digit0 > 4);
    assign carry1 = (digit1 > 4);
    assign carry2 = (digit2 > 4);

    always @(posedge sys_clk) begin
        if (counter == 0) begin
            digit0 <= 0;
            digit1 <= 0;
            digit2 <= 0;
            digit3 <= 0;
            busy <= 1'b1;
            counter <= counter + 1;
        end
        else if (counter < 13) begin // For 12 bits
            if (carry0)
                digit0 <= {digit0 - 5, HexIn[11 - (counter - 1)]};
            else
                digit0 <= {digit0[2:0], HexIn[11 - (counter - 1)]};
        
            if (carry1)
                digit1 <= {digit1 - 5, carry0};
            else
                digit1 <= {digit1[2:0], carry0};
    
            if (carry2)
                digit2 <= {digit2 - 5, carry1};
            else
                digit2 <= {digit2[2:0], carry1};
    
            digit3 <= {digit3[2:0], carry2};
            counter <= counter + 1;
        end 
        else if (counter == 13 ) begin
            // 12-bit max is 4095, which is less than 9999
            BCD_out <= {digit3, digit2, digit1, digit0};
            busy <= 1'b0;
            counter <= 0;
        end
    end

endmodule






//LED CHASER WITH CLOCK DIVIDER--------------------------------------
module led_chaser(
    input clk,              // 10 Hz clock from clk_divider
    input [11:0] adc_value, // 12-bit ADC value input
    output reg [15:0] leds  // 16-bit output for LEDs
);

    reg [3:0] target_leds;  // Number of LEDs to light (0-15)
    reg [3:0] current_led;  // Current LED being turned on

    // Initialize registers
    initial begin
        target_leds = 0;
        current_led = 0;
        leds = 16'b0;
    end

    // Map ADC value to number of LEDs to light
    always @(posedge clk) begin
        target_leds <= (adc_value * 16) / 4096;  // Map ADC to 0-15 range
    end

    // Cumulative chaser logic
    always @(posedge clk) begin
        if (current_led < target_leds) begin
            leds <= leds | (1 << current_led);  // Turn on current LED (and keep previous on)
            current_led <= current_led + 1;
        end else begin
            current_led <= 0;  // Reset to the first LED
            leds <= 16'b0;     // Clear all LEDs to restart the sequence
        end
    end

endmodule



module clk_divider(
    input clk,             // 100 MHz clock input
    output reg clkout      // Divided clock output
);
    reg [26:0] counter = 0;  // Initialize counter to 0

    always @(posedge clk) begin
        if (counter == 999999) begin  // 10 Hz clock (0.1s period)
            counter <= 0;
            clkout <= ~clkout;  // Toggle clkout
        end else
            counter <= counter + 1;
    end
endmodule


