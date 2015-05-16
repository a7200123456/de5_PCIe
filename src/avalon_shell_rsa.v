module avalon_shell_rsa (
    clk,
    reset,
    
	//avalon_MM_to_qsys
	avm_m0_waitrequest,
	avm_m0_address,
	avm_m0_read,
	avm_m0_write,
	avm_m0_readdatavalid,
	avm_m0_readdata,
	avm_m0_writedata,
	
	//avalon_MM_to_design
	avm_design_m0_waitrequest,
    avm_design_m0_address,
    avm_design_m0_read,
    avm_design_m0_write,
	avm_design_m0_readdatavalid,
	avm_design_m0_readdata,
	avm_design_m0_writedata,
	
	//avalon_MM_s0 to qsys
	avs_s0_waitrequest,
    avs_s0_address,
    avs_s0_read,
    avs_s0_write,
	avs_s0_readdata,
	avs_s0_writedata,
	
	//avalon_MM_s0 to design
	avm_design_s0_waitrequest,
    avm_design_s0_address,
    avm_design_s0_read,
    avm_design_s0_write,
	avm_design_s0_readdata,
	avm_design_s0_writedata
);

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
	
    //-------- avalon_MM_to_design --------------------------------------
    output  avm_design_m0_waitrequest;
    input  [31:0] avm_design_m0_address; //
    input  avm_design_m0_read; //
    input  avm_design_m0_write; //
	output  avm_design_m0_readdatavalid;
	output  [255:0] avm_design_m0_readdata;
	input   [255:0] avm_design_m0_writedata;//
	 
	 //avalon_MM_s0 to qsys
	output avs_s0_waitrequest;
    input  avs_s0_address;
    input  avs_s0_read;
    input  avs_s0_write;
	output [127:0] avs_s0_readdata;
	input  [127:0] avs_s0_writedata;
	
	//avalon_MM_s0 to design
	input   avm_design_s0_waitrequest;
    output  avm_design_s0_address;
    output  avm_design_s0_read;
    output  avm_design_s0_write;
	input   [7:0] avm_design_s0_readdata;
	output  [7:0] avm_design_s0_writedata;
	
	assign avm_design_m0_waitrequest = avm_m0_waitrequest;
	assign avm_m0_address            = avm_design_m0_address; //
	assign avm_m0_read               = avm_design_m0_read; //
	assign avm_m0_write              = avm_design_m0_write; //
	assign avm_design_m0_readdatavalid = avm_m0_readdatavalid;
    assign avm_design_m0_readdata    = avm_m0_readdata;
    assign avm_m0_writedata          = avm_design_m0_writedata;//
	 
	assign avs_s0_waitrequest		= avm_design_s0_waitrequest;
   assign avm_design_s0_address	= avs_s0_address;
   assign avm_design_s0_read     = avs_s0_read;
   assign avm_design_s0_write    = avs_s0_write;
   assign avs_s0_readdata			= avm_design_s0_readdata;
	assign avm_design_s0_writedata= avs_s0_writedata[7:0];

endmodule