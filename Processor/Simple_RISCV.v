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
	output reg [3:0] alu_ctrl,
	output reg [2:0] mem_info, //000: byte, 001: halfword, 010: word, 100: unsigned byte, 101: unsigned halfword
);
	localparam  = R_TYPE = 7'b0110011,
				I_TYPE_1 = 7'b0010011,
				I_TYPE_2 = 7'b0000011,
				S_TYPE = 7'b0100011,
				B_TYPE = 7'b1100111,
				U_TYPE = 7'b0110111,
				J_TYPE = 7'b1101111,
				JALR = 7'b1100111;

	//I type
	wire [11:0] imm_i = in_instruction[31:20];
	//S type
	wire [11:0] imm_s1 = {in_instruction[31:25], in_instruction[11:7]};
	//B type
	wire [12:0] imm_b1 = {in_instruction[31], in_instruction[7], in_instruction[30:25], in_instruction[11:8], 1'b0};
	//U type
	wire [9:0] imm_u = {in_instruction[31:12]};
	// R-type
	wire [6:0] func7 = in_instruction[31:25];
	wire [4:0] rs2 = in_instruction[24:20];
	wire [4:0] rs1 = in_instruction[19:15];
	wire [6:0] func3 = in_instruction[14:12];
	wire [4:0] rd = in_instruction[11:7];

	wire [6:0] opcode = in_instruction[6:0];

	always @(posedge clk) begin
		case(opcode)
			R_TYPE:
				begin
					reg_write <= 1'b1;
					mem_read <= 1'b0;
					mem_write <= 1'b0;
					branch <= 1'b0;
					case(func3)
						3'b000: alu_ctrl <= (func7 == 7'b0000000) ? 4'b0010 : 4'b0110; // 0 -> add & sub
						3'b100: alu_ctrl <= 4'b0011; // 4 -> xor
						3'b110: alu_ctrl <= 4'b0001; // 6 -> or
						3'b111: alu_ctrl <= 4'b0000; // 7 -> and
						3'b001: alu_ctrl <= 4'b1000; // 1 -> sll
						3'b101: alu_ctrl <= (func7 == 7'b0000000) ? 4'b1001 : 4'b1011; // 5 -> srl & srla
						3'b010: alu_ctrl <= 4'b0111; // 2 -> slt
						3'b011: alu_ctrl <= 4'b0111; // 3 -> sltu
						default: alu_ctrl <= 4'b1111; // 0 -> NOP or undefined
					endcase
				end
			I_TYPE_1,
				begin
					reg_write <= 1'b1;
					mem_read <= 1'b1;
					mem_write <= 1'b0;
					branch <= 1'b0;
					case(func3)
						3'b000: alu_ctrl <= 4'b0010; // 0 -> add
						3'b100: alu_ctrl <= 4'b0011; // 4 -> xor
						3'b110: alu_ctrl <= 4'b0001; // 6 -> or
						3'b111: alu_ctrl <= 4'b0000; // 7 -> and
						3'b001: alu_ctrl <= 4'b1000; // 1 -> sll
						3'b101: alu_ctrl <= (func7 == 7'b0000000) ? 4'b1001 : 4'b1011; // 5 -> srl & srla
						3'b010: alu_ctrl <= 4'b0111; // 2 -> slt
						3'b011: alu_ctrl <= 4'b0111; // 3 -> sltu
						default: alu_ctrl <= 4'b1111; // 0 -> NOP or undefined
					endcase
				end
			I_TYPE_2:
				begin
					reg_write <= 1'b1;
					mem_read <= 1'b1;
					mem_write <= 1'b0;
					branch <= 1'b0;
					alu_ctrl <= 4'b0010;
					case(func3)
						3'b000: mem_info <= 3'b000; // 0 -> load byte
						3'b001: mem_info <= 3'b001; // 1 -> load halfword
						3'b010: mem_info <= 3'b010; // 2 -> load word
						3'b100: mem_info <= 3'b100; // 4 -> load unsigned byte
						3'b101: mem_info <= 3'b101; // 5 -> load unsigned halfword
						default: mem_info <= 3'b101; // NOP or undefined
					endcase
				end
			S_TYPE:
			B_TYPE:	
			U_TYPE:
			J_TYPE:
			JALR:
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

	reg [31:0] reg_array [31:0];

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
	input wire [3:0] in_alu_ctrl,
	output wire [3:0] out_alu_ctrl
);
endmodule