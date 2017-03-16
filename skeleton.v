//Sw[7:0] data_in

//KEY[0] synchronous reset when pressed
//KEY[1] go signal

//LEDR displays result
//HEX0 & HEX1 also displays result

//Sw[7:0] data_in

//KEY[0] synchronous reset when pressed
//KEY[1] go signal

//LEDR displays result
//HEX0 & HEX1 also displays result


 module lfsr    (
out             ,  // Output of the counter
enable          ,  // Enable  for counter
clk             ,  // clock input
reset              // reset input
);

//----------Output Ports--------------
output [7:0] out;
//------------Input Ports-------------
input enable, clk, reset;
//------------Internal Variables--------
reg [7:0] out;
wire        linear_feedback;

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

endmodule // End Of Module counter

 
module Project(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1;

   reg a = 2'b00;
	reg b = 2'b01;
	reg c = 2'b10;
	

	
	reg [4:0] d= 4'b0010;
	always @(posedge CLOCK_50) begin
		 d <= { d[3:0], d[4] ^ d[3] };
	end
	
	wire [9:0] ok;

	lfsr rand(
	.out(ok),  // Output of the counter
	.enable(KEY[3]),  // Enable  for counter
	.clk(CLOCK_50),  // clock input
	.reset(KEY[2])// reset input
	);
	
	hex_decoder H0(
        .hex_digit(ok), 
        .segments(HEX0)
        );



endmodule
/*


module fpga_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1);
    input [9:0] SW;
    input [3:0] KEY;
    input CLOCK_50;
    output [9:0] LEDR;
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;   
    wire resetn;
    wire go;
    module fpga_top(SW, KEY, CLOCK_50, LEDR, HEX0, HEX1);
    wire [1:0] data_a;
    wire [1:0] data_b;
    wire [1:0] data_c;
    wire [1:0] data_d;
    assign go = ~KEY[1];
    assign resetn = KEY[0];
    
    game simulate(
    	.clk(CLOCK_50),
    	.resetn(resetn),
    	.go(go),
    	.input_a(SW[1:0]),
    	.input_b(SW[3:2]),
    	.input_c(SW[5:4]),
    	.input_d(SW[7:6]),
    	.data_a(data_a),
    	.data_b(data_b),
    	.data_c(data_c),
    	.data_d(data_d)
    	);
    	
    hex_decoder H0(
        .hex_digit(data_a[1:0]), 
        .segments(HEX0)
        );
        
    hex_decoder H1(
        .hex_digit(data_b[1:0]), 
        .segments(HEX1)
        );
        
    hex_decoder H2(
        .hex_digit(data_c[1:0]), 
        .segments(HEX2)
        );
        
    hex_decoder H3(
        .hex_digit(data_d[1:0]), 
        .segments(HEX3)
        );

endmodule

module game(

	input clk,
	input resetn,
	input go,
	input [1:0] input_a,
	input [1:0] input_b,
	input [1:0] input_c,
	input [1:0] input_d,
	output [1:0] data_a,
	output [1:0] data_b,
	output [1:0] data_c,
	output [1:0] data_d
	);
	
	wire ld_a, ld_b, ld_c, ld_d;
	        			alu_op = 1'b0;
	wire [1:0] alu_select_a;


    control C0(
 
    );

    datapath D0(

    );
                
 endmodule        
                

module control(
	input clk,
    input resetn,
    input go,
    output reg  ld_a, ld_b, ld_c, ld_d,
    
    
    output reg [1:0] alu_select_a
    
	);
	
	reg [5:0] current_state, next_state;
	
	localparam  S_LOAD_VAL  = 5'd0,
				S_LOAD_WAIT = 5'd1,
				S_CYCLE_0   = 5'd2
				;
				
	always@(*)
	begin: state_table
			case(current_state)
				S_LOAD_VAL: next_state = go ? S_LOAD_WAIT : S_LOAD_VAL;
				S_LOAD_WAIT: next_state = go ? S_LOAD_WAIT : S_CYCLE_0;
				S_CYCLE_0 : next_state = S_LOAD_VAL;
			default:
				next_state = S_LOAD_VAL;
			endcase
	end
	
	always @(*)
    begin: enable_signals
        ld_a = 1'b0;
        ld_b = 1'b0;
        ld_c = 1'b0;
        ld_d = 1'b0;
        alu_select_a = 2'b0;
        
        case (current_state)
        	S_LOAD_VAL: 
        		begin
        			ld_a = 1'b1;
        			ld_b = 1'b1;
        			ld_c = 1'b1;
        			ld_d = 1'b1;
        		end
        	S_CYCLE_0: // Compare A to generated A
        		begin
        			alu_select_a = 2'b00; // Select register A 
        			alu_op = 1'b0;
        		end
        	
        
        endcase
    end
    
    
    always@(posedge clk)
    begin: state_FFs
    	if(!resetn)
    		current_state <= S_LOAD_VAL;
    	else
    		current_state <= next_state;
    end       	
				
endmodule
/*
module datapath(
	input clk,
	input resetn,            	data_b <= 2'b0; 
	input [1:0] input_a,
	input [1:0] input_b,
	input [1:0] input_c,
	input [1:0] input_d,
	input  ld_a, ld_b, ld_c, ld_d,
	input [1:0] alu_select_a,
	
	output reg [1:0] data_a, data_b, data_c, data_d
	);
	
	reg [1:0] a, b, c, d;

	reg [1:0] alu_a;
	
	always@(posedge clk) begin
        if(!resetn) 
        begin
            a <= 2'b0; 
            b <= 2'b0; 
            c <= 2'b0; 
            d <= 2'b0; 
        end
        else 
        begin
            if(ld_a)
                a <= data_in;
            if(ld_b)
                b <= data_in;
            if(ld_x)            	data_b <= 2'b0; 
                x <= data_in;

            if(ld_c)
                c <= data_in;
        end
    end
    
    always@(posedge clk) begin
        if(!resetn) begin
            data_a <= 2'b0;
            data_b <= 2'b0; 
            data_c <= 2'b0; 
            data_d <= 2'b0;
        end
        else 
            data_a <= a;
            data_b <= b; 
            data_c <= c; 
            data_d <= d;
            
    end

    always @(*)
    begin
        case (alu_select_a)
            2'd0:
                alu_a = a;
            2'd1:
                alu_a = b;
            2'd2:
                alu_a = c;
            2'd3:
                alu_a = d;
            default: alu_a = 8'b0;
        endcase
    
    end
    
    // The ALU 
    always @(*)
    begin : ALU
        // alu
        case (alu_op)
            0: begin
                //perform comparison between alu_a and "red"
                	if (alu_a == 2'b0)
                		data_a = alu_a;
                	else
                		data_a = 2'b0;
               end
            1: begin
                // perform comparison between alu_a and "blue"
					if (alu_a == 2'b01)
                		data_b = alu_a;
                	else
                		data_b = 2'b0;
                end
            2: begin
            	// compare alu_a and "yellow"
            		if (alu_a == 2'b10)
                		data_c = alu_a;
                	else
                		data_c = 2'b0;
            	end
            3: begin
            	// compare alu_a and "green"
            		if (alu_a == 2'b11)
                		data_d = alu_a;
                	else
                		data_d = 2'b0;hex_decoder
            	end
            
            default: 
            	data_a <= 2'b0;
            	data_b <= 2'b0; 
            	data_c <= 2'b0; 
            	data_d <= 2'b0;
        endcase
    end
    
endmodule
    input [3:0] KEY;
    input CLOCK_50;






*/











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
