module Project(KEY, HEX1, HEX0, SW, CLOCK_50);
    input [0:0] KEY;
    input [3:0] SW;
    input CLOCK_50;
    output [6:0] HEX0, HEX1;

    wire [3:0] one;
	wire [3:0] ten;
	
	 // the time enable once per second
	reg [25:0] En = 0;
	wire Enable = (En == 0)&& (~(ten == 4'b0110) || SW[0]);
	always @(posedge CLOCK_50) begin
		En <= (Enable ? 50_000_000 : En) - 1;
	end
	
	
    counter Q0(.enable(SW[1]),.clock(Enable),.clear_b(SW[0]),.q(one[3:0]));
	
	assign en_q1 = (one == 4'b1001) ? 1 : 0; //if one == 9 then ten + 1;
	counter2 Q1(.enable(en_q1),.clock(Enable),.clear_b(SW[0]),.q(ten[3:0]));
	
    hex_decoder h0(one[3:0] , HEX0);
	hex_decoder h1(ten[3:0] , HEX1);

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
