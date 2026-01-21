`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2024 08:51:53 PM
// Design Name: 
// Module Name: def
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


module Decode_And_Execute(SW,  a_to_g, an);

wire [4-1:0] rd; //buffer for rd result
output wire [6:0] a_to_g;
output [3:0] an;

//output [3:0] an;
input [10:0] SW;

andgate andan0( 0, 0, an[0]);
andgate andan1( 1, 1, an[1]);
andgate andan2( 1, 1, an[2]);
andgate andan3( 1, 1, an[3]);

//switch command : SW[2:0] stands for 'sel', SW[6:3] stands for 'rs', SW[10:7] stands for 'rt

wire [3:0] 
comp,w1,w2,w3,w4,w5,w6,w7,w8;

//SUB
two_complement sc1(SW[10:7], comp);
Ripple_Carry_Adder rca1(SW[6:3], comp, w1);

//ADD
Ripple_Carry_Adder rca2(SW[6:3], SW[10:7], w2);

//BITWISE OR
bitwise_OR bor1(SW[6:3], SW[10:7], w3);

//BITWISE AND
bitwise_AND band1(SW[6:3], SW[10:7], w4);

//RIGHT SHIFT
ARI_Right_Shift rs1(SW[10:7], w5);

//LEFT SHIFT
CIR_Left_Shift ls1(SW[6:3], w6);

//COMPARE LT & EQ
Compare com1(SW[6:3], SW[10:7], w8, w7);

Mux_8x1 mux1(w1, w2, w3, w4, w5, w6, w7, w8, SW[2:0], rd);
hex_7seg h(.rd_in(rd), .common_anode(a_to_g));
endmodule





//111
//output is : equal, less
module Compare(a, b, out1, out2);    
input [3:0] a, b;
output [3:0] out1, out2;

wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11, w12;
wire x1, x2, x3, x4, x5, x6, y1, y2;
wire not_a0, not_a1, not_a2, not_a3;
wire not_b0, not_b1, not_b2, not_b3;

//inner gate wire
wire x33, x44, x55, x56, x66, x67, x77, x78;
//result 1 bit
wire res_less, res_equal;



//complement of input
// First set of not gates
notgate not1 (a[0], not_a0);
notgate not2 (a[1], not_a1);
notgate not3 (a[2], not_a2);
notgate not4 (a[3], not_a3);

notgate not5 (b[0], not_b0);
notgate not6 (b[1], not_b1);
notgate not7 (b[2], not_b2);
notgate not8 (b[3], not_b3);


//operation start Level1
andgate n1(b[3], not_a3, w1);
andgate n2(a[3], not_b3, w3);
Custom_NOR nor1(w1, w3, w2);

andgate n3(b[2], not_a2, w4);
andgate n4(a[2], not_b2, w6);
Custom_NOR nor2(w4, w6, w5);

andgate n5(b[1], not_a1, w7);
andgate n6(a[1], not_b1, w9);
Custom_NOR nor3(w7, w9, w8);

andgate n7(b[0], not_a0, w10);
andgate n8(a[0], not_b0, w12);
Custom_NOR nor4(w10, w12, w11);


//operation Level2
andgate n9(w2, w4, x1);

andgate n10(w2, w6, x2);

andgate n11(w2, w5, x33);
andgate n12(w7, x33, x3);

andgate n13(w2, w5, x44);
andgate n14(w9, x44, x4);

andgate n15(w2, w5, x55);
andgate n16(w8, x55, x56);
andgate n17(w10, x56, x5);

andgate n18(w2, w5, x66);
andgate n19(w8, x66, x67);
andgate n20(w12, x67, x6);

//A=B
andgate n21(w2, w5, x77);
andgate n22(w8, x77, x78);
andgate n23(w11, x78, res_equal);

//A < B (LESS THAN)
orgate or1(w1, x1, y1);
orgate or2(x3, y1, y2);
orgate or3(x5, y2, res_less);



//ASSIGN
assign_val a1[3:1](3'b111, out1[3:1]); //out equal
assign_val a2(res_equal, out1[0]);

assign_val a3[3:1](3'b101, out2[3:1]); //out less than
assign_val a4(res_less, out2[0]);

endmodule

// ======== CIRCULAR LEFT SHIFT ==========
module CIR_Left_Shift(in, out);
    input [3:0] in;
    output [3:0] out;

    assign_val a0(in[2], out[3]);
    assign_val a1(in[1], out[2]);
    assign_val a2(in[0], out[1]);
    assign_val a3(in[3], out[0]);
endmodule

// ======== ARITHMETIC RIGHT SHIFT ==========
module ARI_Right_Shift(in, out);
    input [3:0] in;
    output [3:0] out;

    assign_val a0(in[3], out[3]);
    assign_val a1(in[3], out[2]);
    assign_val a2(in[2], out[1]);
    assign_val a3(in[1], out[0]);
endmodule

// ======== BITWISE OR ==========
module bitwise_OR(a, b, out);
    input [3:0] a, b;
    output [3:0] out;

    orgate or0 (a[0], b[0], out[0]);
    orgate or1 (a[1], b[1], out[1]);
    orgate or2 (a[2], b[2], out[2]);
    orgate or3 (a[3], b[3], out[3]);
endmodule

// ======== BITWISE AND ==========
module bitwise_AND(a, b, out);
    input [3:0] a, b;
    output [3:0] out;

    andgate n0 (a[0], b[0], out[0]);
    andgate n1 (a[1], b[1], out[1]);
    andgate n2 (a[2], b[2], out[2]);
    andgate n3 (a[3], b[3], out[3]);
endmodule

// ======== [DONE] RIPPLE CARRY ==========
module Ripple_Carry_Adder(a, b, sum);
    input [3:0] a, b;
    output [3:0] sum;
    wire c1, c2, c3, c4;
    Full_Adder f0(a[0],b[0],1'b0, c1, sum[0]);
    Full_Adder f1(a[1],b[1],c1, c2, sum[1]);
    Full_Adder f2(a[2],b[2],c2, c3, sum[2]);
    Full_Adder f3(a[3],b[3],c3, c4, sum[3]);
endmodule

// ====== TWO COMPLEMENT  ====
module two_complement(in, out);
    input [3:0] in;
    output [3:0] out;

    wire [3:0] w1;

    notgate not_arr[3:0](in, w1);

    Ripple_Carry_Adder rca1(w1, 4'b0001, out);
endmodule

// ======== [DONE] FULL ADDER ==========

module Full_Adder(
    input a, b, cin,
    output cout, sum
    );
    
wire y1, y2;
xorgate xor1(a, b, y1);
andgate n1(a, b, y2);
xorgate xor2(y1, cin, sum);

majority_vote major1(a, b, cin, cout);
 
endmodule


module majority_vote(
    input a, b, c,
    output out
    );

wire w1, w2, w3, w4;

andgate n1(a, b, w1);
andgate n2(a, c, w2);
orgate or1(w1, w2, w3);
andgate n3(b, c, w4);
orgate or2(w3, w4, out);

endmodule




// ======== [DONE] ASSIGN JGN DIUBAH ==========
module assign_val(in, out);
    input in;
    output out;

    wire w1;

    notgate cnot1(in, w1);
    notgate cnot2(w1, out);
endmodule

// ======== [DONE] NOT ==========
module notgate(in, out);
    input in;
    output out;

    Universal_Gate u1(1'b1, in, out);
endmodule

// ======== [DONE] AND ==========
module andgate(a, b, out);
    input a, b;
    output out;

    wire w;
    Universal_Gate u1(1'b1, b, w);
    Universal_Gate u2(a, w, out);
endmodule

// ======== [DONE] OR ==========
module orgate(a, b, out);
    input a, b;
    output out;

    wire w0, w1;
    Universal_Gate n0(1'b1, a, w0);
    Universal_Gate n1(w0, b, w1);
    Universal_Gate n2(1'b1, w1, out);
endmodule

// ======== [DONE] NAND ==========
module nandgate(out, a, b);
    input a, b;
    output out;

    wire not_out;
    andgate n1(a, b, not_out);
    notgate n2(not_out, out);
endmodule

// ======== [DONE] NOR ==========
module Custom_NOR(a, b, out);
input a, b;
output out;

    wire w;
    orgate or1 (a, b, w);
    notgate not1 (w, out);
endmodule

// ======== [DONE] XOR ==========
module xorgate(a, b, out);
    input a,b;
    output out;

    wire w0, w1, not_a, not_b;
    notgate not1 (a, not_a);
    notgate not2 (b, not_b);

    andgate n1 (a, not_b, w0);
    andgate n2 (not_a, b, w1);

    orgate or1 (w0, w1, out);
endmodule

// ======== [DONE] XNOR ==========
module Custom_XNOR(a, b, out);
    input a,b;   
    output out;  

    wire w;

    xorgate xor1 (a, b, w);
    notgate not1 (w, out);
endmodule


//========= [DONE] 8-to-1 MUX (4-bit) ===============
module Mux_8x1(a, b, c, d, e, f, g, h, sel, out);
    input [3:0] a, b, c, d, e, f, g, h;
    input [2:0] sel;
    output [3:0] out;

    wire [3:0] w0, w1, w2, w3, wa, wb;

    Mux_2x1 m0(a,b,sel[0],w0);
    Mux_2x1 m1(c,d,sel[0],w1);
    Mux_2x1 m2(e,f,sel[0],w2);
    Mux_2x1 m3(g,h,sel[0],w3);

    Mux_2x1 m4(w0,w1,sel[1],wa);
    Mux_2x1 m5(w2,w3,sel[1],wb);

    Mux_2x1 m6(wa,wb,sel[2],out);
endmodule

// ========= [DONE] 2-to-1 MUX (4-bit) ===============
module Mux_2x1(a,b,sel,out);
    input [3:0] a,b;
    input sel;
    output [3:0] out;

    wire w0,w1,w2,w3,w4,w5,w6,w7;
    wire not_sel;

    notgate not1(sel, not_sel);

    andgate n1(a[0], not_sel, w0);
    andgate n2(b[0], sel, w1);
    orgate or1(w0, w1, out[0]);

    andgate n3(a[1], not_sel, w2);
    andgate n4(b[1], sel, w3);
    orgate or2(w2, w3, out[1]);

    andgate n5(a[2], not_sel, w4);
    andgate n6(b[2], sel, w5);
    orgate or3(w4, w5, out[2]);

    andgate n7(a[3], not_sel, w6);
    andgate n8(b[3], sel, w7);
    orgate or4(w6, w7, out[3]);
endmodule

// ======== [DONE] UNIVERSAL GATE ==========
module Universal_Gate(a, b, out);
    input a, b;
    output out;
    wire not_b;

    not (not_b, b);          // NOT b
    and (out, a, not_b);     // a AND NOT b
endmodule












//we map rd to a_to_g, x is rd
module hex_7seg (
    input wire [ 3 : 0] rd_in, 
    output reg [ 6 : 0 ] common_anode);
always @ ( * )
begin
    case ( rd_in )
    0 : common_anode = 7'b0000001 ;
    1 : common_anode = 7'b1001111 ;
    2 : common_anode = 7'b0010010 ;
    3 : common_anode = 7'b0000110 ;
    4 : common_anode = 7'b1001100 ;
    5 : common_anode = 7'b0100100 ;
    6 : common_anode = 7'b0100000 ;
    7 : common_anode = 7'b0001111 ;
    8 : common_anode = 7'b0000000 ;
    9 : common_anode = 7'b0000100 ;
    'hA : common_anode = 7'b0001000 ;
    'hB : common_anode = 7'b1100000 ;
    'hC : common_anode = 7'b0110001 ;
    'hD : common_anode = 7'b1000010 ;
    'hE : common_anode = 7'b0110000 ;
    'hF : common_anode = 7'b0111000 ;
    default : common_anode = 7'b0000001 ;
    endcase
end
endmodule
