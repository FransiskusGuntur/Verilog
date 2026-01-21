`timescale 1ns/1ps

module Traffic_Light_Controller (clk, rst_n, lr_has_car, hw_light, lr_light);
input clk, rst_n;
input lr_has_car;
output reg [2:0] hw_light;
output reg [2:0] lr_light;

// ==== STATE PARAMETERS ====
parameter s0 = 3'b000; // hw green, lr red
parameter s1 = 3'b001; // hw yellow, lr red
parameter s2 = 3'b010; // hw red, lr red
parameter s3 = 3'b011; // hw red, lr green
parameter s4 = 3'b100; // hw red, lr yellow
parameter s5 = 3'b101; // hw red, lr red

// ==== LIGHT PARAMETERS ====
parameter RED = 3'b000;
parameter GREEN = 3'b001;
parameter YELLOW = 3'b010;

// ==== CURR, NEXT, COUNTER ====
reg [2:0] curr_state, next_state;
reg [6:0] counter;

// ==== SEQUENTIAL CIRCUIT : CYCLE UPDATER ====
always @(posedge clk) begin
    if (!rst_n) begin
        curr_state <= s0;
        counter <= 7'd0;
    end else begin
        if (curr_state == next_state) begin
            counter <= counter + 7'd1;
        end 
        else begin
            curr_state <= next_state;
            counter <= 0;
        end
    end
end

// ==== COMBINATIONAL CIRCUIT : NEXT STATE LOGIC & LIGHT CONTROL ====
always @(*) begin
    case (curr_state)
    s0: begin
        hw_light = GREEN;
        lr_light = RED;
        if (lr_has_car && counter >= 7'd69) //in the case that there's a car
            next_state = s1;
        else //no car = reset
            next_state = s0;
    end
    
    s1: begin
        hw_light = YELLOW;
        lr_light = RED;
        if (counter >= 7'd24)
            next_state = s2;
        else
            next_state = s1;
    end
    
    s2: begin
        hw_light = RED;
        lr_light = RED;
        if (counter >= 7'd0)
            next_state = s3;
        else
            next_state = s2;
    end
    
    s3: begin
        hw_light = RED;
        lr_light = GREEN;
        if (counter >= 7'd69)
            next_state = s4;
        else
            next_state = s3;
    end
    
    s4: begin
        hw_light = RED;
        lr_light = YELLOW;
        if (counter >= 7'd24)
            next_state = s5;
        else
            next_state = s4;
    end
    
    s5: begin
        hw_light = RED;
        lr_light = RED;
        if (counter >= 7'd0)
            next_state = s0;
        else
            next_state = s5;
    end
    endcase
end
endmodule
