module vga_writer
#(

	parameter 					h_disp				=	12'd640,
	parameter 					h_fporch			=	12'd16,
	parameter 					h_sync				=	12'd96,
	parameter 					h_bporch			=	12'd48,

	parameter 					v_disp				=	12'd350,
	parameter 					v_fporch			=	12'd37,
	parameter 					v_sync				=	12'd2,
	parameter 					v_bporch			=	12'd60,

	parameter 					hs_polarity			=	1'b0,
	parameter 					vs_polarity			=	1'b0,
	parameter 					frame_interlaced	=	1'b0

)
(

	input						vga_clk,
	input						sdram_clk,

	input						reset,

	input						wr_fifo,
	input			[15:0]		sdram_data,

	output						hsync,
	output						vsync,

	output			[3:0]		vga_r,
	output			[3:0]		vga_g,
	output			[3:0]		vga_b,

	output 			[7:0]		wrusedw

);


wire	[11:0]	pixel_x;
wire	[11:0]	pixel_y;
wire			display_enable;
wire			s_hsync;
wire			s_vsync;

vga_sync #(

	.h_disp				(	h_disp				),
	.h_fporch			(	h_fporch			),
	.h_sync				(	h_sync				),
	.h_bporch			(	h_bporch			),

	.v_disp				(	v_disp				),
	.v_fporch			(	v_fporch			),
	.v_sync				(	v_sync				),
	.v_bporch			(	v_bporch			),
	
	.hs_polarity		(	hs_polarity			),
	.vs_polarity		(	vs_polarity			),
	.frame_interlaced	(	frame_interlaced	)
	
) sync (

	.clk				(	vga_clk				),
	.reset_n			(	reset				),

	.vga_hs				(	s_hsync				),
	.vga_vs				(	s_vsync				),
	.vga_de				(	display_enable		),
	.pixel_x			(	pixel_x				),
	.pixel_y			(	pixel_y				),
	.pixel_i_odd_frame	(						) 

);


wire	[11:0]	from_fifo;

fifo_256x12 fifo
(

	.aclr				(	!reset				),
	.data				(	sdram_data[11:0]	),
	.rdclk				(	vga_clk				),
	.rdreq				(	display_enable		),
	.wrclk				(	sdram_clk			),
	.wrreq				(	wr_fifo				),
	.q					(	from_fifo			),
	.wrusedw			(	wrusedw				)

);


reg 			prev_hsync;
reg 			prev_vsync;
reg 			prev_display_enable;

always @( posedge vga_clk or negedge reset )
	if ( !reset ) begin
		prev_hsync			<= hs_polarity ? 1'b1 : 1'b0;
		prev_vsync			<= 1'h0;
		prev_display_enable	<= 1'h0;
	end else begin
		prev_hsync			<= s_hsync;
		prev_vsync			<= s_vsync;
		prev_display_enable	<= display_enable;
	end


assign hsync					=	prev_hsync;
assign vsync					=	prev_vsync;
assign { vga_r, vga_g, vga_b }	=	prev_display_enable && pixel_y <= 12'd319 ? from_fifo : 12'd0;

endmodule