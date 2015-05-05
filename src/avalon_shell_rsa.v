module avalon_shell_rsa (
    clk,
    reset,
    
	//avalon_MM_to_qsys
	avm_m0_waitrequest,
    avm_m0_address,
    avm_m0_read,
    avm_m0_write,
	avm_m0_readdata,
	avm_m0_writedata,
	
	//avalon_MM_to_design
	avm_design_waitrequest,
    avm_design_address,
    avm_design_read,
    avm_design_write,
	avm_design_readdata,
	avm_design_writedata
);

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
	
    //-------- avalon_MM_to_design --------------------------------------
    output  avm_design_waitrequest;
    input  [31:0] avm_design_address; //
    input  avm_design_read; //
    input  avm_design_write; //
	output  [7:0] avm_design_readdata;
	input  [7:0] avm_design_writedata;//
	
	assign avm_design_waitrequest = avm_m0_waitrequest;
	assign avm_m0_address         = avm_design_address; //
	assign avm_m0_read            = avm_design_read; //
	assign avm_m0_write           = avm_design_write; //
    assign avm_design_readdata    = avm_m0_readdata;
    assign avm_m0_writedata       = avm_design_writedata;//

endmodule