`timescale 1ns/1ps

module Ripple_Carry_Adder(a, b, cin, cout, sum);
    input [8-1:0] a, b;
    input cin;
    output cout;
    output [8-1:0] sum;

    wire c0, c1, c2, c3, c4, c5, c6;
    fulladder f0(.a(a[0]), .b(b[0]), .cin(cin), .cout(c1), .sum(sum[0]));
    fulladder f1(.a(a[1]), .b(b[1]), .cin(c1), .cout(c2), .sum(sum[1]));
    fulladder f2(.a(a[2]), .b(b[2]), .cin(c2), .cout(c3), .sum(sum[2]));
    fulladder f3(.a(a[3]), .b(b[3]), .cin(c3), .cout(c4), .sum(sum[3]));
    fulladder f4(.a(a[4]), .b(b[4]), .cin(c4), .cout(c5), .sum(sum[4]));
    fulladder f5(.a(a[5]), .b(b[5]), .cin(c5), .cout(c6), .sum(sum[5]));
    fulladder f6(.a(a[6]), .b(b[6]), .cin(c6), .cout(c7), .sum(sum[6]));
    fulladder f7(.a(a[7]), .b(b[7]), .cin(c7), .cout(cout), .sum(sum[7]));
endmodule

module fulladder(a, b, cin, sum, cout);
    input a, b, cin;
    output sum, cout;
    wire not_cin, mout, not_cout;

    notgate not0(.a(cin), .out(not_cin));

    majoritygate m0(.a(a), .b(b), .c(cin), .out(cout));
    majoritygate m1(.a(a), .b(b), .c(not_cin), .out(mout));

    notgate not1(.a(cout), .out(not_cout));
    majoritygate m2(.a(not_cout), .b(cin), .c(mout), .out(sum));
endmodule

module majoritygate(a, b, c, out);
    input a, b, c;
    output out;

    wire and0, and1, and2, or0;

    andmod andgate0(.a(a), .b(b), .out(and0));
    andmod andgate1(.a(a), .b(c), .out(and1));
    andmod andgate2(.a(b), .b(c), .out(and2));

    ormod orgate0(.a(and0), .b(and1), .out(or0));
    ormod orgate1(.a(or0), .b(and2), .out(out));
endmodule

module andmod(a, b, out);
    input a, b;
    output out;
    wire nand_out;

    nand (nand_out, a, b);
    nand (out, nand_out, nand_out);
endmodule

module ormod(a, b, out);
    input a, b;
    output out;
    wire nand0_out, nand1_out;

    nand (nand0_out, a, a);
    nand (nand1_out, b, b);
    nand (out, nand0_out, nand1_out);
endmodule

module notgate(a, out);
    input a;
    output out;

    nand (out, a, a);
endmodule
