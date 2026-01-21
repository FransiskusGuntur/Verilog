`timescale 1ns / 1ps

module Greatest_Common_Divisor (clk, rst_n, start, a, b, done, gcd);
input clk, rst_n;
input start;
input [15:0] a;
input [15:0] b;
output done;
output [15:0] gcd;

parameter WAIT = 2'b00;
parameter CAL = 2'b01;
parameter FINISH = 2'b10;

reg done; 
reg [15:0] gcd;

reg [1:0] state, next_state;
reg [15:0] a_reg, b_reg;
reg [1:0] finish_counter;

always @(posedge clk) begin
    if (!rst_n) begin
        state <= WAIT;
        a_reg <= 16'd0;
        b_reg <= 16'd0;
        finish_counter <= 2'b00;
       end
    else
        state <= next_state;
        /*
        if (finish_counter == 2'b01) begin
        state <= WAIT;
        */
        
end


always @(posedge clk) begin
    if (!rst_n) begin
        a_reg <= 16'd0;
        b_reg <= 16'd0;
        finish_counter <= 2'b00;
    end 
    
    else begin
        case (state)
            WAIT: begin
                if (start) begin
                    a_reg <= a;
                    b_reg <= b;
                    finish_counter <= 2'b00;
                end
            end

            CAL: begin
                if (a_reg > b_reg) begin
                    a_reg <= a_reg - b_reg;
                end else begin
                    b_reg <= b_reg - a_reg;
                end
            end

            FINISH: begin
                finish_counter <= finish_counter + 1;
            end
        endcase
    end
end

//HANDLE STATE COMBINATIONAL
always @(*) begin
    next_state = state;
    done = 1'b0; // Default: done is low
    gcd = 16'd0; // Default: gcd is zero

    case (state)
        WAIT: begin
            if (start) begin
                next_state = CAL;
            end
        end //default to WAIT

        CAL: begin
            if (a_reg == 0) begin
                next_state = FINISH;
            end 
            
            else if (b_reg == 0) begin
                next_state = FINISH;
            end 
        
            else if (a_reg > b_reg) begin
                next_state = CAL;
            end 
            else begin
                next_state = CAL;
            end
        end

        FINISH: begin
            done = 1'b1;
            gcd = (a_reg == 0) ? b_reg : a_reg;
            
            if (finish_counter == 2'b01) begin
                next_state = WAIT;
            end
            
            //else 
            //finish_counter <= finish_counter + 1;

        end
    endcase
end

    

endmodule
