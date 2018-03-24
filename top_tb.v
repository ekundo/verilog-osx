`timescale 1ps / 1ps

module top_tb
#(

	parameter i_h_disp				=	12'd640,
	parameter i_h_fporch			=	12'd10,
	parameter i_h_sync				=	12'd56,
	parameter i_h_bporch			=	12'd62,

	parameter i_v_disp				=	12'd576,
	parameter i_v_fporch			=	12'd21,
	parameter i_v_sync				=	12'd5,
	parameter i_v_bporch			=	12'd22,

	// parameter i_h_disp				=	12'd40,
	// parameter i_h_fporch			=	12'd10,
	// parameter i_h_sync				=	12'd5,
	// parameter i_h_bporch			=	12'd15,

	// parameter i_v_disp				=	12'd30,
	// parameter i_v_fporch			=	12'd3,
	// parameter i_v_sync				=	12'd2,
	// parameter i_v_bporch			=	12'd4,
		
	parameter i_hs_polarity			=	1'b0,
	parameter i_vs_polarity			=	1'b0,
	parameter i_frame_interlaced	=	1'b0,


	parameter o_h_disp				=	12'd640,
	parameter o_h_fporch			=	12'd16,
	parameter o_h_sync				=	12'd96,
	parameter o_h_bporch			=	12'd48,

	parameter o_v_disp				=	12'd350,
	parameter o_v_fporch			=	12'd37,
	parameter o_v_sync				=	12'd2,
	parameter o_v_bporch			=	12'd60,

	// parameter o_h_disp				=	12'd40,
	// parameter o_h_fporch			=	12'd10,
	// parameter o_h_sync				=	12'd5,
	// parameter o_h_bporch			=	12'd15,

	// parameter o_v_disp				=	12'd15,
	// parameter o_v_fporch			=	12'd3,
	// parameter o_v_sync				=	12'd2,
	// parameter o_v_bporch			=	12'd4,
		
	parameter o_hs_polarity			=	1'b1,
	parameter o_vs_polarity			=	1'b0,
	parameter o_frame_interlaced	=	1'b0
	
)
();

parameter i_h_total				=	i_h_disp + i_h_fporch + i_h_sync + i_h_bporch;
parameter i_v_total				=	i_v_disp + i_v_fporch + i_v_sync + i_v_bporch;
parameter i_s_total				=	i_h_total * i_v_total + 2;

parameter frames				=	3;

reg				clk, clk25, clk100, clk100s, reset;

initial begin
	$dumpfile("top_tb.vcd");
	$dumpvars(0, top_inst);

	reset		<= 1;
	clk25		<= 1;
	clk100		<= 1;
	clk100s		<= 0;

	repeat (10) @(posedge clk);
	reset <= 0;
	repeat (10) @(posedge clk);
	reset <= 1;

	repeat ( i_s_total * frames ) @(posedge clk)
	begin
		repeat (1) @(posedge clk);
		clk100	<= 1;
		repeat (3) @(posedge clk);
		clk100s	<= 0;
		repeat (2) @(posedge clk);
		clk100	<= 0;
		repeat (3) @(posedge clk);
		clk100s	<= 1;
		repeat (2) @(posedge clk);
		clk100	<= 1;
		clk25	<= 0;
		repeat (3) @(posedge clk);
		clk100s	<= 0;
		repeat (2) @(posedge clk);
		clk100	<= 0;
		repeat (3) @(posedge clk);
		clk100s	<= 1;
		repeat (2) @(posedge clk);
		clk100	<= 1;
		repeat (3) @(posedge clk);
		clk100s	<= 0;
		repeat (2) @(posedge clk);
		clk100	<= 0;
		repeat (3) @(posedge clk);
		clk100s	<= 1;
		repeat (2) @(posedge clk);
		clk100	<= 1;
		clk25	<= 1;
		repeat (3) @(posedge clk);
		clk100s	<= 0;
		repeat (2) @(posedge clk);
		clk100	<= 0;
		repeat (3) @(posedge clk);
		clk100s	<= 1;
	end

	$finish;
end

initial
	begin
		clk <= 1;
		forever #500 clk <= !clk;
	end

top #(

	.i_h_disp				(	i_h_disp				),
	.i_h_fporch				(	i_h_fporch				),
	.i_h_sync				(	i_h_sync				),
	.i_h_bporch				(	i_h_bporch				),

	.i_v_disp				(	i_v_disp				),
	.i_v_fporch				(	i_v_fporch				),
	.i_v_sync				(	i_v_sync				),
	.i_v_bporch				(	i_v_bporch				),
	
	.i_hs_polarity			(	i_hs_polarity			),
	.i_vs_polarity			(	i_vs_polarity			),
	.i_frame_interlaced		(	i_frame_interlaced		),

	.o_h_disp				(	o_h_disp				),
	.o_h_fporch				(	o_h_fporch				),
	.o_h_sync				(	o_h_sync				),
	.o_h_bporch				(	o_h_bporch				),

	.o_v_disp				(	o_v_disp				),
	.o_v_fporch				(	o_v_fporch				),
	.o_v_sync				(	o_v_sync				),
	.o_v_bporch				(	o_v_bporch				),
	
	.o_hs_polarity			(	o_hs_polarity			),
	.o_vs_polarity			(	o_vs_polarity			),
	.o_frame_interlaced		(	o_frame_interlaced		)
	
) top_inst (

	.clk25					(	clk25					),
	.clk100					(	clk100					),
	.clk100s				(	clk100					),
	.reset					(	reset					)

);

endmodule
