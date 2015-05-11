module avalon_rsa (
    clk,
    reset,
    
	//avalon_MM_m0
	avm_m0_waitrequest,
   avm_m0_address,
   avm_m0_read,
   avm_m0_write,
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
	 input  [7:0] avm_m0_readdata;
	 output [7:0] avm_m0_writedata;//
	 
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
    reg   core_start;
    reg   [1:0] core_reg_sel;
    wire  [4:0] core_addr;
    wire  [7:0] core_data_i;
	 //-------- output --------------------------------------
    wire core_ready;
    wire [7:0] core_data_o;
	 reg  [7:0] temp_data_in;
	 wire  [7:0] next_temp_data_in;
	
	 wire  next_core_start;
	 
	 reg  [1:0] state;
	 reg  [31:0]dram_addr;
	 reg  addr_go_back;
	 reg  dram_read;
	 reg  dram_write;
	
	 reg  [1:0] next_state;
	 reg  [31:0]next_dram_addr;
	 wire next_addr_go_back;
	 reg  next_dram_write;
	
	 wire  clk_25;
	 reg	 flag_reg;
	 reg   next_flag_reg;
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
				if (dram_addr > 32'd95 && dram_addr%32 == 0)
					next_state = cal_state;
				else next_state = we_state;
			end      
            cal_state:begin
				if (core_ready == 1 && core_start == 0)
					next_state = oe_state;
				else next_state = cal_state;
            end   
            oe_state:begin
				if (dram_addr == 32'd320)
					next_state = idle_state;
				else if (dram_addr > 32'd95 && dram_addr%32 == 0)
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
				if (avm_m0_waitrequest == 1'b1)
					next_dram_addr = dram_addr;
				else if (clk_25 == 1'b1)
					next_dram_addr = dram_addr;
				else next_dram_addr = dram_addr + 32'd1;
			end      
            cal_state:begin
				if (addr_go_back == 1'b1)
					next_dram_addr = dram_addr;
				else next_dram_addr = dram_addr - 32'd33;
			end   
            oe_state:begin
				if (avm_m0_waitrequest == 1'b1)
					next_dram_addr = dram_addr;
				else if (clk_25 == 1'b1)
					next_dram_addr = dram_addr;
				else next_dram_addr = dram_addr + 32'd1;
			end
            default: begin
				next_dram_addr = dram_addr;
			end
        endcase
    end
	
	assign next_addr_go_back = (state == cal_state && addr_go_back == 1'b0)? 1'b1 :(state == cal_state)? addr_go_back : 1'b0;
	assign avm_m0_address = dram_addr;
	
	// avalon read write signal avm_m0_read avm_m0_write
	always@(*) begin
		if (state == we_state)// && slow_counter == 1'b0)
			dram_read = 1'b1;
		else dram_read = 1'b0;
    end
	assign avm_m0_read = dram_read;
	
	always@(*) begin
		if (state == oe_state)// && slow_counter == 1'b0)
			next_dram_write = 1'b1;
		else next_dram_write = 1'b0;
    end
	assign avm_m0_write = dram_write;
	assign avm_m0_writedata = core_data_o;
	
	//-----------------rsa_core-----------------
	//core_we core_oe
	always@(*) begin
        case(state) 
            idle_state:begin
				core_we = 1'b0;
				core_oe = 1'b0;
            end    
            we_state: begin
				core_we = 1'b1;
				core_oe = 1'b0;
			end      
            cal_state:begin
				core_we = 1'b0;
				core_oe = 1'b1;
			end   
            oe_state:begin
				core_we = 1'b0;
				core_oe = 1'b0;
			end
        endcase
    end
	
	//core_start
	assign next_core_start = (state == we_state && next_state == cal_state)? 1'b1 :(clk_25 == 1)? core_start : 1'b0;
	
	always@(*) begin
		if (state == we_state) begin
			if(dram_addr < 32'd32)
				core_reg_sel = 2'b10;
			else if (dram_addr > 32'd31 && dram_addr < 32'd64)
				core_reg_sel = 2'b11;
			else 
				core_reg_sel = 2'b01;
		end
		else
			core_reg_sel = 2'b01;			
	end
	assign core_addr = dram_addr[4:0];
	
	assign next_temp_data_in = (clk_25 == 1'b1)? avm_m0_readdata : temp_data_in;
	assign core_data_i = (clk_25 == 1'b0)? avm_m0_readdata : temp_data_in;
	assign avm_m0_writedata = core_data_o;
	
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
			addr_go_back = 1'b0;
			dram_write = 1'b0;
			core_start = 1'b0;
			temp_data_in = 8'b0;
        end
        else begin
			state = next_state;
			dram_addr =	next_dram_addr;
			addr_go_back = next_addr_go_back;
			dram_write = next_dram_write;
			core_start = next_core_start;
			temp_data_in = next_temp_data_in;
		end
    
endmodule
