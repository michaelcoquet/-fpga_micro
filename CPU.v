module CPU 	
(
	input wire clk,
	input wire sync_reset,
	input wire [3:0] nibble_ir,
	input wire i_sel,
	input wire y_sel,
	input wire x_sel,
	input wire [3:0] source_sel,
	input wire [8:0] reg_en,
	input wire [3:0] dm,
	input wire [3:0] i_pins,
	output reg zero_flag,
	output reg [3:0] i, m, r, y1, y0, x1, x0,
	output reg [3:0] data_bus,
	output reg [3:0] o_reg,
	output reg [7:0] from_CU,
	output reg [3:0] alu_out,
	output reg alu_out_eq_0
);

reg [3:0] i_in;
reg [3:0] ALU_x, ALU_y;
reg [2:0] alu_func;
(* noprune *) reg [7:0] x_y_mul;


always @*
	from_CU = 8'h00;

/********************************************************
**********************Source Mux*************************
*********************************************************/
always @ *
begin
	case (source_sel)
		4'h0: data_bus = x0;
		4'h1: data_bus = x1;
		4'h2: data_bus = y0;
		4'h3: data_bus = y1;
		4'h4: data_bus = r;
		4'h5: data_bus = m;
		4'h6: data_bus = i;
		4'h7: data_bus = dm;
		4'h8: data_bus = nibble_ir;
		4'h9: data_bus = i_pins;
		4'hA: data_bus = 4'h0;
		4'hB: data_bus = 4'h0;
		4'hC: data_bus = 4'h0;
		4'hD: data_bus = 4'h0;
		4'hE: data_bus = 4'h0;
		4'hF: data_bus = 4'h0;
	endcase
end
/********************************************************
***************************i Mux*************************
*********************************************************/
always @ *
begin
	if(i_sel == 0)
		i_in = data_bus;					// i_in is input to the i register f/f
	else
		i_in = i + m;						// i_in is input to the i register f/f
end
/********************************************************
***************************x Mux*************************
*********************************************************/
always @ *
	if(x_sel == 0)
		ALU_x <= x0;
	else
		ALU_x <= x1;
/********************************************************
***************************y Mux*************************
*********************************************************/
always @ *
	if(y_sel == 0)
		ALU_y <= y0;
	else
		ALU_y <= y1;
/********************************************************
****************************ALU**************************
*********************************************************/

always @ *
	alu_func <= nibble_ir[2:0];


// temporary for ALU_x * ALU_y
always @*
	x_y_mul = ALU_x * ALU_y;
	
//	alu_out
always @*
if(sync_reset == 1'b0)
	case(alu_func)
		3'b000 : 
				if(nibble_ir[3] == 0) 
					// r = -x
					alu_out = -ALU_x;
				else
					// no op C8, D8
					alu_out = r;
		3'b001 :
				// r = x - y
				alu_out = ALU_x - ALU_y;
		3'b010 :
				// r = x + y
				alu_out = ALU_x + ALU_y;
		3'b011 :
				// r = most significant nibble of x*y
				alu_out = x_y_mul[7:4];
		3'b100 :
				// r = least significant nibble of x*y
				alu_out = x_y_mul[3:0];
		3'b101 :
				// r = x^y;
				alu_out = ALU_x ^ ALU_y;
		3'b110 :
				// r = x&y;
				alu_out = ALU_x & ALU_y;
		3'b111 :
				if(nibble_ir[3] == 0) 
					// r = ~x
					alu_out = ~ALU_x;
				else
					// no op CF, DF
					alu_out = r;
	endcase
else
	alu_out = 4'h0;

//			alu_out_eq_0	
always @*
if(sync_reset == 1'b0)
	if( (nibble_ir == 4'h8) || (nibble_ir == 4'hF) )
		alu_out_eq_0 = zero_flag;
	else if( alu_out == 4'h0 )
		alu_out_eq_0 = 1'b1;
	else
		alu_out_eq_0 = 1'b0;
else
	alu_out_eq_0 = 1'b1;
	
/********************************************************
************************Flip_FLops***********************
*********************************************************/

//_______x0___________
always @ (posedge clk)
begin
	if(reg_en[0] == 1)
		x0 = data_bus;
end

//_______x1___________
always @ (posedge clk)
begin
	if(reg_en[1] == 1)
		x1 = data_bus;
end

//_______y0___________
always @ (posedge clk)
begin
	if(reg_en[2] == 1)
		y0 = data_bus;
end

//_______y1___________
always @ (posedge clk)
begin
	if(reg_en[3] == 1)
		y1 = data_bus;
end

//________i___________
always @ (posedge clk)
begin
	if(reg_en[6] == 1)
		i = i_in;
end

//_______m____________
always @ (posedge clk)
begin
	if(reg_en[5] == 1)
		m = data_bus;
end

//_______o_reg________
always @ (posedge clk)
begin
	if(reg_en[8] == 1)
		o_reg = data_bus;
end

//_______r____________
always @ (posedge clk)
begin
	if(reg_en[4] == 1)
		r = alu_out;
end

//______zero_flag_____
always @ (posedge clk)
begin
	if(reg_en[4] == 1)
		zero_flag = alu_out_eq_0;
end

endmodule
