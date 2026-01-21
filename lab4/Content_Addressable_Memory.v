`timescale 1ns / 1ps

module Content_Addressable_Memory (
    input clk,
    input wen, ren,              // Write and Read Enable
    input [7:0] din,             // 8-bit Data Input
    input [3:0] addr,            // 4-bit Address Input
    output reg [3:0] dout,       // 4-bit Output Address
    output reg hit               // Hit Signal
);

    // 16x8 memory to store 16 sets of 8-bit data
    reg [7:0] CAM [15:0];
    reg [3:0] dout_temp;
    reg hit_temp;


    wire [15:0] match;  


    always @(posedge clk) begin
        dout <= dout_temp;
        hit <= hit_temp;
    end

    assign match[0]  = (din == CAM[0])  ? 1'b1 : 1'b0;
    assign match[1]  = (din == CAM[1])  ? 1'b1 : 1'b0;
    assign match[2]  = (din == CAM[2])  ? 1'b1 : 1'b0;
    assign match[3]  = (din == CAM[3])  ? 1'b1 : 1'b0;
    assign match[4]  = (din == CAM[4])  ? 1'b1 : 1'b0;
    assign match[5]  = (din == CAM[5])  ? 1'b1 : 1'b0;
    assign match[6]  = (din == CAM[6])  ? 1'b1 : 1'b0;
    assign match[7]  = (din == CAM[7])  ? 1'b1 : 1'b0;
    assign match[8]  = (din == CAM[8])  ? 1'b1 : 1'b0;
    assign match[9]  = (din == CAM[9])  ? 1'b1 : 1'b0;
    assign match[10] = (din == CAM[10]) ? 1'b1 : 1'b0;
    assign match[11] = (din == CAM[11]) ? 1'b1 : 1'b0;
    assign match[12] = (din == CAM[12]) ? 1'b1 : 1'b0;
    assign match[13] = (din == CAM[13]) ? 1'b1 : 1'b0;
    assign match[14] = (din == CAM[14]) ? 1'b1 : 1'b0;
    assign match[15] = (din == CAM[15]) ? 1'b1 : 1'b0;


    always @(*) begin
        if (ren) begin

            case (1'b1)
                match[15]: {dout_temp, hit_temp} = {4'b1111, 1'b1};
                match[14]: {dout_temp, hit_temp} = {4'b1110, 1'b1};
                match[13]: {dout_temp, hit_temp} = {4'b1101, 1'b1};
                match[12]: {dout_temp, hit_temp} = {4'b1100, 1'b1};
                match[11]: {dout_temp, hit_temp} = {4'b1011, 1'b1};
                match[10]: {dout_temp, hit_temp} = {4'b1010, 1'b1};
                match[9]:  {dout_temp, hit_temp} = {4'b1001, 1'b1};
                match[8]:  {dout_temp, hit_temp} = {4'b1000, 1'b1};
                match[7]:  {dout_temp, hit_temp} = {4'b0111, 1'b1};
                match[6]:  {dout_temp, hit_temp} = {4'b0110, 1'b1};
                match[5]:  {dout_temp, hit_temp} = {4'b0101, 1'b1};
                match[4]:  {dout_temp, hit_temp} = {4'b0100, 1'b1};
                match[3]:  {dout_temp, hit_temp} = {4'b0011, 1'b1};
                match[2]:  {dout_temp, hit_temp} = {4'b0010, 1'b1};
                match[1]:  {dout_temp, hit_temp} = {4'b0001, 1'b1};
                match[0]:  {dout_temp, hit_temp} = {4'b0000, 1'b1};
                default:   {dout_temp, hit_temp} = {4'b0000, 1'b0};
            endcase

        end
        else if (wen && !ren) begin

            CAM[addr] = din;
            {dout_temp, hit_temp} = {4'b0000, 1'b0};
        end
        else begin
            // Default case: No operation
            {dout_temp, hit_temp} = {4'b0000, 1'b0};
        end
    end

endmodule


