`timescale 1ns/1ps

module Mealy_Sequence_Detector (clk, rst_n, in, dec);
input clk, rst_n;
input in;
output reg dec;
reg [3:0] curr_state, next_state;

parameter s0=4'b0000;
parameter s1=4'b0001;
parameter s2=4'b0010;
parameter s3=4'b0011;
parameter s4=4'b0100;
parameter s5=4'b0101;
parameter s6=4'b0110;
parameter s7=4'b0111;
parameter s8=4'b1000;
parameter s9=4'b1001;

always @(posedge clk)
begin   
    if (!rst_n) curr_state <= s0;
    else curr_state <= next_state;
end 

always @(*) begin
    //nothing is detected yet
    dec = 1'b0;
    case (curr_state)
        s0:
            if(in == 1)begin
                next_state = s4;
            end
            else begin
                next_state = s1;
            end

        s1:
            if(in == 1)begin
                next_state = s2;
            end
            else begin
                next_state = s8;
            end

        s2:
            if(in == 1)begin
                next_state = s3;
            end
            else begin
                next_state = s9;
            end

        s3:
            if(in == 1)begin
                next_state = s0;
                dec = 1'b1; //detects 1001 from s5 or 0111 from s2
            end
            else begin
                next_state = s0;
            end

        s4:
            if(in == 1)begin
                next_state = s6;
            end
            else begin
                next_state = s5;
            end

        s5:
            if(in == 1)begin
                next_state = s9;
            end
            else begin
                next_state = s3;
            end

        s6:
            if(in == 1)begin
                next_state = s7;
            end
            else begin
                next_state = s9;
            end

        s7:
            if(in == 1)begin
                next_state = s0;
            end
            else begin
                next_state = s0;
                dec = 1'b1; //detects 1110
            end

        s8:
            if(in == 1)begin
                next_state = s9;
            end
            else begin
                next_state = s9;
            end

        s9:
            if(in == 1)begin
                next_state = s0;
            end
            else begin
                next_state = s0;
            end

        default:
            begin
                next_state = s0;
            end
    endcase
end
endmodule