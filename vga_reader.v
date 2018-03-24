module vga_reader
#(

	parameter 					h_disp				=	12'd640,
	parameter 					h_bporch			=	12'd62,

	parameter 					v_disp				=	12'd576,
	parameter 					v_bporch			=	12'd22,
		
	parameter 					hs_polarity			=	1'b0,
	parameter 					vs_polarity			=	1'b0

)
(

	input						vga_clk,
	input						sdram_clk,

	input						reset,

	input			[3:0]		vga_r,
	input			[3:0]		vga_g,
	input			[3:0]		vga_b,
	input						hsync,
	input						vsync,

	output			[ 7: 0]		rdusedw,
	output 						wr_fifo,
	input						rd_fifo,
	output			[11: 0]		from_fifo

);


reg 				prev_hsync;
reg 				curr_hsync;

always @( posedge vga_clk or negedge reset )
	if  ( !reset ) begin
		prev_hsync		<= 1'h1;
		curr_hsync		<= 1'h1;
	end else begin
		prev_hsync		<= curr_hsync;
		curr_hsync		<= hsync;
	end

assign p_hsync = !prev_hsync && curr_hsync;

reg					first_vsync;
reg		[11:0]		v_counter;

always @( posedge vga_clk or negedge reset )
	if  ( !reset ) begin
		first_vsync			<= 1'h0;
		v_counter			<= 1'h0;
	end else
		if ( !vsync ) begin
			first_vsync		<=	1'h1;
			v_counter		<=	1'h0;
		end else
			if (p_hsync && first_vsync)
				v_counter	<=	v_counter + 1'b1;


reg		[11:0]		h_counter;

always @( posedge vga_clk or negedge reset )
	if  ( !reset )
		h_counter			<= 1'h0;
	else
		if ( !hsync )
			h_counter		<=	1'h0;
		else
			h_counter		<=	h_counter + 1'b1;


wire		[11:0]		pixel_x;
wire		[11:0]		pixel_y;

assign v_de = ( ( v_counter > v_bporch ) && ( v_counter <= v_bporch + v_disp ) ) ? 1'h1 : 1'h0;
assign h_de = ( ( h_counter > h_bporch ) && ( h_counter <= h_bporch + h_disp ) ) ? 1'h1 : 1'h0;

assign pixel_y = v_de ? v_counter - v_bporch - 12'd1 : 12'h0;

assign wr_fifo = ( reset && v_de && h_de && (
	(	pixel_y				<=	12'd33	) ||
	(	pixel_y				>=	12'd546	) ||
	(	pixel_y % 12'd2		==	12'd1	)
) ) ? 1'h1 : 1'h0;


wire	[11: 0]		to_fifo;
assign to_fifo = wr_fifo ? { vga_r, vga_g, vga_b } : 12'hZ;


fifo_256x12 fifo
(
	.aclr				( !reset				),
	.data				( to_fifo				),
	.rdclk              ( sdram_clk				),
	.rdreq              ( rd_fifo				),
	.wrclk              ( vga_clk				),
	.wrreq              ( wr_fifo				),
	.q                  ( from_fifo				),
	.rdusedw            ( rdusedw				),
	.wrusedw            ( 						)
);

endmodule