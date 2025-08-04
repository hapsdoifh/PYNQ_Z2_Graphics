`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/27/2025 06:51:30 PM
// Design Name: 
// Module Name: testbench1
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module testbench1(

//    );
//endmodule

//Step 2 - Import two required packages: axi_vip_pkg and <component_name>_pkg.
import axi_vip_pkg::*;
import Graphics_Testing_Design_axi_vip_0_0_pkg ::*;
import Graphics_Testing_Design_axi_vip_1_0_pkg ::*;
//////////////////////////////////////////////////////////////////////////////////
// Test Bench Signals
//////////////////////////////////////////////////////////////////////////////////
// Clock and Reset
bit aclk = 0, aresetn = 1;
//Simulation output
bit led_1, switch_1;
//AXI4-Lite signals
xil_axi_resp_t 	resp;
bit[31:0]  addr, data, base_addr = 32'h4400_0000, switch_state;

module testbench1( );

Graphics_Testing_Design_wrapper UUT
(
    .aclk_0               (aclk),
    .aresetn_0            (aresetn),
    .m00_axi_init_axi_txn_0           (switch_1)
);

// Generate the clock : 50 MHz    
always #10ns aclk = ~aclk;

//////////////////////////////////////////////////////////////////////////////////
// Main Process
//////////////////////////////////////////////////////////////////////////////////
//
initial begin
    //Assert the reset
    aresetn = 0;
    #340ns
    // Release the reset
    aresetn = 1;
end
//
//////////////////////////////////////////////////////////////////////////////////
// The following part controls the AXI VIP. 
//It follows the "Usefull Coding Guidelines and Examples" section from PG267
//////////////////////////////////////////////////////////////////////////////////
//
// Step 3 - Declare the agent for the master VIP
Graphics_Testing_Design_axi_vip_1_0_mst_t     master_agent;
Graphics_Testing_Design_axi_vip_0_0_slv_mem_t     slave_agent;
//Graphics_Testing_Design_axi_vip_0_0_slv_t     slave_agent;
//
initial begin    

    // Step 4 - Create a new agent
    master_agent = new("master vip agent",UUT.Graphics_Testing_Design_i.axi_vip_1.inst.IF);
    slave_agent = new("slave vip agent",UUT.Graphics_Testing_Design_i.axi_vip_0.inst.IF);
    // Step 5 - Start the agent
    master_agent.start_master();
    slave_agent.start_slave();
    
    //Wait for the reset to be released
    wait (aresetn == 1'b1);
	#200ns
	
    
//    Send 0x1 to the AXI GPIO Data register 1
    #500ns
    addr = 0;
    data = 1;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    
    
    
    
    //Send 0x0 to the AXI GPIO Data register 1
//	#200ns
//    addr = 0;
//    data = 0;
//    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    
    // Switch in OFF position
//    switch_1 = 0;
    // Read the AXI GPIO Data register 2
//	#200ns
//    addr = 8;
//    master_agent.AXI4LITE_READ_BURST(base_addr + addr,0,data,resp);
//    switch_state = data&1'h1;
    // Switch in ON position
//	switch_1 = 1;
	// Read the AXI GPIO Data register 2
//	#200ns
//    addr = 8;
//    master_agent.AXI4LITE_READ_BURST(base_addr + addr,0,data,resp);
//    switch_state = data&1'h1;
    #200ns
    addr = 16;
    data = 32'h10000000;
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    switch_state = data&1'h1;
    
	#200ns
    addr = 12;
    data = 5 + (1 << 9);
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    switch_state = data&1'h1;
    
	#200ns
    addr = 12;
    data = data + (1<<8);
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    switch_state = data&1'h1;
    
    #200ns
    addr = 12;
    data = 5 + (1 << 8);
    master_agent.AXI4LITE_WRITE_BURST(base_addr + addr,0,data,resp);
    switch_state = data&1'h1;
    
end
//
//////////////////////////////////////////////////////////////////////////////////
// Simulation output processes
//////////////////////////////////////////////////////////////////////////////////
//
always @(posedge led_1)
begin
     $display("led 1 ON");
end

always @(negedge led_1)
begin
     $display("led 1 OFF");
end
endmodule
