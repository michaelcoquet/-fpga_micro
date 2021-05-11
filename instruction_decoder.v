module instruction_decoder
( 	
	input wire clk,
	input wire sync_reset,
	input wire [7:0] next_instr,
	output reg jump,
	output reg conditional_jump,
	output reg [3:0] jump_address,
	output reg i_sel,
	output reg y_sel,
	output reg x_sel,
	output reg NOPC8,
	output reg NOPCF,
	output reg NOPD8,
	output reg NOPDF,
	output reg [3:0] source_sel,
	output reg [8:0] reg_en,
	output reg [7:0] ir,
	output reg [7:0] from_ID
);

always @*
	from_ID = 8'h00;

always @*
	if(ir == 8'hC8)
		NOPC8 = 1'b1;
	else
		NOPC8 = 1'b0;
		
always @*
	if(ir == 8'hCF)
		NOPCF = 1'b1;
	else
		NOPCF = 1'b0;
	
always @*
	if(ir == 8'hD8)
		NOPD8 = 1'b1;
	else
		NOPD8 = 1'b0;
		
always @*
	if(ir == 8'hDF)
		NOPDF = 1'b1;
	else
		NOPDF = 1'b0;		
	
always @ (posedge clk)
	ir = next_instr;

always @ *
	jump_address = ir[3:0];

/**********************************************************
 ***************Logic for register enables*****************
 **********************************************************/
// o_reg_________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd4))
			reg_en[8] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd4))
			reg_en[8] = 1'b1;
		else
			reg_en[8] = 1'b0;
	else
		reg_en[8] = 1'b1;
end
//_______________________
// dm____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if( (ir[7] == 1'b0)&&(ir[6:4] == 3'd7) )
			reg_en[7] = 1'b1;
		else if( (ir[7:6] == 2'b10)&&(ir[5:3] == 3'd7) )
			reg_en[7] = 1'b1;
		else 
			reg_en[7] = 1'b0;
	else
		reg_en[7] = 1'b1;
end
//_______________________
// i_____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&((ir[6:4] == 3'd6)||(ir[6:4] == 3'd7)))
			reg_en[6] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd6))
			reg_en[6] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd7))
			reg_en[6] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[2:0] == 3'd7))
			reg_en[6] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd6)&&(ir[2:0] == 3'd7))
			reg_en[6] = 1'b1;
		else
			reg_en[6] = 1'b0;
	else
		reg_en[6] = 1'b1;
end
//_______________________
// m_____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd5))
			reg_en[5] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd5))
			reg_en[5] = 1'b1;
		else
			reg_en[5] = 1'b0;
	else
		reg_en[5] = 1'b1;
end
//_______________________
// r_____________________
always @ * begin
	if(sync_reset == 1'b0) 
		if(ir[7:5] == 3'b110)
			reg_en[4] = 1'b1;
		else
			reg_en[4] = 1'b0;
	else
		reg_en[4] = 1'b1;
end
//_______________________
// y1____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd3))
			reg_en[3] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd3))
			reg_en[3] = 1'b1;
		else
			reg_en[3] = 1'b0;
	else
		reg_en[3] = 1'b1;
end
//_______________________
// y0____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd2))
			reg_en[2] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd2))
			reg_en[2] = 1'b1;
		else
			reg_en[2] = 1'b0;
	else
		reg_en[2] = 1'b1;
end
//_______________________
// x1____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd1))
			reg_en[1] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd1))
			reg_en[1] = 1'b1;
		else
			reg_en[1] = 1'b0;
	else
		reg_en[1] = 1'b1;
end
//_______________________
// x0____________________
always @ * 
begin
	if(sync_reset == 1'b0) 
		if((ir[7] == 1'b0)&&(ir[6:4] == 3'd0))
			reg_en[0] = 1'b1;
		else if ((ir[7:6] == 2'b10)&&(ir[5:3] == 3'd0))
			reg_en[0] = 1'b1;
		else
			reg_en[0] = 1'b0;
	else
		reg_en[0] = 1'b1;
end
/**********************************************************
 ***************Logic for source select********************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
	/*_____________________________________
 	______________load___________________*/
		if(ir[7] == 1'b0) 						// load command ID
			source_sel = 4'h8;
	/*_____________________________________
	 ______________mov____________________*/
		else if( (ir[7:6] == 2'b10) && (ir[5:3] == ir[2:0]) )
			if(ir[5:3] == 3'h4)				// if dst == o_reg
				source_sel = 4'h4;			// select r
			else
				source_sel = 4'h9;		
		else if( (ir[7:6] == 2'b10) && (ir[5:3] != ir[2:0]) )
			source_sel = ir[2:0];
		else
			source_sel = 4'b0;
	else
		source_sel = 4'd10;
end

/**********************************************************
 ***************Logic for i select*************************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
	/*_____________________________________
 	______________load___________________*/
		if( (ir[7] == 1'b0) && (ir[6:4] == 3'b111) )						// load command ID
				i_sel = 1'b1;
	
	/*_____________________________________
 	______________mov____________________*/
		else if( (ir[7:6] == 2'b10) && (ir[5:3] == 3'h7) )
			i_sel = 1'b1;
		else if( (ir[7:6] == 2'b10) && (ir[2:0] == 3'h7) && (ir[5:3] != 3'h6) )
			i_sel = 1'b1;
		else
			i_sel = 1'b0;
	else
		i_sel = 1'b0;
end

/**********************************************************
 ***************Logic for x select*************************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
	/*_____________________________________
 	______________load___________________*/
		if( (ir[7] == 1'b0) && (ir[6:4] == 3'H1) )						// load command ID dst = x1								
				x_sel = 1'b1;
	/*_____________________________________
	 ______________mov____________________*/
		else if( (ir[7:6] == 2'b10) && (ir[5:3] == 3'h1) )				// mov command ID
			x_sel = 1'b1;
	/*_____________________________________
 	______________ALU____________________*/
		else if( (ir[7:5] == 3'b110) && (ir[4] != 1'b0) )			// ALU command ID
			x_sel = 1'b1;
		else
			x_sel = 1'b0;
	else
		x_sel = 1'b0;
end

/**********************************************************
 ***************Logic for y select*************************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
	/*_____________________________________
	 ______________load___________________*/
		if( (ir[7] == 1'b0) && (ir[6:4] == 3'h3) )  		// load command ID dst = y1		
			y_sel = 1'b1;
	/*_____________________________________
	 ______________mov____________________*/
		else if( (ir[7:6] == 2'b10) && (ir[5:3] == 3'h3) )	// mov command ID
			y_sel = 1'b1;
	/*_____________________________________
	 ______________ALU____________________*/
		else if( (ir[7:5] == 3'b110) && (ir[3] != 1'b0) )	// ALU command ID
			y_sel = 1'b1;
		else
			y_sel = 1'b0;
	else
		y_sel = 1'b0;
end

/**********************************************************
 ***************Logic for jump*****************************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
 	/*_____________________________________
 	______________jump___________________*/
 		if(ir[7:4] == 4'b1110)				// jump command ID
 			jump = 1'b1;
		else
			jump = 1'b0;
	else
		jump = 1'b0;
end

/**********************************************************
 ***************Logic for conditional jump*****************
 **********************************************************/
always @ *
begin
	if(sync_reset == 1'b0)
 	/*_____________________________________
 	_________conditional_jump_____________*/
 		if(ir[7:4] == 4'b1111)				// conditional jump ID
 			conditional_jump = 1'b1;
		else
			conditional_jump = 1'b0;
	else
		conditional_jump = 1'b0;
end


endmodule
