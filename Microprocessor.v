module Microprocessor 
( 
	input wire clk,
	input wire reset,
	input wire [3:0] i_pins,
	output wire zero_flag,
	output wire [7:0] pm_data,
	output wire [7:0] pc,
	output wire [7:0] from_PS,
	output wire [7:0] ir,
	output wire [7:0] from_ID,
	output wire NOPC8,
	output wire NOPCF,
	output wire NOPD8,
	output wire NOPDF,
	output wire [7:0] pm_address,
	output wire [3:0] data_bus,
	output wire [3:0] o_reg, i, m, r, y1, y0, x1, x0,
	output wire [7:0] from_CU,
	output wire jump,
	output wire conditional_jump,
	output wire i_sel,
	output wire y_sel, x_sel, 
	output wire [3:0] source_sel, 
	output wire [3:0] dm,
	output wire [8:0] reg_en,
	output wire [3:0] nibble_ir,
	output wire [3:0] alu_out,
	output wire alu_out_eq_0
); 

reg sync_reset;

always @(posedge clk)
	sync_reset <= reset;

program_sequencer prog_sequencer 
(
	.clk(clk),
	.sync_reset(sync_reset),
	.dont_jmp(zero_flag),
	.jump(jump),
	.conditional_jump(conditional_jump),
	.jump_address(nibble_ir), 
	.pm_addr(pm_address),
	.pc(pc), //pc is taken out for purposes of debugging
	.from_PS(from_PS)
);

instruction_decoder inst_decoder
( 
	.clk(clk), 
	.sync_reset(sync_reset),
	.next_instr(pm_data),
	.jump(jump),
	.conditional_jump(conditional_jump),
	.jump_address(nibble_ir),
	.i_sel(i_sel),
	.y_sel(y_sel),
	.x_sel(x_sel),
	.source_sel(source_sel),
	.reg_en(reg_en),
	.ir(ir), // ir is for purposes of debugging
	.from_ID(from_ID),
	.NOPC8(NOPC8),
	.NOPCF(NOPCF),
	.NOPD8(NOPD8),
	.NOPDF(NOPDF)
);

CPU cu 	
( 	
	.clk(clk),
	.sync_reset(sync_reset),
	.nibble_ir(nibble_ir),
	.i_sel(i_sel),
	.y_sel(y_sel),
	.x_sel(x_sel),
	.source_sel(source_sel),
	.reg_en(reg_en),
	.dm(dm),
	.i_pins(i_pins),
	.zero_flag(zero_flag),
	.i(i),
	.data_bus(data_bus),
	.o_reg(o_reg),
	.x0(x0),
	.x1(x1),
	.y0(y0),
	.y1(y1),
	.r(r),
	.m(m),
	.from_CU(from_CU),
	.alu_out_eq_0(alu_out_eq_0),
	.alu_out(alu_out)
);

data_memory d_mem
(		
	.clock(~clk),
	.address(i),
	.data(data_bus),
	.wren(reg_en[7]),
	.q(dm)
);

program_memory prog_memory
(
	.address(pm_address),
	.clock(~clk),
	.q(pm_data)
);

endmodule