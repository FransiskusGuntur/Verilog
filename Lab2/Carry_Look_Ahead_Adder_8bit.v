`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/20/2024 10:35:06 PM
// Design Name: 
// Module Name: 4bit_cla
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

module Carry_Look_Ahead_Adder_8bit(a, b, c0, s, c8);
input [8-1:0] a, b;
input c0;
output [8-1:0] s;
output c8;

//create wire for gi, pi, ci
wire c4, g1out, g2out, p1out, p2out;

cla cla1(a[3:0], b[3:0], c0, s[3:0],  g1out, p1out); 
cla cla2(a[7:4], b[7:4], c4, s[7:4],  g2out, p2out);

clala cla3(g1out, p1out, g2out, p2out, c0, c4, c8);


endmodule


//we have to use hierirchal, so need to create seperate module for this


module cla(
    input [3:0] a, b, 
    input c0, 
    output [3:0] s,  
    output gout, pout
);

// Input : g, p, c0 (c previous)
// Create wire for gi, pi, ci but for only 1 block
wire g0, g1, g2, g3, p0, p1, p2, p3;
wire c1, c2, c3, c4;

and_gate n1(a[0], b[0], g0);
and_gate n2(a[1], b[1], g1);
and_gate n3(a[2], b[2], g2);
and_gate n4(a[3], b[3], g3);

xor_gate xor1(a[0], b[0], p0);
xor_gate xor2(a[1], b[1], p1);
xor_gate xor3(a[2], b[2], p2);
xor_gate xor4(a[3], b[3], p3);

// Now combine ci = g + pc(i-1), first set pc(1-i) as d
wire d0, d1, d2, d3;
and_gate n5(p0, c0, d0);  // to put in c1
or_gate or1(g0, d0, c1);
and_gate n6(p1, c1, d1);
or_gate or2(g1, d1, c2);
and_gate n7(p2, c2, d2);
or_gate or3(g2, d2, c3);
and_gate n8(p3, c3, d3);
or_gate or4(g3, d3, c4); //c4 not used directly?



//now obtain s = p xor c
xor_gate xor5(p0, c0, s[0]);
xor_gate xor6(p1, c1, s[1]);
xor_gate xor7(p2, c2, s[2]);
xor_gate xor8(p3, c3, s[3]);



// Now obtain gout, pout
// gout = g3 +| (p3 g2) +| (p3 |p2 g1) +| (p3 p2| p1 g0)  
// pout = p3 p2 p1 p0
// Then later c4 = gout + poutC0

wire y1, y2, y3, y4, y5, y6, y7, y8;

and_gate n9(p1, g0, y1);
and_gate n10(p3, p2, y2);
and_gate n11(y1, y2, y3);

and_gate n12(p2, g1, y4);
and_gate n13(p3, y4, y5);

and_gate n14(p3, g2, y6);

// Now combine from right again
or_gate or5(y3, y5, y7);
or_gate or6(y7, y6, y8);
or_gate or7(y8, g3, gout);

wire w1, w2;
and_gate n15(p0, p1, w1);
and_gate n16(p2, p3, w2);
and_gate n17(w1, w2, pout);


//then later c4 = gout + poutC0 ///dont neeed?? put in 2bit CLA
/*
wire w3;
and_gate n10(pout, c0, w3);
or_gate or4(w3, gout, c4);
*/

 
endmodule




//for the 2 bit CLA, i need c0, p0, p1, p2, p3 and g0, g1, g2, g3 for each 4bit CLA
module clala (
    input g1, p1, g2, p2,   //these are gout, pout
    input c0,
    output c4, c8
);

//then later c4 = gout + poutC0
wire w1;
and_gate n1(p1, c0, w1);
or_gate or1(g1, w1, c4);


//then later c8 = gout + poutC4
wire w2;
and_gate n2(p2, c4, w2);
or_gate or2(g2, w2, c8);

endmodule






 
//make the gates from nand
module and_gate(a, b, out);
input a, b;
output out;
wire w;
nand na1(w, a, b);
nand na2(out, w);
endmodule 

module or_gate(a, b, out);
input a, b;
output out;
wire wa, wb;
nand nand0(wa, a);
nand nand1(wb, b);
nand nand2(out, wa, wb);
endmodule 

module nand_gate(a, b, out);
input a, b;
output out;
nand n(out, a, b);
endmodule



module nor_gate(a, b, out);
input a, b;
output out;
wire w1, w2, w3;
nand na1(w1, a);
nand na2(w2, b);
nand na3(w3, w1, w2);
nand na4(out, w3);
endmodule

module xor_gate(a, b, out);
input a, b;
output out;
wire w1, w3, w4;
nand na1(w1, a, b);
nand na2(w3, w1, a);
nand na3(w4, w1, b);
nand na4(out, w3, w4);
endmodule

module xnor_gate(a, b, out);
input a, b;
output out;
wire w1, w2, w3, w4, w5;
nand na1(w1, a, b);
nand na2(w3, w1, a);
nand na3(w4, w1, b);
nand na4(w5, w3, w4);
nand na5(out, w5);
endmodule
