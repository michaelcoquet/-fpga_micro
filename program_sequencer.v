module program_sequencer
(
	input clk,
	input sync_reset,
	input jump,
	input conditional_jump,
	input dont_jmp,
	input [3:0] jump_address,
	output reg [7:0] pm_addr,
	output reg [7:0] pc,
	output reg [7:0] from_PS
);

always @*
	from_PS = 8'h00;

//pc register
always @(posedge clk)
		pc = pm_addr;
		
//decoding next instruction
always @*
begin
	if(sync_reset == 1'b1)
		pm_addr = 8'h00;
	else
		if(jump == 1'b1)
			pm_addr = {jump_address, 4'h0};
		else if( (conditional_jump == 1'b1) && (dont_jmp == 1'b0) )
			pm_addr = {jump_address, 4'h0};
		else
			pm_addr = pc + 8'h01;
end
		
		
endmodule
