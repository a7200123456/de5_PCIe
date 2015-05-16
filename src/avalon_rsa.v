module avalon_rsa (
    clk,
    reset,
    
	//avalon_MM_m0
	avm_m0_waitrequest,
    avm_m0_address,
    avm_m0_read,
    avm_m0_write,
	avm_m0_readdatavalid,
	avm_m0_readdata,
	avm_m0_writedata,
	
	//avalon_MM_s0 => flag register
	avs_s0_waitrequest,
    avs_s0_address,
    avs_s0_read,
    avs_s0_write,
	avs_s0_readdata,
	avs_s0_writedata
);

//==== parameter definition ===============================
    //state
    parameter   idle_state= 2'b00;
    parameter   we_state  = 2'b01;
    parameter   cal_state = 2'b10;
    parameter   oe_state  = 2'b11;
    
//==== in/out declaration ==================================
    //-------- input ---------------------------
    input clk;
    input reset;
    
    //-------- avalon_MM_master --------------------------------------
    input  avm_m0_waitrequest;
    output [31:0] avm_m0_address; //
    output avm_m0_read; //
    output avm_m0_write; //
	input  avm_m0_readdatavalid;
	input  [255:0] avm_m0_readdata;
	output [255:0] avm_m0_writedata;//
	 
	output avs_s0_waitrequest;
	input  avs_s0_address;
	input  avs_s0_read;
	input  avs_s0_write;
	output [7:0] avs_s0_readdata;
	input  [7:0] avs_s0_writedata;
    
//==== reg/wire declaration ================================
    //-----------rsa_core-------------------
    reg   core_we;
    reg   core_oe;
	reg   next_core_we;
	reg   next_core_oe;
    reg   core_start;
	wire  next_core_start;
	reg   [1:0] core_reg_sel;
	reg   [1:0] next_core_reg_sel;
    reg   [4:0] core_addr;
	reg   [4:0] next_core_addr;
    wire  [7:0] core_data_i;
	wire  [7:0] next_core_data_i;
	 //-------- output --------------------------------------
    wire core_ready;
    wire [7:0] core_data_o;
	
	reg	 [255:0] temp_data_in;
	wire [255:0] next_temp_data_in;
	reg  [255:0] temp_data_out;
	reg  [255:0] next_temp_data_out;
		
	reg  [1:0] state;
	reg  [31:0]dram_addr;
	reg  addr_go_back;
	reg  dram_read;
	reg  next_dram_read;
	reg  dram_write;
	
	reg  [1:0] next_state;
	reg  [31:0]next_dram_addr;
	wire next_addr_go_back;
	reg  next_dram_write;
	
	wire  clk_25;
	reg	 flag_reg;
	reg  next_flag_reg;
	reg  out31_flag;
	reg	 next_out31_flag;
	 
//==== combinational part ==================================
   //next_slow_counter = clk_25 + 1'b1;
    clksrc clk_rsa(
		.refclk(clk),   //  refclk.clk
		.rst(reset),      //   reset.reset
		.outclk_0(clk_25)  // outclk0.clk
	);
   
	// flag_reg 
	always@(*) begin
		if(avs_s0_write == 1'b1)
			next_flag_reg = avs_s0_writedata[0];
		else if (state == oe_state && dram_addr == 32'd320)
			next_flag_reg = 1'b0;
		else 
			next_flag_reg = flag_reg;
	end
	always@(*) begin
		if(state==oe_state && core_addr==5'd31 && out31_flag == 1'b0&&  clk_25 == 1'b0)
			next_out31_flag = 1'b1;
		else if (out31_flag == 1'b1 &&  clk_25 == 1'b0)
			next_out31_flag = 1'b0;
		else
			next_out31_flag = out31_flag;
	end
	
	assign avs_s0_readdata = {8{flag_reg}};
	assign avs_s0_waitrequest = 1'b0;
	
	//finite state machine
   always@(*) begin
        case(state)
            idle_state:begin
				if (flag_reg == 1)
					next_state = we_state;
				else next_state = idle_state;
            end    
            we_state: begin
				if (core_addr == 5'd31 && core_reg_sel == 2'b01 && clk_25 == 1'b0)
					next_state = cal_state;
				else next_state = we_state;
			end      
            cal_state:begin
				if (core_ready == 1 && core_start == 0)
					next_state = oe_state;
				else next_state = cal_state;
            end   
            oe_state:begin
				//if ()
				//	next_state = idle_state;
				//else 
				if (core_addr == 5'd31 && avm_m0_waitrequest == 1'b0 && dram_write == 1)
					next_state = we_state;
				else next_state = oe_state;
            end
            default: begin
				next_state = state;
            end
        endcase
    end
	
	//dram_addr (avalon_adddress)
	always@(*) begin
        case(state)
            idle_state:begin
				next_dram_addr = 32'd0;
            end    
            we_state: begin
				if (avm_m0_readdatavalid == 1'd1)
					next_dram_addr = dram_addr + 32'd32;
				else 
					next_dram_addr = dram_addr;
			end      
            cal_state:begin
				if (core_start == 1'b1 && clk_25 == 1'b1)
					next_dram_addr = dram_addr - 32'd32;
				else 
					next_dram_addr = dram_addr;
			end   
            oe_state:begin
				if(next_state == we_state)
					next_dram_addr = dram_addr + 32'd32;
				else
				next_dram_addr = dram_addr;
			end
            default: begin
				next_dram_addr = dram_addr;
			end
        endcase
    end
	
	//assign next_addr_go_back = (state == cal_state && addr_go_back == 1'b0)? 1'b1 :(state == cal_state)? addr_go_back : 1'b0;
	assign avm_m0_address = dram_addr;
	
	// avalon read write signal avm_m0_read avm_m0_write
	always@(*) begin
		if (out31_flag == 1'b1  &&  clk_25 == 1'b0)// && slow_counter == 1'b0)
			next_dram_write = 1'b1;
		else if(avm_m0_waitrequest == 1'b0)
			next_dram_write = 1'b0;
		else 
			next_dram_write = dram_write;
    end
	
	always@(*) begin
		if (state == idle_state && flag_reg == 1)
			next_dram_read = 1'b1;
		else if (state == we_state && avm_m0_waitrequest == 1'd1)// && slow_counter == 1'b0)
			next_dram_read = 1'b1;
		else if (avm_m0_readdatavalid == 1'd1)
			next_dram_read = 1'b0;
		else if (state == we_state && core_addr == 5'd31)
			next_dram_read = 1'b1;
		else
			next_dram_read = 1'b0;
    end
	assign avm_m0_read = dram_read;
	
	assign avm_m0_write = dram_write;
	assign avm_m0_writedata = temp_data_out;
	
	//-----------------rsa_core-----------------
	//core_we core_oe
	always@(*) begin
		case(state) 
			idle_state:begin
				next_core_we = 1'b0;
				next_core_oe = 1'b0;
			end    
			we_state: begin
				if(next_state == cal_state)begin
					next_core_we = 1'b0;
					next_core_oe = 1'b0;
				end
				else begin
					next_core_we = 1'b1;
					next_core_oe = 1'b0;
				end
			end      
			cal_state:begin
				next_core_we = 1'b0;
				next_core_oe = 1'b0;
			end   
			oe_state:begin
				next_core_we = 1'b0;
				next_core_oe = 1'b1;
			end
		endcase
		//else begin
		//	next_core_we = core_we;
		//	next_core_oe = core_oe;
		//end
    end
	
	//core_start
	assign next_core_start = (state == we_state && next_state == cal_state)? 1'b1 :(clk_25 == 1'b0)? core_start:1'b0;

	
	always@(*) begin
		if (state == we_state && avm_m0_readdatavalid == 1'b1) begin
			if(dram_addr == 32'd0)
				next_core_reg_sel = 2'b10;
			else if (dram_addr == 32'd32)
				next_core_reg_sel = 2'b11;
			else //(dram_addr >= 32'd96)
				next_core_reg_sel = 2'b01;
		end
		else if (state == we_state)
			next_core_reg_sel = core_reg_sel;
		else
			next_core_reg_sel = 2'b00;			
	end
	
	always@(*) begin
		if (state == we_state) begin
			if(avm_m0_readdatavalid == 1'b1)
				next_core_addr = 5'd0;
			else if(core_addr == 5'd31)
				next_core_addr = core_addr;
			else if(clk_25 == 1'b0)
				next_core_addr = core_addr +5'b1;
			else 
				next_core_addr = core_addr;
		end
		else if (state == cal_state) begin
				next_core_addr = 5'd0;		
		end
		else if (state == oe_state) begin
			if(core_addr == 5'd31)
				next_core_addr = core_addr;
			else if(clk_25 == 1'b0 && core_oe == 1'b1)
				next_core_addr = core_addr +5'b1;
			else 
				next_core_addr = core_addr;
		end
		else
			next_core_addr = core_addr;						
	end
	
	assign next_temp_data_in = (avm_m0_readdatavalid == 1'b1)? avm_m0_readdata : temp_data_in;

	assign core_data_i = temp_data_in[core_addr*8  +: 8];
	always@(*) begin
		if (state == oe_state) begin
			next_temp_data_out = temp_data_out;
			case(core_addr) 
				5'd0  : next_temp_data_out[(core_addr)*8 +: 8] = core_data_o;
				5'd1  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd2  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd3  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd4  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd5  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd6  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd7  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd8  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd9  : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd10 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd11 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd12 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd13 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd14 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd15 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd16 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd17 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd18 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd19 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd20 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd21 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd22 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd23 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd24 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd25 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd26 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd27 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd28 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd29 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd30 : next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
				5'd31 : begin
					if(out31_flag == 1'b0) begin
						next_temp_data_out[(core_addr-5'd1)*8 +: 8] = core_data_o;
						next_temp_data_out[(core_addr)*8 +: 8] = temp_data_out[(core_addr)*8 +: 8];
					end
					else begin 
						next_temp_data_out[(core_addr)*8 +: 8] = core_data_o;
						next_temp_data_out[(core_addr-5'd1)*8 +: 8] = temp_data_out[(core_addr-5'd1)*8 +: 8];
					end
				end
			endcase
		end
		else	
			next_temp_data_out = temp_data_out;
    end
	assign avm_m0_writedata = temp_data_out;
	
    rsa_core rsa1(
    .clk(clk_25), //
    .reset(reset), //
    .ready(core_ready), //
    .we(core_we),//
    .oe(core_oe),//
    .start(core_start),//
    .reg_sel(core_reg_sel),//
    .addr(core_addr),//
    .data_i(core_data_i),
    .data_o(core_data_o));
//==== sequential part =====================================  
    always@(posedge clk or posedge reset)
        if (reset == 1) begin
			state = idle_state;
			dram_addr = 32'b0;
			dram_write = 1'b0;
			dram_read = 1'b0;
			core_start = 1'b0;
			flag_reg = 1'b0;
			out31_flag = 1'b0;
			core_we = 1'b0;
			core_oe = 1'b0;
			core_start = 1'b0;
			core_reg_sel = 2'b00;
			core_addr = 5'd31;
			temp_data_in = 255'b0;
			temp_data_out= 255'b0;
        end
        else begin
			state = next_state;
			dram_addr =	next_dram_addr;
			dram_write = next_dram_write;
			dram_read = next_dram_read;
			core_start = next_core_start;
			flag_reg = next_flag_reg;
			out31_flag = next_out31_flag;
			core_we = next_core_we;
			core_oe = next_core_oe;
			core_start = next_core_start;
			core_reg_sel = next_core_reg_sel;
			core_addr = next_core_addr;
			temp_data_in = next_temp_data_in ;
			temp_data_out= next_temp_data_out;
		end
    
endmodule
