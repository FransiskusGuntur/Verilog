`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/02/2024 10:26:08 PM
// Design Name: 
// Module Name: simul
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


`timescale 1ns/1ps

module Round_Robin_FIFO_Arbiter_tb;
    reg clk;
    reg rst_n;
    reg [3:0] wen;       // Write enable for each FIFO
    reg [7:0] a, b, c, d; // Input data for each FIFO
    wire [7:0] dout;     // Output data from the arbiter
    wire valid;          // Valid signal from the arbiter

    // Instantiate the Round Robin FIFO Arbiter
    Round_Robin_FIFO_Arbiter uut (
        .clk(clk),
        .rst_n(rst_n),
        .wen(wen),
        .a(a),
        .b(b),
        .c(c),
        .d(d),
        .dout(dout),
        .valid(valid)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock period of 10ns
    end
    
    
    /*
    initial begin
   $dumpfile("Round_Robin_FIFO_Arbiter_tb");
   $dumpvars(0, Round_Robin_FIFO_Arbiter_tb);
    end
    */

    // Test sequence
    initial begin
        // Initialize inputs
        rst_n = 0;
        wen = 4'b0000;
        a = 8'd0;
        b = 8'd0;
        c = 8'd0;
        d = 8'd0;

        // Apply reset
        #10 rst_n = 1; // Release reset after 10ns

        // Write to FIFO A, B, C, D sequentially
        #10 wen = 4'b0001; a = 8'd10;  // Write 10 to FIFO A
        #10 wen = 4'b0010; b = 8'd20;  // Write 20 to FIFO B
        #10 wen = 4'b0100; c = 8'd30;  // Write 30 to FIFO C
        #10 wen = 4'b1000; d = 8'd40;  // Write 40 to FIFO D

        // Write to multiple FIFOs simultaneously
        #10 wen = 4'b1100; c = 8'd50; d = 8'd60; // Write 50 to FIFO C and 60 to FIFO D
        
        // Disable write enable for reading
        #10 wen = 4'b0000;

        // Observe round-robin read behavior
        #50; // Allow multiple clock cycles for round-robin reads

        // Test simultaneous read and write (conflict scenario)
        #10 wen = 4'b0001; a = 8'd70;  // Write 70 to FIFO A while reading

        // Disable write to allow reading
        #10 wen = 4'b0000;
        
        
        #10 rst_n = 0;
        #10 rst_n = 1;

       //simulation in ppt
        #20;
        
        #10 wen = 4'b1111; a = 87; b = 56; c = 9; d = 13;
        #10 d = 85; wen = 4'b1000;
        #10 c = 139; wen = 4'b0100;
        wen = 4'b0000;
        #30 a = 51; wen = 4'b0001;
        
        

        // Finish simulation after some time
        #500 $finish;
    end

    // Monitor signals for debugging
    initial begin
        $monitor("Time=%0t | rst_n=%b | wen=%b | a=%d | b=%d | c=%d | d=%d | dout=%d | valid=%b",
                 $time, rst_n, wen, a, b, c, d, dout, valid);
    end

endmodule

