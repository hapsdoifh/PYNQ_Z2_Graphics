module Simple_RISCV(
	input wire clk,
	input wire rst
);
	wire [31:0] instruction;
	wire [31:0] read_data_1;
	wire [31:0] read_data_2;

	instruction_fetch IF_inst(
		.clk(clk), 
		.read_address(32'b0), 
		.instruction(instruction)
	);

	control_unit CU_inst(
		.in_reg_1(instruction[19:15]), 
		.in_reg_2(instruction[24:20]), 
		.in_write_reg(instruction[11:7]), 
		.in_write_data(instruction), 
		.out_data_1(read_data_1), 
		.out_data_2(read_data_2)
	);

endmodule

module control_unit(
	input wire clk,
	input wire [3:0] in_instruction
	output reg reg_write,
	output reg mem_read,
	output reg mem_write,
	output reg branch,
	output reg [3:0] alu_op,
);
	localparam  = R_TYPE = 7'b0110011,
				I_TYPE_1 = 7'b0000011,
				I_TYPE_2 = 7'b0010011,
				S_TYPE = 7'b0100011,
				B_TYPE = 7'b1100111,
				U_TYPE = 7'b0110111,
				J_TYPE = 7'b1101111;
	wire [6:0] opcode = in_instruction[6:0];
	always @(posedge clk) begin
		case(opcode)
			R_TYPE:
			I_TYPE_1,
			I_TYPE_2:
			S_TYPE:
			B_TYPE:	
			U_TYPE:
			J_TYPE:
			default:
		endcase
	end
endmodule


module instruction_fetch(
	input wire clk,
	input wire [31:0] read_address,
	output reg [31:0] instruction
);

	(* ramstyle = "M9K" *) reg [31:0] mem [1024:0];
	initial begin
		$readmemh("instructions.hex", mem);
	end
	
	//log2(1024) = 10
	wire [9:0] read_addr = read_address[11:2];

	always @(posedge clk) instruction <= mem[read_addr];
endmodule


module register_file(
	input wire [4:0] in_read_reg_1,
	input wire [4:0] in_read_reg_2,
	input wire [4:0] in_write_reg,
	input wire [31:0] in_write_data,
	output wire [31:0] out_read_data_1,
	output wire [31:0] out_read_data_2	
);

endmodule 


module ALU(
	input wire [31:0] in_data_1,
	input wire [31:0] in_data_2,
	input wire [3:0] in_alu_ctrl,
	output wire out_zero,
	output wire [31:0] out_alu_result
);
endmodule

module memory_write(
	input wire in_zero,
	input wire [31:0] in_address,
	input wire [31:0] in_write_data,
	input wire [31:0] out_read_data
);
endmodule

module imm_gen(
	input wire [31:0] in_data,
	output wire [31:0] out_data
);
endmodule

module alu_control(
	input wire [3:0] in_instruction,
	input wire [3:0] in_alu_op,
	output wire [3:0] out_alu_ctrl
);
endmodule