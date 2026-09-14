module vending_machine_top(
	input logic clk, r, nickel, dime, quarter,candy,chips,soda,
	output logic [1:0] states,
	output logic [0:6] tens, ones,
	output logic clk_led, notEnough, selCandy,selChips,selSoda
);
	logic one_sec, nickel_counter, dime_counter, quarter_counter;
	logic [5:0] change,total;
	clockdivider clk_inst(
	.clk(clk),
	.start_timer(1'b0),
	.slow_clock_signal(one_sec),
	.slow_led(clk_led)
	);
	
	fsm fsm_inst(
	.clk(one_sec), 
	.reset(r), 
	.nickel(nickel), 
	.dime(dime), 
	.quarter(quarter),
	.candy(candy),
	.chips(chips),
	.soda(soda),
	.states(states),
	.total(change),
	.notEnough(notEnough),
	.selCandy(selCandy), 
	.selChips(selChips), 
	.selSoda(selSoda)
	);
	
	
	
	two_bcd bcd_inst(
	.a(change),
	.tens(tens),
	.ones(ones)
	);
endmodule

module fsm( 
	input logic clk, reset, nickel, dime, quarter, candy, chips, soda, //candy = 20, chips = 25, soda = 30
	output logic [1:0] states,
	output logic [5:0] total,
	output logic notEnough, selCandy, selChips, selSoda
	);
	logic [5:0] temp_change, change;
	typedef enum logic [1:0] {Idle,Candy, Chips, Soda} statetype;
	statetype state, nextstate;
	always_ff @(posedge clk, posedge reset) begin
		if (reset) begin
			temp_change <= 6'd0;
			state <= Idle;
		end
		
		else begin
			temp_change <= change;
			state <= nextstate;
		end
	end
	
	always_comb
		begin
		change = temp_change;
		selCandy = 1'b0;
		selChips = 1'b0;
		selSoda = 1'b0;
		notEnough = 1'b0;
		nextstate = state;
			case (state)
						
				Idle: begin
							if (candy || chips || soda) begin
								notEnough = 1'b1;
							end
							
							//Inserting Coins/Buying Products
							else if (nickel) begin
								change = change + 6'b000101;
							end
							
							else if (dime) begin
								change = change + 6'b001010;
							end
							
							else if (quarter) begin 
								change = change + 6'b011001;
							end
						end
							
				Candy: begin 
						
							if (chips || soda) begin
								notEnough = 1'b1;
							end
							
							//Inserting Coins/Buying Products
							else if (nickel) begin
								change = change + 6'b000101;
							end
							
							else if (dime) begin
								change = change + 6'b001010;
							end
							
							else if (quarter) begin 
								change = change + 6'b011001;
							end
							
							else if (candy) begin
								selCandy = 1'b1;
								change = change - 6'b010100; 
							end
						end
				
				Chips: 
						 begin 
							 if (soda) begin
								notEnough = 1'b1;
							 end
							 //Inserting Coins/Buying Products
							else if (nickel) begin
								change = change + 6'b000101;
							end
							
							else if (dime) begin
								change = change + 6'b001010;
							end
							
							else if (quarter) begin 
								change = change + 6'b011001;
							end
							
							else if (candy) begin
								selCandy = 1'b1;
								change = change - 6'b010100; 
								
							end
							
							else if (chips) begin
								selChips = 1'b1;
								change = change - 6'b011001;
							end
						end
						
				
				Soda:	//Inserting Coins/Buying Product
						begin 
							if (nickel) begin
								change = change + 6'b000101;
							end
							
							else if (dime) begin
								change = change + 6'b001010;
							end
							
							else if (quarter) begin 
								change = change + 6'b011001;
							end
							
							else if (candy) begin
								selCandy = 1'b1;
								change = change - 6'b010100; 
							end
							
							else if (chips) begin
								selChips = 1'b1;
								change = change - 6'b011001;
							end
							
							else if (soda) begin
								selSoda = 1'b1;
								change = change - 6'b011110;
							end
						end
						
						//End of Inserting/Buying
					
					default : nextstate = Idle;
				endcase
						if (change >= 6'd60) begin
							change = 6'd60;
						end
						if (change >= 6'd20 & change < 6'd25) 
							nextstate = Candy;
						else if (change >= 6'd25 & change < 6'd30) 
							nextstate = Chips;
						else if (change >= 6'd30) 
							nextstate = Soda;
						else
							nextstate = Idle;
						
						total = temp_change;
						states = state;
			end
		
		
endmodule

module clockdivider(
	input    clk,start_timer,
	output wire slow_clock_signal,
	output reg slow_led
	);
	
	reg [25:0] cnt;
	wire slow_sig;
	assign slow_clock_signal = cnt[24];
	assign slow_sig = cnt[24];
	always @(posedge clk)
		if (start_timer == 1) begin
			cnt = 26'h0;
		end 
		else begin
			cnt = cnt + 1;
		end
	always @ (slow_sig)
		if (slow_sig == 1)
			slow_led = 1;
		else
			slow_led = 0;
endmodule

module two_bcd(
	input logic [5:0] a,
	output logic [0:6] tens, ones 
	);
	always_comb begin
		case (a)
			0: begin tens = 7'b000_0001; ones = 7'b000_0001; end
			5: begin tens = 7'b000_0001; ones = 7'b010_0100; end
			10: begin tens = 7'b100_1111; ones = 7'b000_0001; end
			15: begin tens = 7'b100_1111; ones = 7'b010_0100; end
			20: begin tens = 7'b001_0010; ones = 7'b000_0001; end
			25: begin tens = 7'b001_0010; ones = 7'b010_0100; end
			30: begin tens = 7'b000_0110; ones = 7'b000_0001; end
			35: begin tens = 7'b000_0110; ones = 7'b010_0100; end
			40: begin tens = 7'b100_1100; ones = 7'b000_0001; end
			45: begin tens = 7'b100_1100; ones = 7'b010_0100; end
			50: begin tens = 7'b010_0100; ones = 7'b000_0001; end
			55: begin tens = 7'b010_0100; ones = 7'b010_0100; end
			60: begin tens = 7'b010_0000; ones = 7'b000_0001; end
			default: begin tens = 7'b000_0001; ones = 7'b000_0001; end
		endcase
	end
endmodule
