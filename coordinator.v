module coordinator
(

	input					sdram_clk,
	input 					reset,

	input		[7:0]		inusedw,
	input		[7:0]		outusedw,

	input					sd_ready,

	output reg				wr_strobe,
	output reg				rd_strobe

);

reg		[9:0]	cnt_rd_fifo;


localparam		s1_wait		=	3'd1;
localparam		s1_rd		=	3'd2;
localparam		s1_wr		=	3'd3;

reg		[2:0]	cs;

always @(posedge sdram_clk or negedge reset)
	if ( !reset )
		begin
			cs			<=	s1_wait;
			wr_strobe	<=	1'h0;
			rd_strobe	<=	1'h0;
		end
	else
		begin
			wr_strobe	<=	1'h0;
			rd_strobe	<=	1'h0;

			case ( cs )

				s1_wait:				if ( ( inusedw >= 120 ) & sd_ready )
				// s1_wait:				if ( ( inusedw >= 240 ) & sd_ready )
				// s1_wait:				if ( ( inusedw >= 600 ) & sd_ready )
											begin
												cs			<=	s1_wr;
												wr_strobe	<=	1'h1;
											end

										else if ( ( outusedw <= 60 ) & sd_ready )
										// else if ( ( outusedw <= 200 ) & sd_ready )
										// else if ( ( outusedw <= 300 ) & sd_ready )
											begin
												cs			<=	s1_rd;
												rd_strobe	<=	1'h1;
											end

				s1_wr:					if ( !sd_ready )
											cs 				<= s1_wait;

				s1_rd:					if ( !sd_ready )
											cs 				<= s1_wait;

				default:				cs 					<= s1_wait;

			endcase
		end



endmodule