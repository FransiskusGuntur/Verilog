`timescale 1ns / 1ps

module rca_t;
    reg [7:0] a, b;
    reg cin;
    wire [7:0] sum;
    wire cout;

     Ripple_Carry_Adder UUT(
        .a(a), 
        .b(b), 
        .cin(cin),
        .cout(cout), 
        .sum(sum)
    );

    initial begin
        //case 1: 0+0, cin = 0
        a = 8'b00000000;
        b = 8'b00000000;
        cin = 1'b0;
        #10; 
        
        //case 2: full+0, cin = 1
        a = 8'b11111111;
        b = 8'b00000000;
        cin = 1'b1;
        #10;

        //case 3: full + full, cin = 0
        a = 8'b11111111;
        b = 8'b11111111;
        cin = 1'b0;
        #10;  

        //case 4: random, cin = 0
        a = 8'b10101010;
        b = 8'b11001100;
        cin = 1'b0;
        #10; 

        //case 5: random, cin = 1
        a = 8'b10101010;
        b = 8'b11001100;
        cin = 1'b1;
        #10; 

        //case 6: overflow
        a = 8'b10000000;
        b = 8'b10000000;
        cin = 1'b0;
        #10; 

        //case 7: half, cin = 0
        a = 8'b00000000;
        b = 8'b11110000;
        cin = 1'b0;
        #10; 

        // Test Case 8: half, cin = 1
        a = 8'b00000000;
        b = 8'b11110000;
        cin = 1'b1;
        #10; 

        $finish();
    end
endmodule