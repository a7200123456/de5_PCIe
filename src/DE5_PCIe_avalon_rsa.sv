`define ENABLE_DDR3A
//`define ENABLE_DDR3B
`define ENABLE_PCIE
//`define ENABLE_QDRIIA
//`define ENABLE_QDRIIB
//`define ENABLE_QDRIIC
//`define ENABLE_QDRIID
//`define ENABLE_SATA_DEVICE
//`define ENABLE_SATA_HOST
//`define ENABLE_SFPA
//`define ENABLE_SFPB
//`define ENABLE_SFPC
//`define ENABLE_SFPD
//`define ENABLE_SFP1G_REFCLK

module DE5_PCIe_avalon_rsa(
	
	input [3:0] BUTTON,
	output CLOCK_SCL,
	inout CLOCK_SDA,
	input CPU_RESET_n,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	input [3:0] SW,
	output TEMP_CLK,
	inout TEMP_DATA,
	input TEMP_INT_n,
	input TEMP_OVERT_n,
	inout FAN_CTRL,
	output FLASH_ADV_n,
	output [1:0] FLASH_CE_n,
	output FLASH_CLK,
	output FLASH_OE_n,
	input [1:0] FLASH_RDY_BSY_n,
	output FLASH_RESET_n,
	output FLASH_WE_n,
	output [26:0] FSM_A,
	inout [31:0] FSM_D,
	output [6:0] HEX0_D,
	output HEX0_DP,
	output [6:0] HEX1_D,
	output HEX1_DP,
	output [3:0] LED,
	output [3:0] LED_BRACKET,
	output LED_RJ45_L,
	output LED_RJ45_R,
	input OSC_50_B3B,
	input OSC_50_B3D,
	input OSC_50_B4A,
	input OSC_50_B4D,
	input OSC_50_B7A,
	input OSC_50_B7D,
	input OSC_50_B8A,
	input OSC_50_B8D,
	output PLL_SCL,
	inout PLL_SDA,
	output RS422_DE,
	input RS422_DIN,
	output RS422_DOUT,
	output RS422_RE_n,
	output RS422_TE,
	input RZQ_0,
	input RZQ_1,
	input RZQ_4,
	input RZQ_5
`ifdef ENABLE_DDR3A
	,
	output [15:0] DDR3A_A,
	output [2:0] DDR3A_BA,
	output DDR3A_CAS_n,
	output [0:0] DDR3A_CK,
	output [0:0] DDR3A_CKE,
	output [0:0] DDR3A_CK_n,
	output [0:0] DDR3A_CS_n,
	output [7:0] DDR3A_DM,
	inout [63:0] DDR3A_DQ,
	inout [7:0] DDR3A_DQS,
	inout [7:0] DDR3A_DQS_n,
	input DDR3A_EVENT_n,
	output [0:0] DDR3A_ODT,
	output DDR3A_RAS_n,
	output DDR3A_RESET_n,
	output DDR3A_SCL,
	inout DDR3A_SDA,
	output DDR3A_WE_n
`endif
`ifdef ENABLE_DDR3B
	,
	output [15:0] DDR3B_A,
	output [2:0] DDR3B_BA,
	output DDR3B_CAS_n,
	output [0:0] DDR3B_CK,
	output [0:0] DDR3B_CKE,
	output [0:0] DDR3B_CK_n,
	output [0:0] DDR3B_CS_n,
	output [7:0] DDR3B_DM,
	inout [63:0] DDR3B_DQ,
	inout [7:0] DDR3B_DQS,
	inout [7:0] DDR3B_DQS_n,
	input DDR3B_EVENT_n,
	output [0:0] DDR3B_ODT,
	output DDR3B_RAS_n,
	output DDR3B_RESET_n,
	output DDR3B_SCL,
	inout DDR3B_SDA,
	output DDR3B_WE_n
`endif
`ifdef ENABLE_PCIE
	,
	input PCIE_PERST_n,
	input PCIE_REFCLK_p,
	input [7:0] PCIE_RX_p,
	input PCIE_SMBCLK,
	inout PCIE_SMBDAT,
	output [7:0] PCIE_TX_p,
	output PCIE_WAKE_n
`endif
`ifdef ENABLE_QDRIIA
	,
	output [20:0] QDRIIA_A,
	output [1:0] QDRIIA_BWS_n,
	input QDRIIA_CQ_n,
	input QDRIIA_CQ_p,
	output [17:0] QDRIIA_D,
	output QDRIIA_DOFF_n,
	output QDRIIA_K_n,
	output QDRIIA_K_p,
	output QDRIIA_ODT,
	input [17:0] QDRIIA_Q,
	input QDRIIA_QVLD,
	output QDRIIA_RPS_n,
	output QDRIIA_WPS_n
`endif
`ifdef ENABLE_QDRIIB
	,
	output [20:0] QDRIIB_A,
	output [1:0] QDRIIB_BWS_n,
	input QDRIIB_CQ_n,
	input QDRIIB_CQ_p,
	output [17:0] QDRIIB_D,
	output QDRIIB_DOFF_n,
	output QDRIIB_K_n,
	output QDRIIB_K_p,
	output QDRIIB_ODT,
	input [17:0] QDRIIB_Q,
	input QDRIIB_QVLD,
	output QDRIIB_RPS_n,
	output QDRIIB_WPS_n
`endif
`ifdef ENABLE_QDRIIC
	,
	output [20:0] QDRIIC_A,
	output [1:0] QDRIIC_BWS_n,
	input QDRIIC_CQ_n,
	input QDRIIC_CQ_p,
	output [17:0] QDRIIC_D,
	output QDRIIC_DOFF_n,
	output QDRIIC_K_n,
	output QDRIIC_K_p,
	output QDRIIC_ODT,
	input [17:0] QDRIIC_Q,
	input QDRIIC_QVLD,
	output QDRIIC_RPS_n,
	output QDRIIC_WPS_n
`endif
`ifdef ENABLE_QDRIID
	,
	output [20:0] QDRIID_A,
	output [1:0] QDRIID_BWS_n,
	input QDRIID_CQ_n,
	input QDRIID_CQ_p,
	output [17:0] QDRIID_D,
	output QDRIID_DOFF_n,
	output QDRIID_K_n,
	output QDRIID_K_p,
	output QDRIID_ODT,
	input [17:0] QDRIID_Q,
	input QDRIID_QVLD,
	output QDRIID_RPS_n,
	output QDRIID_WPS_n
`endif
`ifdef ENABLE_SATA_DEVICE
	,
	input [1:0] SATA_DEVICE_RX_p,
	output [1:0] SATA_DEVICE_TX_p,
	input SATA_DEVICE_REFCLK_p
`endif
`ifdef ENABLE_SATA_HOST
	,
	input [1:0] SATA_HOST_RX_p,
	output [1:0] SATA_HOST_TX_p,
	input SATA_HOST_REFCLK_p
`endif
`ifdef ENABLE_SFPA
	,
	input SFP_REFCLK_p
`elsif ENABLE_SFPB
	input SFP_REFCLK_p
`elsif ENABLE_SFPC
	input SFP_REFCLK_p
`elsif ENABLE_SFPD
	input SFP_REFCLK_p
`endif
`ifdef ENABLE_SFP1G_REFCLK
	,
	input SFP1G_REFCLK_p
`endif
`ifdef ENABLE_SFPA
	,
	input SFPA_LOS,
	input SFPA_MOD0_PRSNT_n,
	output SFPA_MOD1_SCL,
	inout SFPA_MOD2_SDA,
	output [1:0] SFPA_RATESEL,
	input SFPA_RX_p,
	output SFPA_TXDISABLE,
	input SFPA_TXFAULT,
	output SFPA_TX_p
`endif
`ifdef ENABLE_SFPB
	,
	input SFPB_LOS,
	input SFPB_MOD0_PRSNT_n,
	output SFPB_MOD1_SCL,
	inout SFPB_MOD2_SDA,
	output [1:0] SFPB_RATESEL,
	input SFPB_RX_p,
	output SFPB_TXDISABLE,
	input SFPB_TXFAULT,
	output SFPB_TX_p
`endif
`ifdef ENABLE_SFPC
	,
	input SFPC_LOS,
	input SFPC_MOD0_PRSNT_n,
	output SFPC_MOD1_SCL,
	inout SFPC_MOD2_SDA,
	output [1:0] SFPC_RATESEL,
	input SFPC_RX_p,
	output SFPC_TXDISABLE,
	input SFPC_TXFAULT,
	output SFPC_TX_p
`endif
`ifdef ENABLE_SFPD
	,
	input SFPD_LOS,
	input SFPD_MOD0_PRSNT_n,
	output SFPD_MOD1_SCL,
	inout SFPD_MOD2_SDA,
	output [1:0] SFPD_RATESEL,
	input SFPD_RX_p,
	output SFPD_TXDISABLE,
	input SFPD_TXFAULT,
	output SFPD_TX_p
`endif
);

wire        rsa_desgin_waitrequest;
wire [31:0] rsa_design_address;        
wire        rsa_design_read;              
wire [7:0]  rsa_design_readdata;      
wire        rsa_design_write;            
wire [7:0]  rsa_design_writedata;    

//avalon_MM_s0 => flag register
wire rsa_reg_waitrequest;
wire rsa_reg_address;
wire rsa_reg_read;
wire rsa_reg_write;
wire [7:0] rsa_reg_readdata;
wire [7:0] rsa_reg_writedata;

assign DDR3A_A[15:14] = 0;

PCIe_rsa the_system(
	.reset_0_reset_n(CPU_RESET_n),
	.clk_0_clk(OSC_50_B8A),
	
	//RSA
	.avalon_shell_rsa_0_m0_address_address(rsa_design_address),         //     avalon_shell_rsa_0_m0_address.address
	.avalon_shell_rsa_0_m0_read_read(rsa_design_read),               //        avalon_shell_rsa_0_m0_read.read
	.avalon_shell_rsa_0_m0_readdata_readdata(rsa_design_readdata),       //    avalon_shell_rsa_0_m0_readdata.readdata
	.avalon_shell_rsa_0_m0_waitrequest_waitrequest(rsa_desgin_waitrequest), // avalon_shell_rsa_0_m0_waitrequest.waitrequest
	.avalon_shell_rsa_0_m0_write_write(rsa_design_write),             //       avalon_shell_rsa_0_m0_write.write
	.avalon_shell_rsa_0_m0_writedata_writedata(rsa_design_writedata),     //   avalon_shell_rsa_0_m0_writedata.writedata
	.avalon_shell_rsa_0_s0_address_address(rsa_reg_address),         //     avalon_shell_rsa_0_s0_address.address
	.avalon_shell_rsa_0_s0_read_read(rsa_reg_read),               //        avalon_shell_rsa_0_s0_read.read
	.avalon_shell_rsa_0_s0_readdata_readdata(rsa_design_readdata),     //    avalon_shell_rsa_0_s0_readdata.readdata
	.avalon_shell_rsa_0_s0_waitrequest_waitrequest(rsa_reg_waitrequest), // avalon_shell_rsa_0_s0_waitrequest.waitrequest
	.avalon_shell_rsa_0_s0_write_write(rsa_reg_write),             //       avalon_shell_rsa_0_s0_write.write
	.avalon_shell_rsa_0_s0_writedata_writedata(rsa_reg_writedata),    //   avalon_shell_rsa_0_s0_writedata.writedata
	
	// DDR3a, many signals only connect to [0], but I don't know why
	// ddr3a_status_local_init_done,
	// ddr3a_status_local_cal_success,
	// ddr3a_status_local_cal_fail,
	.ddr3a_mem_a(DDR3A_A[13:0]),
	.ddr3a_mem_ba(DDR3A_BA),
	.ddr3a_mem_ck(DDR3A_CK[0]),
	.ddr3a_mem_ck_n(DDR3A_CK_n[0]),
	.ddr3a_mem_cke(DDR3A_CKE[0]),
	.ddr3a_mem_cs_n(DDR3A_CS_n[0]),
	.ddr3a_mem_dm(DDR3A_DM),
	.ddr3a_mem_ras_n(DDR3A_RAS_n),
	.ddr3a_mem_cas_n(DDR3A_CAS_n),
	.ddr3a_mem_we_n(DDR3A_WE_n),
	.ddr3a_mem_reset_n(DDR3A_RESET_n),
	.ddr3a_mem_dq(DDR3A_DQ),
	.ddr3a_mem_dqs(DDR3A_DQS),
	.ddr3a_mem_dqs_n(DDR3A_DQS_n),
	.ddr3a_mem_odt(DDR3A_ODT[0]),
	.ddr3a_oct_rzqin(RZQ_5), // I don't know why...

	.pcie_interface_hip_serial_rx_in0(PCIE_RX_p[0]),
	.pcie_interface_hip_serial_rx_in1(PCIE_RX_p[1]),
	.pcie_interface_hip_serial_rx_in2(PCIE_RX_p[2]),
	.pcie_interface_hip_serial_rx_in3(PCIE_RX_p[3]),
	.pcie_interface_hip_serial_rx_in4(PCIE_RX_p[4]),
	.pcie_interface_hip_serial_rx_in5(PCIE_RX_p[5]),
	.pcie_interface_hip_serial_rx_in6(PCIE_RX_p[6]),
	.pcie_interface_hip_serial_rx_in7(PCIE_RX_p[7]),
	.pcie_interface_hip_serial_tx_out0(PCIE_TX_p[0]),
	.pcie_interface_hip_serial_tx_out1(PCIE_TX_p[1]),
	.pcie_interface_hip_serial_tx_out2(PCIE_TX_p[2]),
	.pcie_interface_hip_serial_tx_out3(PCIE_TX_p[3]),
	.pcie_interface_hip_serial_tx_out4(PCIE_TX_p[4]),
	.pcie_interface_hip_serial_tx_out5(PCIE_TX_p[5]),
	.pcie_interface_hip_serial_tx_out6(PCIE_TX_p[6]),
	.pcie_interface_hip_serial_tx_out7(PCIE_TX_p[7]),
	.pcie_interface_npor_npor(1'b1),
	.pcie_interface_npor_pin_perst(PCIE_PERST_n),
	.pcie_interface_refclk_clk(PCIE_REFCLK_p)
);

avalon_rsa avalon_rsa_1(
   .clk(OSC_50_B8A),
   .reset(CPU_RESET_n),
    
	//avalon_MM
	.avm_m0_waitrequest(rsa_desgin_waitrequest),
   .avm_m0_address	 (rsa_design_address),
   .avm_m0_read		 (rsa_design_read),
   .avm_m0_write		 (rsa_design_write),
	.avm_m0_readdata	 (rsa_design_readdata),
	.avm_m0_writedata  (rsa_design_writedata),
	
	//avalon_MM_s0 => flag register
	.avs_s0_waitrequest(rsa_reg_waitrequest),
   .avs_s0_address(rsa_reg_address),
   .avs_s0_read(rsa_reg_read),
   .avs_s0_write(rsa_reg_write),
	.avs_s0_readdata(rsa_reg_readdata),
	.avs_s0_writedata(rsa_reg_writedata)    
);
endmodule 
