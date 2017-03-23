module Project(KEY, HEX5, HEX4, HEX1, HEX0, SW, LEDR, CLOCK_50);
	input [3:0] KEY;
	input [3:0] SW;
	input CLOCK_50;
	output [7:0] LEDR;
	output [6:0] HEX0, HEX1, HEX4, HEX5;

	wire [3:0] one;
	wire [3:0] ten;
	
	 // the time enable once per second
	reg [25:0] En = 0;
	wire Enable = (En == 0)&& (~(ten == 4'b0110) || SW[0]);
	always @(posedge CLOCK_50) begin
		En <= (Enable ? 50_000_000 : En) - 1;
	end
	
	wire [7:0] randVal1, randVal2;

	lfsr rand1(
	.out(randVal1),  // Output of the counter
	.enable(1'b1),  // Enable  for counter
	.clk(CLOCK_50),  // clock input
	.reset(KEY[2])// reset input
	);
	lfsr rand2(
	.out(randVal2),  // Output of the counter
	.enable(1'b1),  // Enable  for counter
	.clk(CLOCK_50),  // clock input
	.reset(KEY[2])// reset input
	);
	
   counter Q0(.enable(KEY[3]),.clock(Enable),.clear_b(~SW[0]),.q(one[3:0]));
	
	assign en_q1 = (one == 4'b1001) ? 1 : 0; //if one == 9 then ten + 1;
	counter2 Q1(.enable(en_q1),.clock(Enable),.clear_b(~SW[0]),.q(ten[3:0]));
	
   hex_decoder h0(one[3:0] , HEX0);
	hex_decoder h1(ten[3:0] , HEX1);
	hex_decoder h2(randVal1, HEX4);
	hex_decoder h3(randVal2, HEX5);
endmodule

// random number generator   
module lfsr(
	out             ,  // Output of the counter
	enable          ,  // Enable  for counter
	clk             ,  // clock input
	reset              // reset input
);
	//----------Output Ports--------------
	output reg [7:0] out;
	//------------Input Ports-------------
	input enable, clk, reset;
	//------------Internal Variables--------
	wire linear_feedback;

	//-------------Code Starts Here-------
	assign linear_feedback = !(out[7] ^ out[3]);

	always @(posedge clk)
	if (reset) begin // active high reset
	  out <= 8'b0 ;
	end else if (enable) begin
	  out <= {out[6],out[5],
				 out[4],out[3],
				 out[2],out[1],
				 out[0], linear_feedback};
	end 
endmodule


module counter(enable, clock, clear_b, q); //0-9 counter
	input enable, clock, clear_b;
    output reg [3:0]q;
    always @(posedge clock) // triggered every time clock rises
	begin
		if (clear_b == 1'b1) // when Clear b is 0
			q <= 0; // q is set to 0
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
