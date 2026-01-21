`timescale 1ns / 1ps
`timescale 1ns / 1ps



module timed_light_uart_system (
    input wire clk,                    // 100 MHz clock
    input wire capture_btn,            // Button to start recording
    input wire playback_btn,           // Button to start playback
    input wire reset_btn,              // Button to reset during recording
    input wire end_capture_btn,        // Button to end capture
    input wire stop_playback_btn,      // Button to stop playback immediately
    input wire [7:0] switches,         // 8-bit switches input
    input wire [1:0] storage_selector, // 2-bit selector for choosing storage bank
    output wire [15:0] leds,           // 16 LEDs output
    output wire tx                     // UART TX line
);

    // Clock divider for 5ms intervals
    wire clk_5ms;
    clk_divider #(.DIVIDE_BY(500_000)) clk_div_inst (
        .clk_in(clk),
        .reset(1'b0),
        .clk_out(clk_5ms)
    );

    // Debounced button signals
    wire capture_debounced, playback_debounced, reset_debounced, end_capture_debounced, stop_playback_debounced;

    // Debouncers
    debouncer capture_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(capture_btn), .button_out(capture_debounced));
    debouncer playback_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(playback_btn), .button_out(playback_debounced));
    debouncer reset_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(reset_btn), .button_out(reset_debounced));
    debouncer end_capture_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(end_capture_btn), .button_out(end_capture_debounced));
    debouncer stop_playback_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(stop_playback_btn), .button_out(stop_playback_debounced));

    // One-pulse generators
    wire capture_pulse, playback_pulse, reset_pulse, end_capture_pulse, stop_playback_pulse;
    one_pulse_generator capture_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(capture_debounced), .pulse_out(capture_pulse));
    one_pulse_generator playback_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(playback_debounced), .pulse_out(playback_pulse));
    one_pulse_generator reset_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(reset_debounced), .pulse_out(reset_pulse));
    one_pulse_generator end_capture_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(end_capture_debounced), .pulse_out(end_capture_pulse));
    one_pulse_generator stop_playback_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(stop_playback_debounced), .pulse_out(stop_playback_pulse));

    // Parameters for state definitions
    parameter IDLE = 2'b00;
    parameter RECORDING = 2'b01;
    parameter PLAYBACK = 2'b10;

    // State registers and counters
    reg [1:0] state = IDLE;           // State register
    reg [15:0] write_addr = 0;
    reg [15:0] read_addr = 0;
    reg bram_we;

    // Outputs from each BRAM
    wire [7:0] bram_out_0, bram_out_1;

    // Dual-port BRAM modules
    dual_port_bram bram_0 (
        .clk(clk_5ms),
        .we(bram_we && (storage_selector == 2'b00)), // Enable only if selector matches
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(switches),
        .dout(bram_out_0)
    );

    dual_port_bram bram_1 (
        .clk(clk_5ms),
        .we(bram_we && (storage_selector == 2'b01)), // Enable only if selector matches
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(switches),
        .dout(bram_out_1)
    );

    // UART Data Selector
    wire [7:0] uart_data;
    assign uart_data = (state == PLAYBACK) ? 
                       ((storage_selector == 2'b00) ? bram_out_0 :
                        (storage_selector == 2'b01) ? bram_out_1 : 8'b0) :
                       switches; // Use switch data during IDLE and RECORDING

    uart_top uart_inst (
        .clk_100MHz(clk),
        .reset(reset_btn),
        .write_data(uart_data),
        .tx(tx)
    );

    // State control logic
    always @(posedge clk_5ms) begin
        case (state)
            IDLE: begin
                if (capture_pulse) begin
                    state <= RECORDING;
                    write_addr <= 0;
                end else if (playback_pulse) begin
                    state <= PLAYBACK;
                    read_addr <= 0;
                end
            end

            RECORDING: begin
                if (reset_pulse) begin
                    state <= IDLE;
                    write_addr <= 0;
                    bram_we <= 0;
                end else if (end_capture_pulse) begin
                    state <= IDLE;
                    bram_we <= 0;
                end else if (write_addr < 48000) begin
                    bram_we <= 1;
                    write_addr <= write_addr + 1;
                end else begin
                    bram_we <= 0;
                end
            end

            PLAYBACK: begin
                if (stop_playback_pulse) begin
                    state <= IDLE; // Interrupt playback and return to IDLE
                end else if (read_addr < write_addr) begin
                    read_addr <= read_addr + 1;
                end else begin
                    state <= IDLE;
                end
            end
        endcase
    end

    // LED output logic
    assign leds = (state == PLAYBACK) ? {8'b0, uart_data} : 
                  {8'b0, switches}; // Reflect switch state during IDLE and RECORDING

endmodule







module timed_light_system (
    input wire clk,                   // 100 MHz clock
    input wire capture_btn,           // Button to start capture mode
    input wire playback_btn,          // Button to start playback mode
    input wire [7:0] switches,        // 8-bit switches input
    output wire [15:0] leds           // 16 LEDs output (combinational logic)
);

    // Clock divider for 5ms intervals (100 MHz / 500000 = 5ms)
    wire clk_5ms;
    clk_divider #(
        .DIVIDE_BY(500_000)
    ) clk_div_inst (
        .clk_in(clk),
        .reset(1'b0),
        .clk_out(clk_5ms)
    );

    // Debounced button outputs
    wire capture_debounced;
    wire playback_debounced;

    // Debouncers
    debouncer capture_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(capture_btn), .button_out(capture_debounced));
    debouncer playback_debouncer (.clk(clk_5ms), .reset(1'b0), .button_in(playback_btn), .button_out(playback_debounced));

    // One-pulse generators
    wire capture_pulse, playback_pulse;
    one_pulse_generator capture_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(capture_debounced), .pulse_out(capture_pulse));
    one_pulse_generator playback_pulse_gen (.clk(clk_5ms), .reset(1'b0), .button_in(playback_debounced), .pulse_out(playback_pulse));

    // State registers and address counters
    reg capture_mode = 1'b0;
    reg playback_mode = 1'b0;
    reg [15:0] write_addr = 0;
    reg [15:0] read_addr = 0;

    // BRAM Module Declaration
    reg [7:0] bram_data;
    wire [7:0] bram_out;
    reg bram_we;

    dual_port_bram my_bram (
        .clk(clk_5ms),
        .we(bram_we),
        .write_addr(write_addr),
        .read_addr(read_addr),
        .din(switches),
        .dout(bram_out)
    );

    // Control Logic
    always @(posedge clk_5ms) begin
        if (capture_pulse) begin
            capture_mode <= 1'b1;
            playback_mode <= 1'b0;
            write_addr <= 0;
        end else if (playback_pulse) begin
            capture_mode <= 1'b0;
            playback_mode <= 1'b1;
            read_addr <= 0;
        end

        if (capture_mode && write_addr < 48000) begin
            bram_we <= 1;
            write_addr <= write_addr + 1;
        end else begin
            bram_we <= 0;
        end

        if (playback_mode && read_addr < write_addr) begin
            read_addr <= read_addr + 1;
        end
    end

    // LED Output Logic
    assign leds = playback_mode ? {8'b0, bram_out} : {8'b0, switches};

endmodule

// Dual-Port BRAM Module
module dual_port_bram (
    input wire clk,
    input wire we,
    input wire [15:0] write_addr,
    input wire [15:0] read_addr,
    input wire [7:0] din,
    output reg [7:0] dout
);

    // BRAM storage
    reg [7:0] ram [0:47999];  // 48,000 x 8-bit memory

    always @(posedge clk) begin
        if (we)
            ram[write_addr] <= din;  // Write operation

        dout <= ram[read_addr];  // Read operation
    end

endmodule

// Clock Divider Module
module clk_divider #(parameter DIVIDE_BY = 500_000) (
    input wire clk_in,
    input wire reset,
    output reg clk_out
);
    reg [$clog2(DIVIDE_BY)-1:0] count = 0;

    always @(posedge clk_in) begin
        if (count == (DIVIDE_BY/2 - 1)) begin
            count <= 0;
            clk_out <= ~clk_out;
        end else begin
            count <= count + 1;
        end
    end
endmodule

// Debouncer Module
module debouncer (
    input wire clk,
    input wire reset,
    input wire button_in,
    output reg button_out
);
    reg [3:0] shift_reg;

    always @(posedge clk) begin
        shift_reg <= {shift_reg[2:0], button_in};
        if (shift_reg == 4'b1111)
            button_out <= 1;
        else
            button_out <= 0;
    end
endmodule

// One-Pulse Generator Module
module one_pulse_generator (
    input wire clk,
    input wire reset,
    input wire button_in,
    output reg pulse_out
);
    reg prev_state = 0;

    always @(posedge clk) begin
        if (button_in && !prev_state)
            pulse_out <= 1;
        else
            pulse_out <= 0;
        prev_state <= button_in;
    end
endmodule




//////////////////////////////////////////////////////////////////////////////////
// Unified UART Top Module with Automatic 5ms Trigger
//////////////////////////////////////////////////////////////////////////////////

module uart_top
    #(
        parameter   DBITS = 8,          // Number of data bits in a word
                    SB_TICK = 16,       // Number of stop bit / oversampling ticks
                    BR_LIMIT = 651,     // Baud rate generator counter limit (for 9600 baud)
                    BR_BITS = 10,       // Number of baud rate generator counter bits
                    FIFO_EXP = 2        // Exponent for number of FIFO addresses (2^2 = 4)
    )
    (
        input clk_100MHz,               // FPGA clock
        input reset,                    // Reset signal
        input [DBITS-1:0] write_data,   // Data to be transmitted
        output tx                       // UART serial output
    );

    // Internal Signals
    wire tick;                          // Tick signal from baud rate generator
    wire tx_done_tick;                  // Indicates transmission completion
    wire tx_empty;                      // Indicates FIFO is empty
    wire tx_fifo_not_empty;             // Indicates FIFO contains data to transmit
    wire [DBITS-1:0] tx_fifo_out;       // Data output from FIFO to UART transmitter
    wire timer_trigger;                 // Automatic trigger from the timer module

    // Instantiate Timer for 5ms Trigger
    timer_5ms TIMER (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .trigger(timer_trigger)
    );

    // Instantiate Baud Rate Generator
    baud_rate_generator
        #(
            .M(BR_LIMIT), 
            .N(BR_BITS)
         ) 
         BAUD_RATE_GEN   
         (
            .clk_100MHz(clk_100MHz), 
            .reset(reset),
            .tick(tick)
         );

    // Instantiate UART Transmitter
    uart_transmitter
        #(
            .DBITS(DBITS),
            .SB_TICK(SB_TICK)
         )
         UART_TX_UNIT
         (
            .clk_100MHz(clk_100MHz),
            .reset(reset),
            .tx_start(tx_fifo_not_empty),
            .sample_tick(tick),
            .data_in(tx_fifo_out),
            .tx_done(tx_done_tick),
            .tx(tx)
         );

    // Instantiate FIFO for Transmitting Data
    fifo
        #(
            .DATA_SIZE(DBITS),
            .ADDR_SPACE_EXP(FIFO_EXP)
         )
         FIFO_TX_UNIT
         (
            .clk(clk_100MHz),
            .reset(reset),
            .write_to_fifo(timer_trigger),  // Use timer trigger as write signal
            .read_from_fifo(tx_done_tick),
            .write_data_in(write_data),
            .read_data_out(tx_fifo_out),
            .empty(tx_empty),
            .full()
         );

    // Signal Logic
    assign tx_fifo_not_empty = ~tx_empty;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Timer Module for 5ms Trigger
//////////////////////////////////////////////////////////////////////////////////

module timer_5ms (
    input clk_100MHz,         // Clock signal
    input reset,              // Reset signal
    output reg trigger        // Trigger signal for UART
);
    reg [18:0] counter;       // 19-bit counter to count 500,000 cycles

    always @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            counter <= 0;
            trigger <= 0;
        end else if (counter == 500000 - 1) begin
            counter <= 0;
            trigger <= 1;     // Generate a trigger pulse
        end else begin
            counter <= counter + 1;
            trigger <= 0;     // Keep trigger low
        end
    end
endmodule

//////////////////////////////////////////////////////////////////////////////////
// UART Transmitter Module
//////////////////////////////////////////////////////////////////////////////////

module uart_transmitter
    #(
        parameter   DBITS = 8,          // number of data bits
                    SB_TICK = 16        // number of stop bit / oversampling ticks (1 stop bit)
    )
    (
        input clk_100MHz,               // basys 3 FPGA
        input reset,                    // reset
        input tx_start,                 // begin data transmission (FIFO NOT empty)
        input sample_tick,              // from baud rate generator
        input [DBITS-1:0] data_in,      // data word from FIFO
        output reg tx_done,             // end of transmission
        output tx                       // transmitter data line
    );
    
    // State Machine States
    localparam [1:0]    idle  = 2'b00,
                        start = 2'b01,
                        data  = 2'b10,
                        stop  = 2'b11;
    
    // Registers                    
    reg [1:0] state, next_state;            // state registers
    reg [3:0] tick_reg, tick_next;          // number of ticks received from baud rate generator
    reg [2:0] nbits_reg, nbits_next;        // number of bits transmitted in data state
    reg [DBITS-1:0] data_reg, data_next;    // assembled data word to transmit serially
    reg tx_reg, tx_next;                    // data filter for potential glitches
    
    // Register Logic
    always @(posedge clk_100MHz, posedge reset)
        if(reset) begin
            state <= idle;
            tick_reg <= 0;
            nbits_reg <= 0;
            data_reg <= 0;
            tx_reg <= 1'b1;
        end
        else begin
            state <= next_state;
            tick_reg <= tick_next;
            nbits_reg <= nbits_next;
            data_reg <= data_next;
            tx_reg <= tx_next;
        end
    
    // State Machine Logic
    always @* begin
        next_state = state;
        tx_done = 1'b0;
        tick_next = tick_reg;
        nbits_next = nbits_reg;
        data_next = data_reg;
        tx_next = tx_reg;
        
        case(state)
            idle: begin                     // no data in FIFO
                tx_next = 1'b1;             // transmit idle
                if(tx_start) begin          // when FIFO is NOT empty
                    next_state = start;
                    tick_next = 0;
                    data_next = data_in;
                end
            end
            
            start: begin
                tx_next = 1'b0;             // start bit
                if(sample_tick)
                    if(tick_reg == 15) begin
                        next_state = data;
                        tick_next = 0;
                        nbits_next = 0;
                    end
                    else
                        tick_next = tick_reg + 1;
            end
            
            data: begin
                tx_next = data_reg[0];
                if(sample_tick)
                    if(tick_reg == 15) begin
                        tick_next = 0;
                        data_next = data_reg >> 1;
                        if(nbits_reg == (DBITS-1))
                            next_state = stop;
                        else
                            nbits_next = nbits_reg + 1;
                    end
                    else
                        tick_next = tick_reg + 1;
            end
            
            stop: begin
                tx_next = 1'b1;         // back to idle
                if(sample_tick)
                    if(tick_reg == (SB_TICK-1)) begin
                        next_state = idle;
                        tx_done = 1'b1;
                    end
                    else
                        tick_next = tick_reg + 1;
            end
        endcase    
    end
    
    // Output Logic
    assign tx = tx_reg;
 
endmodule

//////////////////////////////////////////////////////////////////////////////////
// FIFO Module
//////////////////////////////////////////////////////////////////////////////////

module fifo
	#(
	   parameter	DATA_SIZE 	   = 8,	       // number of bits in a data word
				    ADDR_SPACE_EXP = 4	       // number of address bits (2^4 = 16 addresses)
	)
	(
	   input clk,                              // FPGA clock           
	   input reset,                            // reset button
	   input write_to_fifo,                    // signal start writing to FIFO
	   input read_from_fifo,                   // signal start reading from FIFO
	   input [DATA_SIZE-1:0] write_data_in,    // data word into FIFO
	   output [DATA_SIZE-1:0] read_data_out,   // data word out of FIFO
	   output empty,                           // FIFO is empty (no read)
	   output full	                           // FIFO is full (no write)
    );

	// Signal Declarations
	reg [DATA_SIZE-1:0] memory [2**ADDR_SPACE_EXP-1:0];		// memory array register
	reg [ADDR_SPACE_EXP-1:0] current_write_addr, current_write_addr_buff, next_write_addr;
	reg [ADDR_SPACE_EXP-1:0] current_read_addr, current_read_addr_buff, next_read_addr;
	reg fifo_full, fifo_empty, full_buff, empty_buff;
	wire write_enabled;
	
	// Register file (memory) write operation
	always @(posedge clk)
		if(write_enabled)
			memory[current_write_addr] <= write_data_in;
			
	// Register file (memory) read operation
	assign read_data_out = memory[current_read_addr];
	
	// Only allow write operation when FIFO is NOT full
	assign write_enabled = write_to_fifo & ~fifo_full;
	
	// FIFO control logic
	// Register logic
	always @(posedge clk or posedge reset)
		if(reset) begin
			current_write_addr 	<= 0;
			current_read_addr 	<= 0;
			fifo_full 			<= 1'b0;
			fifo_empty 			<= 1'b1;       // FIFO is empty after reset
		end
		else begin
			current_write_addr  <= current_write_addr_buff;
			current_read_addr   <= current_read_addr_buff;
			fifo_full  			<= full_buff;
			fifo_empty 			<= empty_buff;
		end

	// Next state logic for read and write address pointers
	always @* begin
		// Successive pointer values
		next_write_addr = current_write_addr + 1;
		next_read_addr  = current_read_addr + 1;
		
		// Default: keep old values
		current_write_addr_buff = current_write_addr;
		current_read_addr_buff  = current_read_addr;
		full_buff  = fifo_full;
		empty_buff = fifo_empty;
		
		// Button press logic
		case({write_to_fifo, read_from_fifo})     // check both buttons
			2'b01:	// Read button pressed
				if(~fifo_empty) begin   // FIFO not empty
					current_read_addr_buff = next_read_addr;
					full_buff = 1'b0;   // After read, FIFO not full anymore
					if(next_read_addr == current_write_addr)
						empty_buff = 1'b1;
				end
			
			2'b10:	// Write button pressed
				if(~fifo_full) begin	// FIFO not full
					current_write_addr_buff = next_write_addr;
					empty_buff = 1'b0;  // After write, FIFO not empty anymore
					if(next_write_addr == current_read_addr)
						full_buff = 1'b1;
				end
				
			2'b11:	begin	// Write and read simultaneously
				current_write_addr_buff = next_write_addr;
				current_read_addr_buff  = next_read_addr;
				end
		endcase			
	end

	// Output
	assign full = fifo_full;
	assign empty = fifo_empty;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Baud Rate Generator for UART
//////////////////////////////////////////////////////////////////////////////////

module baud_rate_generator
    #(
        parameter   N = 10,     // number of counter bits
                    M = 651     // counter limit value (9600 baud)
    )
    (
        input clk_100MHz,       // basys 3 clock
        input reset,            // reset
        output tick             // sample tick
    );
    
    // Counter Register
    reg [N-1:0] counter;        // counter value
    wire [N-1:0] next;          // next counter value
    
    // Register Logic
    always @(posedge clk_100MHz or posedge reset)
        if(reset)
            counter <= 0;
        else
            counter <= next;
            
    // Next Counter Value Logic
    assign next = (counter == (M-1)) ? 0 : counter + 1;
    
    // Output Logic
    assign tick = (counter == (M-1)) ? 1'b1 : 1'b0;
       
endmodule
