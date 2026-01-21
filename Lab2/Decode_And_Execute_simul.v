`timescale 1ns / 1ps

module decode_execute_tb;

    // Inputs
    reg [3:0] rs;      // Source Register 1
    reg [3:0] rt;      // Source Register 2
    reg [2:0] sel;     // Selection Signal

    // Output
    wire [3:0] rd;     // Result Register

    // Instantiate the decode_execute module
    Decode_And_Execute uut (
        .rs(rs),
        .rt(rt),
        .sel(sel),
        .rd(rd)
    );

    initial begin
        // Initialize Inputs
        rs = 4'b0000;
        rt = 4'b0000;
        sel = 3'b000;

        // Wait for global reset
        #10;

        // -----------SUBTRACTION----------------------
        // Test Case 1: Subtraction (sel = 000)
        // Operation: rd = rs - rt
        // Example: 4 - 2 = 2
        sel = 3'b000; 
        rs = 4'b0100; // 4
        rt = 4'b0010; // 2
        #10;
        $display("Test Case 1: sel=000 (Subtraction)");
        $display("Input: rs=%d, rt=%d | Output: rd=%d (Expected: 2)\n", rs, rt, rd);

        // Test Case 1.1: Subtraction (sel = 000)
        // Operation: rd = rs - rt
        // Example: 15-12 = 3
        sel = 3'b000; 
        rs = 4'b1111; // 15
        rt = 4'b1100; // 12
        #10;
        $display("Test Case 1: sel=000 (Subtraction)");
        $display("Input: rs=%d, rt=%d | Output: rd=%d (Expected: 2)\n", rs, rt, rd);

        // Test Case 1.2: Subtraction (sel = 000)
        // Operation: rd = rs - rt
        // Example: 15-15=0
        sel = 3'b000; 
        rs = 4'b1111; // 15
        rt = 4'b1111; // 15
        #10;
        $display("Test Case 1: sel=000 (Subtraction)");
        $display("Input: rs=%d, rt=%d | Output: rd=%d (Expected: 2)\n", rs, rt, rd);


        // -----------ADDITION----------------------
        // Test Case 2: Addition (sel = 001)
        // Operation: rd = rs + rt
        // Example: 3 + 2 = 5
        sel = 3'b001; 
        rs = 4'b0011; // 3
        rt = 4'b0010; // 2
        #10;
        $display("Test Case 2: sel=001 (Addition)");
        $display("Input: rs=%d, rt=%d | Output: rd=%d (Expected: 5)\n", rs, rt, rd);

        // Test Case 2.1: Addition (sel = 001)
        // Operation: rd = rs + rt
        // Example: 13 + 2 = 15
        sel = 3'b001; 
        rs = 4'b1101; // 13
        rt = 4'b0010; // 2
        #10;
        $display("Test Case 2: sel=001 (Addition)");
        $display("Input: rs=%d, rt=%d | Output: rd=%d (Expected: 5)\n", rs, rt, rd);

        // -----------BITWISE AND----------------------
        // Test Case 3: Bitwise AND (sel = 010)
        // Operation: rd = rs & rt
        // Example: 12 & 10 = 8
        sel = 3'b010; 
        rs = 4'b1100; // 12
        rt = 4'b1010; // 10
        #10;
        $display("Test Case 3: sel=010 (Bitwise AND)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1000)\n", rs, rt, rd);

        // Test Case 3.1: Bitwise AND (sel = 010)
        // Operation: rd = rs & rt
        // Example: 15 & 0 = 0
        sel = 3'b010; 
        rs = 4'b1111; // 15
        rt = 4'b0000; // 0
        #10;
        $display("Test Case 3: sel=010 (Bitwise AND)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1000)\n", rs, rt, rd);

        // Test Case 3.2: Bitwise AND (sel = 010)
        // Operation: rd = rs & rt
        // Example: 0 & 15 = 0
        sel = 3'b010; 
        rs = 4'b0000; // 0
        rt = 4'b1111; // 15
        #10;
        $display("Test Case 3: sel=010 (Bitwise AND)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1000)\n", rs, rt, rd);

        // Test Case 3.3: Bitwise AND (sel = 010)
        // Operation: rd = rs & rt
        // Example: 15 & 15 = 15
        sel = 3'b010; 
        rs = 4'b1111; // 15
        rt = 4'b1111; // 15
        #10;
        $display("Test Case 3: sel=010 (Bitwise AND)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1000)\n", rs, rt, rd);

        // Test Case 3.4: Bitwise AND (sel = 010)
        // Operation: rd = rs & rt
        // Example: 0 & 0 = 0
        sel = 3'b010; 
        rs = 4'b0000; // 0
        rt = 4'b0000; // 0
        #10;
        $display("Test Case 3: sel=010 (Bitwise AND)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1000)\n", rs, rt, rd);

        // -----------BITWISE OR----------------------
        // Test Case 4: Bitwise OR (sel = 011)
        // Operation: rd = rs | rt
        // Example: 12 | 10 = 14
        sel = 3'b010; 
        rs = 4'b1100; // 12
        rt = 4'b1010; // 10
        #10;
        $display("Test Case 4: sel=011 (Bitwise OR)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1110)\n", rs, rt, rd);

        // Test Case 4.1: Bitwise OR (sel = 011)
        // Operation: rd = rs | rt
        // Example: 15 | 0 = 15
        sel = 3'b011; 
        rs = 4'b1111; // 15
        rt = 4'b0000; // 0
        #10;
        $display("Test Case 4: sel=011 (Bitwise OR)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1110)\n", rs, rt, rd);

        // Test Case 4.2: Bitwise OR (sel = 011)
        // Operation: rd = rs | rt
        // Example: 0 | 15 = 15
        sel = 3'b011; 
        rs = 4'b0000; // 0
        rt = 4'b1111; // 15
        #10;
        $display("Test Case 4: sel=011 (Bitwise OR)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1110)\n", rs, rt, rd);

        // Test Case 4.3: Bitwise OR (sel = 011)
        // Operation: rd = rs | rt
        // Example: 15 | 15 = 15
        sel = 3'b011; 
        rs = 4'b1111; // 15
        rt = 4'b1111; // 15
        #10;
        $display("Test Case 4: sel=011 (Bitwise OR)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1110)\n", rs, rt, rd);

        // Test Case 4.4: Bitwise OR (sel = 011)
        // Operation: rd = rs | rt
        // Example: 0 | 0 = 0
        sel = 3'b011; 
        rs = 4'b0000; // 0
        rt = 4'b0000; // 0
        #10;
        $display("Test Case 4: sel=011 (Bitwise OR)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1110)\n", rs, rt, rd);

        // -----------ARITH SHIFT RIGHT----------------------
        // Test Case 5: Arithmetic Shift Right (sel = 100)
        // Operation: rd = rs >>> 1 (Preserve MSB)
        // Example: 9 (1001) >>> 1 = 12 (1100)
        sel = 3'b100; 
        rs = 4'b0000; // Unused
        rt = 4'b1001; // 9
        #10;
        $display("Test Case 5: sel=100 (Arithmetic Shift Right)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1100)\n", rs, rt, rd);

        // Test Case 5.1: Arithmetic Shift Right (sel = 100)
        // Operation: rd = rs >>> 1 (Preserve MSB)
        // Example: 2 (0010) >>> 1 = 1 (0001)
        sel = 3'b100; 
        rs = 4'b0000; // Unused
        rt = 4'b0010; // 2
        #10;
        $display("Test Case 5: sel=100 (Arithmetic Shift Right)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1100)\n", rs, rt, rd);

        // Test Case 5.2: Arithmetic Shift Right (sel = 100)
        // Operation: rd = rs >>> 1 (Preserve MSB)
        // Example: 1 (0010) >>> 1 = 0? 
        sel = 3'b100; 
        rs = 4'b0000; // Unused
        rt = 4'b0001; // 1
        #10;
        $display("Test Case 5: sel=100 (Arithmetic Shift Right)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1100)\n", rs, rt, rd);

        // Test Case 5.3: Arithmetic Shift Right (sel = 100)
        // Operation: rd = rs >>> 1 (Preserve MSB)
        // Example: 8 (1000) >>> 1 = 12 (C)
        sel = 3'b100; 
        rs = 4'b0000; // Unused
        rt = 4'b1000; // 8
        #10;
        $display("Test Case 5: sel=100 (Arithmetic Shift Right)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 1100)\n", rs, rt, rd);
        
        // -----------CIRC SHIFT LEFT----------------------
        // Test Case 6: Circular Shift Left (sel = 101)
        // Operation: rd = rs <<< 1 (Circular)
        // Example: 9 (1001) <<< 1 = 3 (0011)
        sel = 3'b101; 
        rs = 4'b1001; // 9
        rt = 4'b0000; // Unused
        #10;
        $display("Test Case 6: sel=101 (Circular Shift Left)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 0011)\n", rs, rt, rd);

        // Test Case 6.1: Circular Shift Left (sel = 101)
        // Operation: rd = rs <<< 1 (Circular)
        // Example: 8 (1000) <<< 1 = 1 (0001)
        sel = 3'b101; 
        rs = 4'b1000; // 8
        rt = 4'b0000; // Unused
        #10;
        $display("Test Case 6: sel=101 (Circular Shift Left)");
        $display("Input: rs=%b, rt=%b | Output: rd=%b (Expected: 0011)\n", rs, rt, rd);

        // -----------COMP LESS THAN----------------------
        // Test Case 7: Less Than (sel = 110)
        // Operation: rd = (rs < rt) ? 1 : 0
        // Example: 2 < 4 = 1011 (11 -> b)
        sel = 3'b110; 
        rs = 4'b0010; // 2
        rt = 4'b0100; // 4
        #10;
        $display("Test Case 7: sel=110 (Less Than)");
        $display("Input: rs=%d, rt=%d | Output: rd=%b (Expected: 0001)\n", rs, rt, rd);

        // Test Case 7.1: Less Than (sel = 110)
        // Operation: rd = (rs < rt) ? 1 : 0
        // Example: 6 < 4 = 1010 (10 -> A)
        sel = 3'b110; 
        rs = 4'b0110; // 6
        rt = 4'b0100; // 4
        #10;
        $display("Test Case 7: sel=110 (Less Than)");
        $display("Input: rs=%d, rt=%d | Output: rd=%b (Expected: 0001)\n", rs, rt, rd);

        // -----------COMP EQUAL TO----------------------
        // Test Case 8: Equal To (sel = 111)
        // Operation: rd = (rs == rt) ? 1 : 0
        // Example: 6 == 6 = 1111 (15 -> F)
        sel = 3'b111; 
        rs = 4'b0110; // 6
        rt = 4'b0110; // 6
        #10;
        $display("Test Case 8: sel=111 (Equal To)");
        $display("Input: rs=%d, rt=%d | Output: rd=%b (Expected: 0001)\n", rs, rt, rd);

        // Test Case 8.1: Equal To (sel = 111)
        // Operation: rd = (rs == rt) ? 1 : 0
        // Example: 6 == 7 = 1110 (14 -> E)
        sel = 3'b111; 
        rs = 4'b0110; // 6
        rt = 4'b0111; // 7
        #10;
        $display("Test Case 8: sel=111 (Equal To)");
        $display("Input: rs=%d, rt=%d | Output: rd=%b (Expected: 0001)\n", rs, rt, rd);

        // Finish simulation
        #10;
        $finish;
    end

endmodule