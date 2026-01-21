`timescale 1ns/1ps




module Round_Robin_FIFO_Arbiter(clk, rst_n, wen, a, b, c, d, dout, valid);
input clk;
input rst_n;
input [4-1:0] wen;
input [8-1:0] a, b, c, d;
output [8-1:0] dout;
output valid;

//reg [7:0] dout;
//reg valid;
reg valid_temp = 1'b0;

//reg valid;


//define top module connection
wire [7:0] FIFO_curr_a, FIFO_curr_b, FIFO_curr_c, FIFO_curr_d; //fifo to arbiter
reg [7:0] FIFO_curr_dout;
reg [1:0] FIFO_curr;
reg [1:0] FIFO_next;


//module FIFO_8(clk, rst_n, wen, ren, din, dout, error); from qns
parameter FIFO_a = 2'b00;
parameter FIFO_b = 2'b01;
parameter FIFO_c = 2'b10;
parameter FIFO_d = 2'b11;


always @(posedge clk or negedge rst_n) begin
    if(!rst_n) 
    begin
        FIFO_curr <= FIFO_a;
        FIFO_next <= FIFO_next; //x condition
        //dout <= 8'd0;

    end
    else
    begin
        FIFO_curr <= FIFO_curr + 2'b01;
        FIFO_next <= FIFO_curr;

        //dout <= FIFO_curr_dout;
        //valid <= (valid_temp) ? 1'b1 : 1'b0;
    end
end



wire ren_a, ren_b, ren_c, ren_d;
wire ren_a_enable, ren_b_enable, ren_c_enable, ren_d_enable;

assign ren_a = (FIFO_curr == FIFO_a) ? 1'b1 : 1'b0;
assign ren_b = (FIFO_curr == FIFO_b) ? 1'b1 : 1'b0;
assign ren_c = (FIFO_curr == FIFO_c) ? 1'b1 : 1'b0;
assign ren_d = (FIFO_curr == FIFO_d) ? 1'b1 : 1'b0;


//we need to buffer read signal
//without this, our circuit will OUTPUT a,b,c, or d values directly when 
//ren 0000 (or when ren for that fifo), so it will skip the previous (if any)
//store data inside the fifo
//triggers ptr read?
assign ren_a_enable = (ren_a == 1'b1 && wen[0] == 1'b1)? 1'b0 : ren_a;
assign ren_b_enable = (ren_b == 1'b1 && wen[1] == 1'b1)? 1'b0 : ren_b;
assign ren_c_enable = (ren_c == 1'b1 && wen[2] == 1'b1)? 1'b0 : ren_c;
assign ren_d_enable = (ren_d == 1'b1 && wen[3] == 1'b1)? 1'b0 : ren_d;


 
//above changes for every turn : ie, if a's turn, ren_a = 1, but if we actually want to write, 


wire error_a, error_b, error_c, error_d;
FIFO_8 fa(clk, rst_n, wen[0], ren_a_enable, a, FIFO_curr_a, error_a);
FIFO_8 fb(clk, rst_n, wen[1], ren_b_enable, b, FIFO_curr_b, error_b);
FIFO_8 fc(clk, rst_n, wen[2], ren_c_enable, c, FIFO_curr_c, error_c);
FIFO_8 fd(clk, rst_n, wen[3], ren_d_enable, d, FIFO_curr_d, error_d);



//check ren_a, 
//PUT TO FIFO
//other alternative : do all in a single always block 
//need to initialize var
//need to add temporary valid signal?

//COMBINATIONAL
always @(*) begin

    if(!rst_n) begin
    valid_temp = 1'b0;
    FIFO_curr_dout = 8'd0;
    end
    
    else 
    begin

    case(FIFO_next)
        FIFO_a : 
            if(!wen[0] && !error_a)
            begin
                FIFO_curr_dout = FIFO_curr_a;
                valid_temp = 1'b1;
            end
            else
            begin
                FIFO_curr_dout = 8'd0;
                valid_temp = 1'b0; 
            end
        
        FIFO_b : 
            if(!wen[1] && !error_b)
            begin
                FIFO_curr_dout = FIFO_curr_b;
                valid_temp = 1'b1;
            end
            else
            begin
                FIFO_curr_dout = 8'd0;
                valid_temp = 1'b0;
            end

        FIFO_c :
        if(!wen[2] && !error_c)
        begin 
            FIFO_curr_dout = FIFO_curr_c;
            valid_temp = 1'b1;
        end
        else
        begin
            FIFO_curr_dout = 8'd0;
            valid_temp = 1'b0;
        end

        FIFO_d : 
        if(!wen[3] && !error_d)
        begin 
            FIFO_curr_dout = FIFO_curr_d;
            valid_temp = 1'b1;
        end
        else
        begin 
            FIFO_curr_dout = 8'd0;
            valid_temp = 1'b0;
        end
        
        default : 
        begin
        FIFO_curr_dout = 8'd0;
        valid_temp = 1'b0;
        end

    endcase
    
    
    
    end

end

/*
always@(posedge clk or negedge rst_n) begin
    if(rst_in)

    */

assign valid = (clk) ? valid_temp : valid;
assign dout = (clk) ? FIFO_curr_dout : dout;

endmodule










module FIFO_8(clk, rst_n, wen, ren, din, dout, error);
input clk;
input rst_n;
input wen, ren;
input [7:0] din;
output [7:0] dout;
output reg error; 

//memory
reg [7:0] fifo [7:0];  
reg [2:0] ren_ptr;      
reg [2:0] wen_ptr;      
reg [3:0] counter;      
reg [7:0] dout;        

always @(posedge clk or negedge rst_n) begin
    //initialize at reset
    if(!rst_n) begin
        wen_ptr <= 3'b000;
        ren_ptr <= 3'b000;
        counter <= 4'b0000;
        dout <= 8'b00000000;
        error <= 1'b0; 
    end
    else begin
        error <= 1'b0;
        
        //===== WRITE OPERATION =====
        if(wen && !ren) begin 
            if(counter == 4'b1000) begin  
                error <= 1'b1; 
                dout <= 8'dx;
            end
            else begin
                fifo[wen_ptr] <= din;     
                wen_ptr <= wen_ptr + 3'b001; 
                counter <= counter + 4'b0001; 
            end
        end


        //===== READ OPERATION =====
        if(!wen && ren) begin
            if(counter == 4'b0000) begin  
                error <= 1'b1;      
                dout <= 8'dx;      
            end
            else begin
                dout <= fifo[ren_ptr];    
                ren_ptr <= ren_ptr + 3'b001; 
                counter <= counter - 4'b0001; 
            end
        end


        //===== READ & WRITE OPERATION =====
        if(wen && ren) begin
            if(counter == 4'b0000) begin  
                error <= 1'b1; 
                dout <= 8'dx;           
            end
            else begin
                fifo[wen_ptr] <= din;     
                dout <= fifo[ren_ptr];    
                wen_ptr <= wen_ptr + 3'b001; 
                ren_ptr <= ren_ptr + 3'b001; 
            end
        end

    end
end
endmodule