`timescale 1ns / 1ps

module uart_top_tb;

    // Parameters for the UART module
    parameter DBITS = 8;
    parameter SB_TICK = 16;
    parameter BR_LIMIT = 651;
    parameter BR_BITS = 10;
    parameter FIFO_EXP = 2;

    // Testbench signals
    reg clk_100MHz;
    reg reset;
    reg write_uart;
    reg [DBITS-1:0] write_data;
    wire tx;

    // Instantiate the UART top module
    uart_top #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK),
        .BR_LIMIT(BR_LIMIT),
        .BR_BITS(BR_BITS),
        .FIFO_EXP(FIFO_EXP)
    ) uut (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .write_uart(write_uart),
        .write_data(write_data),
        .tx(tx)
    );

    // Clock generation
    initial begin
        clk_100MHz = 0;
        forever #5 clk_100MHz = ~clk_100MHz; // 100MHz clock (10ns period)
    end

    // Test stimulus
    initial begin
        // Initialize inputs
        reset = 1;
        write_uart = 0;
        write_data = 8'b0;

        // Wait for global reset
        #20;
        reset = 0;

        // Write data to FIFO and observe transmission
        @(posedge clk_100MHz);
        write_data = 8'b10101010; // Example data to transmit
        write_uart = 1;

        @(posedge clk_100MHz);
        write_uart = 0; // De-assert write signal

        // Wait for a few clock cycles
        repeat(500000) @(posedge clk_100MHz);

        // Write another piece of data
        @(posedge clk_100MHz);
        write_data = 8'b11001100; // Another example data
        write_uart = 1;

        @(posedge clk_100MHz);
        write_uart = 0;

        // Wait for transmission to complete
        repeat(200) @(posedge clk_100MHz);

        // End simulation
        $stop;
    end

    // Monitor tx signal for verification
    initial begin
        $monitor("Time: %0t | TX: %b", $time, tx);
    end

endmodule
