module converter
#(

			parameter 		i_h_disp				=	12'd640,
			parameter 		i_h_bporch				=	12'd62,

			parameter 		i_v_disp				=	12'd576,
			parameter 		i_v_bporch				=	12'd22,
				
			parameter 		i_hs_polarity			=	1'b0,
			parameter 		i_vs_polarity			=	1'b0,


			parameter 		o_h_disp				=	12'd640,
			parameter 		o_h_fporch				=	12'd16,
			parameter 		o_h_sync				=	12'd96,
			parameter 		o_h_bporch				=	12'd48,

			parameter 		o_v_disp				=	12'd350,
			parameter 		o_v_fporch				=	12'd37,
			parameter 		o_v_sync				=	12'd2,
			parameter 		o_v_bporch				=	12'd60,
				
			parameter 		o_hs_polarity			=	1'b0,
			parameter 		o_vs_polarity			=	1'b0,
			parameter 		o_frame_interlaced		=	1'b0
	
)
(

			input			clk_in,
			input			clk_out,
			input			clk100,
			input			reset,

			input			i_hsync,
			input			i_vsync,

			input	[3:0]	i_vga_r,
			input	[3:0]	i_vga_g,
			input	[3:0]	i_vga_b,

			output	[11:0]	sdr_addr,
			output	[1:0]	sdr_bank_addr,
			inout	[15:0]	sdr_data,
			output			sdr_clock_enable,
			output			sdr_cs_n,
			output			sdr_ras_n,
			output			sdr_cas_n,
			output			sdr_we_n,
			output	[1:0]	sdr_data_mask,

			output			o_hsync,
			output			o_vsync,

			output	[3:0]	o_vga_r,
			output	[3:0]	o_vga_g,
			output	[3:0]	o_vga_b

);


wire				rd_in_fifo;
wire	[11:0]		in_fifo;
wire	[7:0]		inusedw;

vga_reader #(

	.h_disp				(	i_h_disp				),
	.h_bporch			(	i_h_bporch				),

	.v_disp				(	i_v_disp				),
	.v_bporch			(	i_v_bporch				),

	.hs_polarity		(	i_hs_polarity			),
	.vs_polarity		(	i_vs_polarity			)
	

) vga_reader_inst (

	.vga_clk			(	clk_in				),
	.sdram_clk			(	clk100				),

	.reset				(	reset				),

	.hsync				(	i_hsync				),
	.vsync				(	i_vsync				),

	.vga_r				(	i_vga_r				),
	.vga_g				(	i_vga_g				),
	.vga_b				(	i_vga_b				),

	.rdusedw			(	inusedw				),
	.rd_fifo			(	rd_in_fifo			),
	.from_fifo			(	in_fifo				)

);


wire				sd_ready;
wire				wr_out_fifo;
wire				wr_strobe;
wire				rd_strobe;

sdram_cntr #(

	.burst_size			(	128						)

) sdram_cntr_inst (

	.clk				(	clk100					),
	.rst_n				(	reset					),
	.wr					(	wr_strobe				),
	.rd					(	rd_strobe 				),
	.valid_data			(	wr_out_fifo				),
	.data				(	in_fifo					),
	.cs_n				(	sdr_cs_n				),
	.ras_n				(	sdr_ras_n				),
	.cas_n				(	sdr_cas_n				),
	.we_n				(	sdr_we_n				),
	.dqm				(	sdr_data_mask			),
	.sd_addr			(	sdr_addr				),
	.ba					(	sdr_bank_addr			),
	.cke				(	sdr_clock_enable		),
	.sd_data			(	sdr_data				),
	.rd_ena				(	rd_in_fifo				),
	.sd_ready			(	sd_ready				),
	.i_vsync			(	i_vsync					),
	.o_vsync			(	o_vsync					)

);


wire	[7:0]		outusedw;

coordinator coordinator_inst (

	.sdram_clk			(	clk100					),
	.reset				(	reset					),

	.inusedw			(	inusedw					),
	.outusedw			(	outusedw				),

	.sd_ready			(	sd_ready				),

	.wr_strobe			(	wr_strobe				),
	.rd_strobe			(	rd_strobe				)

);

vga_writer #(

	.h_disp				(	o_h_disp				),
	.h_fporch			(	o_h_fporch				),
	.h_sync				(	o_h_sync				),
	.h_bporch			(	o_h_bporch				),

	.v_disp				(	o_v_disp				),
	.v_fporch			(	o_v_fporch				),
	.v_sync				(	o_v_sync				),
	.v_bporch			(	o_v_bporch				),
	
	.hs_polarity		(	o_hs_polarity			),
	.vs_polarity		(	o_vs_polarity			),
	.frame_interlaced	(	o_frame_interlaced		)
	
) vga_writer_inst (

	.vga_clk			(	clk_out					),
	.sdram_clk			(	clk100					),

	.reset				(	reset					),

	.wr_fifo			(	wr_out_fifo				),
	.sdram_data			(	sdr_data				),

	.hsync				(	o_hsync					),
	.vsync				(	o_vsync					),

	.vga_r				(	o_vga_r					),
	.vga_g				(	o_vga_g					),
	.vga_b				(	o_vga_b					),

	.wrusedw			(	outusedw				)
	
);

endmodule
