module Project(KEY, HEX5, HEX4, HEX2, HEX1, HEX0, SW, LEDR, LEDG, GPIO, CLOCK_50);
	input [3:0] KEY;
	input [17:0] SW;
	input CLOCK_50;
	input [2:0] GPIO;
	
	output [4:0] LEDG;
	output [17:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX4, HEX5;

	wire [3:0] one;
	wire [3:0] ten;

	wire [1:0] winner;

	 // the time enable once per second
	reg [25:0] En = 0;
	wire Enable = (En == 0)&& (~(ten == 4'b0110) || SW[0]) && ~(winner || gameover); // assuming ~winner works...........
	always @(posedge CLOCK_50) begin
		En <= (Enable ? 50_000_000 : En) - 1;
	end
	
	wire [1:0] a, b, c;
	wire [1:0] num_inputs;

	wire [2:0] randVal1;
	wire [2:0] randVal2;
	wire [2:0] randVal3;

	
	wire [1:0] inOne;
	wire [1:0] inTwo;	
	wire [1:0] inThree;
	

	lfsr rand1(
	.out(randVal1),  // Output of the counter
	.enable(~SW[0]),  // Enable  for counter
	.clk(CLOCK_50),  // clock input	

	.reset(~KEY[2]),// reset input
	.var1(randVal1[0]),
	.var2(randVal1[1])
	);
	lfsr rand2(
	.out(randVal2),  // Output of the counter
	.enable(~SW[0]),  // Enable  for counter
	.clk(CLOCK_50),  // clock input
	.reset(~KEY[2]),// reset input
	.var1(randVal1[0]),	
	.var2(randVal2[2])
	);
	lfsr rand3(
	.out(randVal3),  // Output of the counter
	.enable(~SW[0]),  // Enable  for counter
	.clk(CLOCK_50),  // clock input7:0] LEDR;
	.reset(~KEY[2]),// reset input
	.var1(randVal3[1]),
	.var2(randVal3[2])
	);	
	
	hex_decoder h0(randVal1%3, HEX0);
	hex_decoder h1(randVal2%3, HEX1);
	hex_decoder h2(randVal3%3, HEX2);
	/*
	hex_decoder h0(inOne, HEX0);
	hex_decoder h1(inTwo, HEX1);
	hex_decoder h2(inThree, HEX2);*/

   counter Q0(.enable(~(winner || gameover)),.clock(Enable),.clear_b(~SW[0]),.q(one[3:0]));
	
	assign en_q1 = (one == 4'b1001) ? 1 : 0; //if one == 9 then ten + 1;
	counter2 Q1(.enable(en_q1),.clock(Enable),.clear_b(~SW[0]),.q(ten[3:0]));
		
  	hex_decoder h4(one[3:0] , HEX4);
	hex_decoder h5(ten[3:0] , HEX5);
	
	assign inOne = SW[13:12];
	assign inTwo = SW[15:14];
	assign inThree = SW[17:16];
	
	assign LEDR[13:12] = (inOne == randVal1%3);
	assign LEDR[15:14] = (inTwo == randVal2%3);
	assign LEDR[17:16] = (inThree == randVal3%3);

	assign winner = ((inOne == randVal1%3) && (inTwo == randVal2%3) && (inThree == randVal3%3));
	assign gameover = (ten == 4'b0101 && one == 4'b1001);
	
	assign LEDG[4:0] = winner;
	
	/*buttonPress dsda(
		.GPIO(GPIO[2:0]), .a(a[1:0]), .b(b[1:0]), .c(c[1:0]), .num_inputs(num_inputs), .clock(CLOCK_50)); 
		*/

endmodule

// Comparator and checker
module comparator(
	inputVal, // user input
	expectedVal, // correct val
	outputCorrect	
);
	
	output reg outputCorrect; 
	input [3:0] inputVal; 
	input expectedVal; 
	
	always @(*)
	begin
	if(inputVal == expectedVal)
		outputCorrect = 1'b1;
	else	
		outputCorrect = 1'b0;
	end
endmodule

// random number generator
// using a linear-feedback shift register   
module lfsr(
	out             ,  // Output of the counter
	enable          ,  // Enable  for counter
	clk             ,  // clock input	

	reset,              // reset input
	var1, // var
	var2
);
	//----------Output Ports--------------
	output reg [2:0] out;
	//------------Input Ports-------------Good hierarchy
	input enable, clk, reset, var1, var2;
	//------------Internal Variables--------Good hierarchy0
	wire linear_feedback;

	//-------------Code Starts Here-------
	assign linear_feedback = !(var1 ^ var2);

	always @(posedge clk)
	//if (reset) begin // active high reset
	//  out <= 2'b0 ;
	//end
	if ((enable) || (reset)) begin
	  out <= {out[1],
				 out[0], linear_feedback};
	end
endmodule

/*
module buttonPress(GPIO, ld_a, ld_b, ld_c, num_inputs, clock);
	input clock;
	input [2:0] GPIO;
	output reg a, b, c, num_inputs;
	
	 localparam  S_LOAD_A        = 5'd0,
                S_LOAD_A_WAIT   = 5'd1,
                S_LOAD_B        = 5'd2,
                S_LOAD_B_WAIT   = 5'd3,
                S_LOAD_C        = 5'd4,
                S_LOAD_C_WAIT   = 5'd5,
                S_CYCLE_0       = 5'd6,
                S_CYCLE_1       = 5'd7,
                S_CYCLE_2       = 5'd8,
                S_CYCLE_3       = 5'd9,
					 
	always@(*)
    begin: state_table 
            case (current_state)
				S_LOAD_A: next_state = go ? S_LOAD_A_WAIT : S_LOAD_A; // Loop in current state until value is input
				 S_LOAD_A_WAIT: next_state = go ? S_LOAD_A_WAIT : S_LOAD_B; // Loop in current state until go signal goes low
				 S_LOAD_B: next_state = go ? S_LOAD_B_WAIT : S_LOAD_B; // Loop in current state until value is input
				 S_LOAD_B_WAIT: next_state = go ? S_LOAD_B_WAIT : S_LOAD_C; // Loop in current state until go signal goes low
				 S_LOAD_C: next_state = go ? S_LOAD_C_WAIT : S_LOAD_C; // Loop in current state until value is input
				 S_LOAD_C_WAIT: next_state = go ? S_LOAD_X_WAIT : S_CYCLE_0; // Loop in current state until go signal goes lo
				 S_CYCLE_0: next_state = S_CYCLE_1;
				 S_CYCLE_1: next_state = S_CYCLE_2; 
				 S_CYCLE_2: next_state = S_CYCLE_3;
				 S_CYCLE_3: next_state = S_LOAD_A;
				default:     next_state = S_LOAD_A;
        endcase
    end // state_table
	always @(*)
    begin: enable_signals
        // By default make all our signals 0
        ld_alu_out = 1'b0;
        ld_a = 1'b0;
        ld_b = 1'b0;
        ld_c = 1'b0;
        ld_x = 1'b0;
        ld_r = 1'b0;
        alu_select_a = 2'b0;
        alu_select_b = 2'b0;
        alu_op       = 1'b0;

        case (current_state)
            S_LOAD_A: begin
                ld_a = 1'b1;
                end
            S_LOAD_B: begin
                ld_b = 1'b1;
                end
            S_LOAD_C: begin
                ld_c = 1'b1;
                end
            S_CYCLE_0: begin // Do A * x
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result back into A
                alu_select_a = 2'b00; // Select register A
                alu_select_b = 2'b11; // Also select register x
                alu_op = 1'b1; // multiply
            end
            S_CYCLE_1: begin // Do Ax * x
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result in result register
					 //ld_x = 1'b1;
                alu_select_a = 2'b00; // Select register Ax
                alu_select_b = 2'b11; // Select register x
                alu_op = 1'b1; // multiply
            end
            S_CYCLE_2: begin // Do B * x
                ld_alu_out = 1'b1; ld_b = 1'b1; // store result in result registe
					 //ld_x = 1'b1;
                alu_select_a = 2'b01; // Select register B
                alu_select_b = 2'b11;// Select register x
                alu_op = 1'b1; // multiply
            end
            S_CYCLE_3: begin // Do (Ax^2) + Bx
                ld_alu_out = 1'b1; ld_a = 1'b1; // store result in result register
                alu_select_a = 2'b00; // Select register Ax^2
                alu_select_b = 2'b01; // Select register Bx
                alu_op = 1'b0; // add
            end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals
   
    // current_state registers
    always@(posedge clock)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_A;
        else
            current_state <= next_state;
    end // state_FFS
	 
   always @(posedge clock) // triggered every time clock rises
	begin
		if (num_inputs == 2'b00)
			num_inputs <= 2'b01;
			if (GPIO[0])
				a <= 1'b11;
			else if (GPIO[0])
				a <= 1'b01;
			else if (GPIO[0])
				a <= 1'b10;
		else if (num_inputs == 2'b01)
			num_inputs <= 2'b10;
			if (GPIO[1])
				b <= 1'b11;
			else if (GPIO[1])
				b <= 1'b01;
			else if (GPIO[1])
				b <= 1'b10;
		else if (num_inputs == 2'b10)
			num_inputs <= 2'b00;
			if (GPIO[2])
				c <= 1'b11;
			else if (GPIO[2])
				c <= 1'b01;
			else if (GPIO[2])
				c <= 1'b10;
			
	end
endmodule
*/


module counter(enable, clock, clear_b, q); //0-9 counter
	input enable, clock, clear_b;

    output reg [3:0]q;
    always @(posedge clock) // triggered every time clock rises
	begin
		if (clear_b == 1'b1) // when Clear b is 0
			q <= 0; // q is set to 0Good hierarchy
		else if (q == 4'b1001) // when q is the maximum value for the counter
			q <= 0; // q reset to 0
		else if (enable == 1'b1) // increment q only when Enable is 1
			q <= q + 1'b1; // increment q
			
	end
endmodule

module counter2(enable, clock, clear_b, q); //0-9 counter
	input enable, clock, clear_b;
    output reg [3:0]q;
    always @(posedge clock) // triggered every time clock rises
	begin
		if (clear_b == 1'b1) // when Clear b is 0
			q <= 0; // q is set to 0
		else if (q == 4'b0110) // when q is the maximum value for the counter
			q <= 0; // q reset to 0
		else if (enable == 1'b1) // increment q only when Enable is 1
			q <= q + 1'b1; // increment q
			
	end
endmodule

module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
