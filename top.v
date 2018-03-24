`timescale 1ns / 1ps

module top
#(

	parameter 					addr_bits				=	12,
	parameter 					data_bits				=	16,

	parameter					i_h_disp				=	12'd640,
	parameter					i_h_fporch				=	12'd10,
	parameter					i_h_sync				=	12'd56,
	parameter					i_h_bporch				=	12'd62,

	parameter					i_v_disp				=	12'd576,
	parameter					i_v_fporch				=	12'd21,
	parameter					i_v_sync				=	12'd5,
	parameter					i_v_bporch				=	12'd22,
		
	parameter 					i_hs_polarity			=	1'b0,
	parameter 					i_vs_polarity			=	1'b0,
	parameter 					i_frame_interlaced		=	1'b0,


	parameter 					o_h_disp				=	12'd640,
	parameter 					o_h_fporch				=	12'd16,
	parameter 					o_h_sync				=	12'd96,
	parameter 					o_h_bporch				=	12'd48,

	parameter 					o_v_disp				=	12'd350,
	parameter 					o_v_fporch				=	12'd37,
	parameter 					o_v_sync				=	12'd2,
	parameter 					o_v_bporch				=	12'd60,
		
	parameter 					o_hs_polarity			=	1'b0,
	parameter 					o_vs_polarity			=	1'b0,
	parameter 					o_frame_interlaced		=	1'b0
	
)
(

	input						clk25,
	input						clk100,
	input						clk100s,
	input						reset

);

wire	[addr_bits - 1:0]	sdr_addr;
wire	[1:0]				sdr_bank_addr;
wire	[data_bits - 1:0]	sdr_data;
wire						sdr_clock_enable;
wire						sdr_cs_n;
wire						sdr_ras_n;
wire						sdr_cas_n;
wire						sdr_we_n;
wire	[1:0]				sdr_data_mask;

sdr #(

	.ADDR_BITS			(	addr_bits				),
	.ROW_BITS			(	addr_bits				),
	.COL_BITS			(	8						),
	.DQ_BITS			(	data_bits				),
	.DM_BITS			(	2						),
	.BA_BITS			(	2						)

) sdr_inst (

	.Dq					(	sdr_data				),
	.Addr				(	sdr_addr				),
	.Ba					(	sdr_bank_addr			),
	.Clk				(	clk100s					),
	.Cke				(	sdr_clock_enable		),
	.Cs_n				(	sdr_cs_n				),
	.Ras_n				(	sdr_ras_n				),
	.Cas_n				(	sdr_cas_n				),
	.We_n				(	sdr_we_n				),
	.Dqm				(	sdr_data_mask			)

);


wire						hsync;
wire						vsync;

wire	[3:0]				vga_r;
wire	[3:0]				vga_g;
wire	[3:0]				vga_b;

vga #(

	.h_disp				(	i_h_disp				),
	.h_fporch			(	i_h_fporch				),
	.h_sync				(	i_h_sync				),
	.h_bporch			(	i_h_bporch				),

	.v_disp				(	i_v_disp				),
	.v_fporch			(	i_v_fporch				),
	.v_sync				(	i_v_sync				),
	.v_bporch			(	i_v_bporch				),
	
	.hs_polarity		(	i_hs_polarity			),
	.vs_polarity		(	i_vs_polarity			),
	.frame_interlaced	(	i_frame_interlaced		)
	
) vga_inst (

	.clk				(	clk25					),
	.reset				(	reset					),

	.hsync				(	hsync					),
	.vsync				(	vsync					),

	.vga_r				(	vga_r					),
	.vga_g				(	vga_g					),
	.vga_b				(	vga_b					)

);


converter #(

	.i_h_disp			(	i_h_disp				),
	.i_h_bporch			(	i_h_bporch				),

	.i_v_disp			(	i_v_disp				),
	.i_v_bporch			(	i_v_bporch				),
				
	.i_hs_polarity		(	i_hs_polarity			),
	.i_vs_polarity		(	i_vs_polarity			),


	.o_h_disp			(	o_h_disp				),
	.o_h_fporch			(	o_h_fporch				),
	.o_h_sync			(	o_h_sync				),
	.o_h_bporch			(	o_h_bporch				),

	.o_v_disp			(	o_v_disp				),
	.o_v_fporch			(	o_v_fporch				),
	.o_v_sync			(	o_v_sync				),
	.o_v_bporch			(	o_v_bporch				),
	
	.o_hs_polarity		(	o_hs_polarity			),
	.o_vs_polarity		(	o_vs_polarity			),
	.o_frame_interlaced	(	o_frame_interlaced		)
	
) converter_inst (
	
	.clk_in				(	clk25					),
	.clk_out			(	clk25					),
	.clk100				(	clk100					),
	.reset				(	reset					),

	.i_hsync			(	hsync					),
	.i_vsync			(	vsync					),

	.i_vga_r			(	vga_r					),
	.i_vga_g			(	vga_g					),
	.i_vga_b			(	vga_b					),

	.sdr_addr			(	sdr_addr				),
	.sdr_bank_addr		(	sdr_bank_addr			),
	.sdr_data			(	sdr_data				),
	.sdr_clock_enable	(	sdr_clock_enable		),
	.sdr_cs_n			(	sdr_cs_n				),
	.sdr_ras_n			(	sdr_ras_n				),
	.sdr_cas_n			(	sdr_cas_n				),
	.sdr_we_n			(	sdr_we_n				),
	.sdr_data_mask		(	sdr_data_mask			)

);

endmodule
