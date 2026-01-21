`timescale 1ns/1ps

module Multiplier_4bit(a, b, p);
input [4-1:0] a, b;
output [8-1:0] p;



wire w1, w11, w2, w22, w3, w33, w4;
wire x1, x11, x2, x22, x3, x33;  //x33 not used? see diagram
wire y1, y22, y3, y33;
wire z1, z2, z3;

wire c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10;

and_gate n1(a[0], b[0], p[0]);
and_gate n2(a[1], b[0], w11);
and_gate n3(a[2], b[0], w22);
and_gate n4(a[3], b[0], w33);

and_gate n5(a[0], b[1], w1);
and_gate n6(a[1], b[1], w2);
and_gate n7(a[2], b[1], w3);
and_gate n8(a[3], b[1], w4);

Half_Adder ha1(w1, w11, p[1], c0);     // a, b, sum, cout
Half_Adder ha2(w2, w22, x11, c1);
Half_Adder ha3(w3, w33, x22, c2);

and_gate n9(a[0], b[2], x1);
and_gate n10(a[1], b[2], x2);
and_gate n11(a[2], b[2], x3);
and_gate n12(a[3], b[2], y33);

Full_Adder fa1(x1, x11, c0, p[2], c3);    // a, b, cin, sum, cout
Full_Adder fa2(x2, x22, c1, y11, c4); 
Full_Adder fa3(x3, w4, c2, y22, c5);     //x33 not used

and_gate n13(a[0], b[3], y1);
and_gate n14(a[1], b[3], y2);
and_gate n15(a[2], b[3], y3);
and_gate n16(a[3], b[3], z3);

Full_Adder fa4(y1, y11, c3, p[3], c6);
Full_Adder fa5(y2, y22, c4, z1, c7);
Full_Adder fa6(y3, y33, c5, z2, c8);

Half_Adder ha4(z1, c6, p[4], c9);
Full_Adder fa7(z2, c7, c9, p[5], c10);
Full_Adder fa8(z3, c8, c10, p[6], p[7]);


endmodule






module Half_Adder(
    input a, b,
    output sum, cout
    );
    
xor_gate xor1(a, b, sum);
and_gate n1(a,b, cout);

endmodule



module Full_Adder(
    input a, b, cin,
    output sum, cout
    );
    
wire y1, y2;
xor_gate xor1(a, b, y1);
and_gate n1(a, b, y2);
xor_gate xor2(y1, cin, sum);

majority_vote major1(a, b, cin, cout);
 
endmodule



module majority_vote(
    input a, b, c,
    output out
    );

wire w1, w2, w3, w4;

and_gate n1(a, b, w1);
and_gate n2(a, c, w2);
or_gate or1(w1, w2, w3);
and_gate n3(b, c, w4);
or_gate or2(w3, w4, out);

endmodule



module and_gate(
    input a, b,
    output out
);
wire y1;
nand na1(y1, a, b);
nand na2(out, y1, y1);
endmodule



module or_gate(
   
    input a, b,
    output out
    );

wire y1, y2;
nand na1(y1, a, a);
nand na2(y2, b, b);
nand na3(out, y1, y2);

endmodule



module xor_gate(
    input a, b, 
    output out 
    );
    
wire na, nb, y1, y2;
nand na1(na, a, a);
nand na2(nb, b, b);
nand na3(y1, na, b);
nand na4(y2, nb, a);
nand na5(out, y1, y2);

endmodule