`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/24/2024 10:24:40 PM
// Design Name: 
// Module Name: top
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


module Top(
    input clk,
    input rst,
    input echo,
    input left_signal,
    input right_signal,
    input mid_signal,
    output trig,
    output left_motor,
    output reg [1:0]left,
    output right_motor,
    output reg [1:0]right,
    output left_led,
    output right_led,
    output mid_led
);

    wire Rst_n, rst_pb, stop;
    //wire [2:0] state;


    wire [1:0] state;

    parameter move_straight = 2'd0;
    parameter move_left = 2'd1;
    parameter move_right = 2'd2;



    //control motor driver --> use parameter in combinational loop
    parameter motor_off = 2'b00;
    parameter forward = 2'b10;
    parameter backward = 2'b01;

    debounce d0(rst_pb, rst, clk);
    onepulse d1(rst_pb, clk, Rst_n);

    motor A(
        .clk(clk),
        .rst(Rst_n),
        .mode(state),
        .pwm({left_motor, right_motor})
    );

    sonic_top B(
        .clk(clk), 
        .rst(Rst_n), 
        .Echo(echo), 
        .Trig(trig),
        .stop(stop)
    );
    
    tracker_sensor C(
        .clk(clk), 
        .reset(Rst_n), 
        .left_signal(left_signal), 
        .right_signal(right_signal),
        .mid_signal(mid_signal), 
        .state(state)
       );

    always @(*) begin
        // [TO-DO] Use left and right to set your pwm
        if(stop) 
            {left, right} = {motor_off, motor_off};
        else begin
        case(state)
            move_straight: begin
               {left, right} = {forward, forward};
               
            end
            move_left: begin
                {left, right} = {motor_off, forward};

            end

            move_right: begin
               // {left, right} = {forward, forward};
                {left, right} = {forward, motor_off};
                
            end
            
            default: begin
                {left, right} = {motor_off, motor_off};
            end
        endcase
        end
    end

    assign left_led = left_signal;
    assign right_led = right_signal;
    assign mid_led = mid_signal;

endmodule

module debounce (pb_debounced, pb, clk);
    output pb_debounced; 
    input pb;
    input clk;
    reg [4:0] DFF;
    
    always @(posedge clk) begin
        DFF[4:1] <= DFF[3:0];
        DFF[0] <= pb; 
    end
    assign pb_debounced = (&(DFF)); 
endmodule

module onepulse (PB_debounced, clk, PB_one_pulse);
    input PB_debounced;
    input clk;
    output reg PB_one_pulse;
    reg PB_debounced_delay;

    always @(posedge clk) begin
        PB_one_pulse <= PB_debounced & (! PB_debounced_delay);
        PB_debounced_delay <= PB_debounced;
    end 
endmodule







module tracker_sensor(clk, reset, left_signal, right_signal, mid_signal, state);
input clk;
input reset;
input left_signal, right_signal, mid_signal;
output reg [1:0] state;

// [TO-DO] Receive three signals and make your own policy.
// Hint: You can use output state to change your action.


parameter move_straight = 2'd0;
parameter move_left = 2'd1;
parameter move_right = 2'd2;

    reg [1:0] dir, next_dir; // track last dir for input to next state


//record last direction : act as feedback variable. necessary for extreame track.
//think about it : 

//prev_state?
//reg [2:0] prev_state;
//----->
parameter straight = 2'd0;
parameter left = 2'd1;
parameter right = 2'd2;

reg [2:0] next_state;


always @(posedge clk) begin
    if(reset == 1'b1) begin
        dir <= straight;
        state <= move_straight;
    end
    else begin
        dir <= next_dir;
        state <= next_state;
    end
end

//---------------------------------
//-------
always @(*) begin
    case({left_signal, mid_signal, right_signal})
    
    
        3'b111: begin
            next_state = move_straight;  // Stay straight by default
            next_dir = straight; // No need `direction` here
        end
        
        3'b011: begin
            next_state = move_right;
            next_dir = right;
        end
    
        3'b001: begin
            next_state = move_right;
            next_dir = right;
            //reset cou
        end
        
        3'b000: begin
        //start counter
        //if(counter > 1s) -- > abrupt turn
        
            //same process, but different speed -- > different mode

            next_dir = dir;

            if(dir == left)
                next_state = move_left;
            else if(dir == right)
                next_state = move_right;
            else 
            next_state = next_state;
                //next_state = stop;
            
        end
        3'b110: begin
            next_state = move_left;
            next_dir = left;
        end
        
        
        3'b100: begin
            next_state = move_left;
            next_dir = left;
        end

        default: begin
            next_state = move_straight; 
            next_dir = straight;
        end
    endcase
end


endmodule



//track 2 ----------------------/////
//evaluate all of the above based on a counter

//ie 





module motor(
    input clk,
    input rst,
    input [1:0]mode,
    output [1:0]pwm
);

    reg [9:0]next_left_motor, next_right_motor;
    reg [9:0]left_motor, right_motor;
    wire left_pwm, right_pwm;

    parameter stop_motor = 10'd0;
    parameter move_motor = 10'd850;

    parameter move_straight = 2'd0;
    parameter move_left = 2'd1;
    parameter move_right = 2'd2;

    motor_pwm m0(clk, rst, left_motor, left_pwm);
    motor_pwm m1(clk, rst, right_motor, right_pwm);
    
    always@(posedge clk)begin
        if(rst)begin
            left_motor <= 10'd0;
            right_motor <= 10'd0;
        end else begin
            left_motor <= next_left_motor;
            right_motor <= next_right_motor;
        end
    end
  
        // [TO-DO] take the right speed for different situation

      always @(*) begin
        case(mode)
            move_straight: begin
                next_left_motor = move_motor;
                next_right_motor = move_motor;
            end
            move_left: begin
                next_left_motor = stop_motor;
                next_right_motor = move_motor;
            end
            
            move_right: begin
                next_left_motor = move_motor;
                next_right_motor = stop_motor;
            end
       
            default: begin
                next_left_motor = stop_motor;
                next_right_motor = stop_motor;
            end
        endcase    
    end
    
    assign pwm = {left_pwm, right_pwm};

endmodule








module motor_pwm (
    input clk,
    input reset,
    input [9:0]duty,
	output pmod_1 //PWM
);
        
    PWM_gen pwm_0 ( 
        .clk(clk), 
        .reset(reset), 
        .freq(32'd25000),
        .duty(duty), 
        .PWM(pmod_1)
    );

endmodule

//generte PWM by input frequency & duty
module PWM_gen (
    input wire clk,
    input wire reset,
	input [31:0] freq,
    input [9:0] duty,
    output reg PWM
);
    wire [31:0] count_max = 32'd100_000_000 / freq;
    wire [31:0] count_duty = count_max * duty / 32'd1024;
    reg [31:0] count;
        
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            count <= 32'b0;
            PWM <= 1'b0;
        end else if (count < count_max) begin
            count <= count + 32'd1;
            if(count < count_duty)
                PWM <= 1'b1;
            else
                PWM <= 1'b0;
        end else begin
            count <= 32'b0;
            PWM <= 1'b0;
        end
    end
endmodule









module sonic_top(clk, rst, Echo, Trig, stop);
	input clk, rst, Echo;
	output Trig, stop;

	wire[20:0] dis;
	wire[20:0] d;
    wire clk1M;
	wire clk_2_17;

    div clk1(clk ,clk1M);
	TrigSignal u1(.clk(clk), .rst(rst), .trig(Trig));
	PosCounter u2(.clk(clk1M), .rst(rst), .echo(Echo), .distance_count(dis));

    // [TO-DO] calculate the right distance to trig stop(triggered when the distance is lower than 40 cm)
    // Hint: using "dis"
    assign stop = (dis <= 21'd4000) ? 1'b1 :1'b0;
 
endmodule

module PosCounter(clk, rst, echo, distance_count); 
    input clk, rst, echo;
    output[20:0] distance_count;

    parameter S0 = 2'b00;
    parameter S1 = 2'b01; 
    parameter S2 = 2'b10;
    
    wire start, finish;
    reg[1:0] curr_state, next_state;
    reg echo_reg1, echo_reg2;
    reg[20:0] count, next_count, distance_register, next_distance;
    wire[20:0] distance_count; 

    always@(posedge clk) begin
        if(rst) begin
            echo_reg1 <= 1'b0;
            echo_reg2 <= 1'b0;
            count <= 21'b0;
            distance_register <= 21'b0;
            curr_state <= S0;
        end
        else begin
            echo_reg1 <= echo;   
            echo_reg2 <= echo_reg1; 
            count <= next_count;
            distance_register <= next_distance;
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case(curr_state)
            S0: begin
                next_distance = distance_register;
                if (start) begin
                    next_state = S1;
                    next_count = count;
                end else begin
                    next_state = curr_state;
                    next_count = 21'b0;
                end 
            end
            S1: begin
                next_distance = distance_register;
                if (finish) begin
                    next_state = S2;
                    next_count = count;
                end else begin
                    next_state = curr_state;
                    next_count = count + 1'b1;
                end 
            end
            S2: begin
                next_distance = count;
                next_count = 21'b0;
                next_state = S0;
            end
            default: begin
                next_distance = 21'b0;
                next_count = 21'b0;
                next_state = S0;
            end
        endcase
    end

    assign distance_count = distance_register * 21'd100 / 21'd58; 
    assign start = echo_reg1 & ~echo_reg2;  
    assign finish = ~echo_reg1 & echo_reg2; 
endmodule

module TrigSignal(clk, rst, trig);
    input clk, rst;
    output trig;

    reg trig, next_trig;
    reg[23:0] count, next_count;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            count <= 24'b0;
            trig <= 1'b0;
        end
        else begin
            count <= next_count;
            trig <= next_trig;
        end
    end

    always @(*) begin
        next_trig = trig;
        next_count = count + 1'b1;
        if(count == 24'd999)
            next_trig = 1'b0;
        else if(count == 24'd9999999) begin
            next_trig = 1'b1;
            next_count = 24'd0;
        end
    end
endmodule

module div(clk ,out_clk);
    input clk;
    output out_clk;
    reg out_clk;
    reg [6:0]cnt;
    
    always @(posedge clk) begin   
        if(cnt < 7'd50) begin
            cnt <= cnt + 1'b1;
            out_clk <= 1'b1;
        end 
        else if(cnt < 7'd100) begin
	        cnt <= cnt + 1'b1;
	        out_clk <= 1'b0;
        end
        else if(cnt == 7'd100) begin
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
        else begin 
            cnt <= 7'b0;
            out_clk <= 1'b1;
        end
    end
endmodule