`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/29/2024 11:47:55 PM
// Design Name: 
// Module Name: param
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


module Parameterized_Ping_Pong_Counter (clk, rst_n, enable, flip, max, min, direction, out);
input clk, rst_n, enable, flip;
input [3:0] max, min;
output direction;
output [3:0] out;


reg direction;
reg [3:0] out;

always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
    begin
        out <= min;
        direction <= 1'b1;
    end

    //handle min-max
    else if(min > max || out > max || out < min)
    begin
        //hold value
        out <= out;

    end

    else if(min == max)
    begin
        out <= min;
        direction <= direction;
    end

    //handle flip condition
    else if( flip && out !=max && out != min )
    begin
        //do stuff
        case(direction)
        1'b1 : out <= out - 1'b1;
        1'b0 : out <= out + 1'b1;
        endcase
        direction = ~direction;
    end

    else if(out == max && direction == 1'b1)
    begin
        out <= max-1;
        direction <= 0;
    end

    else if(out == min && direction == 1'b0)
    begin 
        out <= min + 1;
        direction <= 1'b1;
    end

    else if(enable)
    begin
        case(direction)
        1'b1 : out <= out + 1;
        1'b0 : out <= out - 1;
        endcase

    end
    else 
    out <= out;

end

endmodule
