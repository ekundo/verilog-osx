module	vga_bitstream
#(

	parameter 			h_disp			=	12'd640

)
(

	input				clk,
	input				reset,

	input				display_enable,

	input		[11:0]	pixel_x,
	input		[11:0]	pixel_y,

	output reg	[3:0]	o_vga_r,
	output reg	[3:0]	o_vga_g,
	output reg	[3:0]	o_vga_b

);

always@(posedge clk or negedge reset)
begin
	if(!reset)
	begin
		o_vga_r	<=	4'b0;
		o_vga_g	<=	4'b0;
		o_vga_b	<=	4'b0;
	end
	else
	begin
		if ( display_enable )
			{ o_vga_r, o_vga_g, o_vga_b } <= pixel_x + 1;
		else
			{ o_vga_r, o_vga_g, o_vga_b } <= 12'd0;
	end
end

endmodule
