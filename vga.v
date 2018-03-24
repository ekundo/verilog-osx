module vga
#(

	parameter		h_disp				=	12'd640,
	parameter		h_fporch			=	12'd10,
	parameter		h_sync				=	12'd56,
	parameter		h_bporch			=	12'd62,

	parameter		v_disp				=	12'd576,
	parameter		v_fporch			=	12'd21,
	parameter		v_sync				=	12'd5,
	parameter		v_bporch			=	12'd22,

	parameter 		hs_polarity			=	1'b0,
	parameter 		vs_polarity			=	1'b0,
	parameter 		frame_interlaced	=	1'b0

)
(

	input			clk,
	input			reset,

	output			hsync,
	output			vsync,

	output	[3:0]	vga_r,
	output	[3:0]	vga_g,
	output	[3:0]	vga_b

);

wire	[11:0]	pixel_x;
wire	[11:0]	pixel_y;
wire			display_enable;

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
	.clk				(	clk					),
	.reset_n			(	reset				),

	.vga_hs				(	hsync				),
	.vga_vs				(	vsync				),
	.vga_de				(	display_enable		),
	.pixel_x			(	pixel_x				),
	.pixel_y			(	pixel_y				),
	.pixel_i_odd_frame	(						) 
);


vga_bitstream #(

	.h_disp				(	h_disp				)

) bitstream (
	.clk				(	clk					),
	.reset				(	reset				),

	.display_enable		(	display_enable		),

	.pixel_x			(	pixel_x				),
	.pixel_y			(	pixel_y				),

	.o_vga_r			(	vga_r				),
	.o_vga_g			(	vga_g				),
	.o_vga_b			(	vga_b				)
);

endmodule
