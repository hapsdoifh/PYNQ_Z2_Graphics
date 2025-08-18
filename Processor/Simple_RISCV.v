module Simple_RISCV(
	input wire clk,
	input wire rst
);

endmodule

module control_unit(
	input wire [4:0] in_reg_1,
	input wire [4:0] in_reg_2,
	input wire [4:0] in_wire_reg,
	input wire [31:0] in_write_data,
	output wire [31:0] out_data_1,
	output wire [31:0] out_data_2
);

endmodule


module instruction_fetch(
	input wire [31:0] read_address,
	output wire [31:0] instruction
);
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