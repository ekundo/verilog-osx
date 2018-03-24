module sdram_cntr_small
(

	input wire  						clk,
	input wire							rst_n,
	input wire							wr,
	input wire							rd,	
	input wire		[15: 0]				data,
	input wire							p_i_vsync,
	input wire							p_o_vsync,
	output reg							valid_data,
	output reg							rd_ena,
	output reg							sd_ready,

	output reg							cs_n,
	output reg							ras_n,
	output reg							cas_n,
	output reg							we_n,
	output reg		[ 1: 0]				dqm,
	output reg		[11: 0]				sd_addr,
	output reg		[ 1: 0]				ba,
	output reg							Cke,
	inout wire		[15: 0]				sd_data

);

parameter			burst_size		=	256;
parameter			burst_max		=	burst_size - 1;

reg					mode_flag;
reg		[ 7: 0]		cnt_burst;
reg		[11: 0]		cur_addr_wr;
reg		[11: 0]		cur_addr_rd;
reg					protect;
reg		[1:0]		prev_bank_wr;
reg		[1:0]		bank_wr;
reg		[1:0]		bank_rd;
reg					cur_wr;
reg					cur_rd;
reg					delay;

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		Cke		<= 1'h1;
	else
		Cke		<= 1'h1;

localparam		s0_idle			= 4'd1;
localparam		s0_NOP			= 4'd2;
localparam		s0_MRS			= 4'd3;
localparam		s0_ACT			= 4'd4;
localparam		s0_READ			= 4'd5;
localparam		s0_WRIT			= 4'd6;
localparam		s0_PRE			= 4'd7;
localparam		s0_PALL			= 4'd8;
localparam		s0_Trcd			= 4'd9;
localparam		s0_Trp			= 4'd10;

reg [3:0]	cs;
reg [3:0]	ns;
reg [1:0]	cnt_mrs;

always @(posedge clk or negedge rst_n)
	if ( !rst_n )		cs	<= s0_idle;
	else				cs	<= ns;

always @*
	begin
		ns = cs;
		case ( cs )

			s0_idle:				if ( rst_n & !mode_flag  )
										ns = s0_PALL;
									else if ( rst_n & mode_flag & ( cur_wr | cur_rd ) )
										ns = s0_ACT;

			s0_PALL:				ns = s0_NOP;

			s0_MRS:					ns = s0_idle;

			s0_ACT:					ns = s0_Trcd;

			s0_NOP:					if ( !mode_flag )
										ns = s0_MRS;
									else if ( cnt_mrs < 2'h0)
										ns = s0_idle;
									else if ( cnt_burst == burst_max )
										ns = s0_PRE;
									else
										ns = s0_NOP;

			s0_WRIT:				ns = s0_NOP;

			s0_READ:				ns = s0_NOP;

			s0_PRE:					ns = s0_Trp;

			s0_Trcd:				if ( delay == 1'h0 )
										ns = s0_Trcd;
									else if ( cur_wr )
										ns = s0_WRIT;
									else if ( cur_rd )
										ns = s0_READ;

			s0_Trp:					if ( delay == 1'h0 )
										ns = s0_Trp;
									else
										ns = s0_idle;

			default:				ns = s0_idle;

		endcase
	end

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		cnt_mrs								<= 2'h0;
	else
		if ( cs == s0_MRS )
			cnt_mrs	<= cnt_mrs + 1'h1;

always @ ( posedge clk or negedge rst_n )
	if ( !rst_n )
		delay		<= 1'h0;
	else
		if ( ( cs == s0_Trcd ) | ( cs == s0_Trp ) )
			delay	<= delay + 1'h1;

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		mode_flag		<= 1'h0;
	else 
		if ( cs == s0_MRS )
			mode_flag	<= 1'h1; 

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		cnt_burst		<= 8'h0;
	else
		if ( cnt_burst == burst_max )
			cnt_burst	<= 8'h0;
		else if ( ( cs == s0_WRIT ) | ( cs == s0_READ ) | ( cnt_burst == burst_max ) )
			cnt_burst	<= 8'h1;
		else if ( cnt_burst != 8'h0 )
			cnt_burst	<= cnt_burst + 1'h1;

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		begin
			cur_wr			<= 1'h0;
			cur_rd			<= 1'h0;
		end
	else
		begin
			if ( cnt_burst == burst_max/*7*/ )
				begin
					cur_wr	<= 1'h0;
					cur_rd	<= 1'h0;
				end
			else if ( rd )
				cur_rd		<= 1'h1;
			else if ( wr )
				cur_wr		<= 1'h1;
		end

always @ ( posedge clk or negedge rst_n )
	if ( ! rst_n )
		cur_addr_wr			<= 12'h0;
	else
		begin
			if ( p_i_vsync )
				cur_addr_wr	<= 12'h0;
			else if ( cs == s0_WRIT ) 
				cur_addr_wr	<= cur_addr_wr + 1'h1;
		end

always @ ( posedge clk or negedge rst_n )
	if ( ! rst_n )
		cur_addr_rd			<= 12'h0;
	else
		begin
			if ( p_o_vsync )
				cur_addr_rd	<= 12'h0;
			else if ( cs == s0_READ ) 
				cur_addr_rd	<= cur_addr_rd + 1'h1;
		end

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		begin
			prev_bank_wr		<= 2'h1;
			bank_wr				<= 2'h2;
		end
	else
		if ( p_i_vsync ) 
			begin
				prev_bank_wr	<= bank_wr;
				bank_wr			<= 2'h3 - bank_wr - bank_rd;
			end

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		begin
			bank_rd				<= 2'h0;
		end
	else
		if ( p_o_vsync ) 
			begin
				bank_rd			<= prev_bank_wr;
			end

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		rd_ena		<= 1'h0;
	else
		if ( ( cs == s0_Trcd ) & cur_wr )
			rd_ena	<= 1'h1;
		else if ( cnt_burst == burst_max - 1'h1 )
			rd_ena	<= 1'h0;

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		sd_ready		<= 1'h0;
	else
		if ( ( cnt_burst == burst_max ) | ( cs == s0_MRS) )
			sd_ready	<= 1'h1;
		else if ( cs == s0_ACT )
			sd_ready	<= 1'h0;

always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		begin
			cs_n							<= 1'h1;
			ras_n							<= 1'h1;
			cas_n							<= 1'h1;
			we_n							<= 1'h1;
			ba								<= 2'h0;
			sd_addr							<= 12'h0;
			dqm								<= 2'h0;
		end
	else
		if ( ( ns == s0_NOP ) | ( ns == s0_idle ) | ( ns == s0_Trcd ) )
			begin
				cs_n						<= 1'h0;
				ras_n						<= 1'h1;
				cas_n						<= 1'h1;
				we_n						<= 1'h1;
				ba							<= 2'h0;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_000;
				dqm							<= 2'h0;
			end
		else if ( ns == s0_MRS )
			begin
				cs_n						<= 1'h0;
				ras_n						<= 1'h0;
				cas_n						<= 1'h0;
				we_n						<= 1'h0;
				ba							<= 2'h0;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_010_0_111;
				dqm							<= 2'h0;
			end
		else if ( ( ns == s0_ACT ) )
			begin
				cs_n						<= 1'h0;
				ras_n						<= 1'h0;
				cas_n						<= 1'h1;
				we_n						<= 1'h1;
					if ( cur_wr )
						begin
							sd_addr			<=	cur_addr_wr;
							ba				<=	bank_wr;
						end
					else if ( cur_rd )
						begin
							sd_addr			<= cur_addr_rd;
							ba				<= bank_rd;
						end
					else
						begin
							sd_addr			<= 12'h0;
							ba				<= 2'h0;
						end
				dqm							<= 2'h0;
			end
		else if ( ns == s0_READ )
			begin 
				cs_n						<= 1'h0;
				ras_n						<= 1'h1;
				cas_n						<= 1'h0;
				we_n						<= 1'h1;
				ba							<= bank_rd;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_000;
				dqm							<= 2'h0;
			end
		else if ( ns == s0_WRIT )
			begin 
				cs_n						<= 1'h0;
				ras_n						<= 1'h1;
				cas_n						<= 1'h0;
				we_n						<= 1'h0;
				ba							<= bank_wr;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_000;
				dqm							<= 2'h0;
			end
		else if ( ( ns == s0_PRE ) | ( ns == s0_Trp ) )
			begin 
				cs_n						<= 1'h0;
				ras_n						<= 1'h0;
				cas_n						<= 1'h1;
				we_n						<= 1'h0;
				if ( cur_rd )
					ba						<= bank_rd;
				else if ( cur_wr )
					ba						<= bank_wr;
				else
					ba						<= 2'h0;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_010;
				dqm							<= 2'h0;
			end
		else if ( ns == s0_PALL ) 
			begin
				cs_n						<= 1'h0;
				ras_n						<= 1'h0;
				cas_n						<= 1'h1;
				we_n						<= 1'h0;
				ba							<= 2'h0;
				sd_addr[10]					<= 1'h1;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_000;
				dqm							<= 2'h3;
			end
		else
			begin
				cs_n						<= 1'h0;
				ras_n						<= 1'h1;
				cas_n						<= 1'h1;
				we_n						<= 1'h1;
				ba							<= 2'h0;
				sd_addr[10]					<= 1'h0;
				{sd_addr[11],sd_addr[9:0]}	<= 11'b0__000_000_0_000;
				dqm							<= 2'h0;
			end

assign sd_data = ( cs == s0_WRIT ) | ( ( cs == s0_NOP ) & ( cnt_burst != 8'h0 ) & cur_wr )  ? data : 16'hZ;


always @( posedge clk or negedge rst_n )
	if ( !rst_n )
		begin
			valid_data		<= 1'h0;
		end
	else
		begin
			if ( cs == s0_READ )
				valid_data	<= 1'h1;
			else if ( cs == s0_PRE )
				valid_data	<= 1'h0;
		end

endmodule
