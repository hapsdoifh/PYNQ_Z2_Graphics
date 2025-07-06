`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/21/2025 12:08:37 AM
// Design Name: 
// Module Name: Wireframe_drawer
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


module Wireframe_drawer(
    input wire clk,
//    input wire rst,
    input wire [7:0] x0, //256 bit
    input wire [7:0] y0, //256 bit
    input wire [7:0] x1, //256 bit
    input wire [7:0] y1, //256 bit
    input wire start,
    
    output wire[15:0] fb_addr,
    output wire[7:0] fb_data,
    output wire w_en    
    );
    
    function [7:0] abs;
        input signed [7:0] in_val;
        begin
            abs = (in_val >= 0) ? in_val : in_val * -1;
        end
    endfunction
    
    
    reg [1:0] state;
    
    localparam  IDLE = 2'b00,
                INIT = 2'b01,
                RUNNING = 2'b10;
                
    reg signed [7:0] dx = (x0 < x1) ? 1 : -1;
    reg signed [7:0] dy = (y0 < y1) ? 1 : -1;
    
    reg signed [7:0] delta_x;
    reg signed [7:0] delta_y;
    
    reg signed [7:0] cur_x;
    reg signed [7:0] cur_y;
    
    reg signed [7:0] current = 0;   
    
    reg write_now = 0;
    reg [7:0] pixel_color = 16'hff;
    
    assign fb_addr = {cur_x[7:0], cur_y[7:0]};
    assign fb_data = pixel_color;
    assign w_en = write_now;
       
    always @(posedge clk) begin
        case(state)
            IDLE: begin
                if(start) begin
                    state <= INIT;
                end else begin
                    write_now <= 0;
                end
            end
            
            INIT: begin
                cur_x <= x0;
                cur_y <= y0;
                delta_x <= abs($signed(x1) - $signed(x0));
                delta_y <= abs($signed(y1) - $signed(y0));
                state <= RUNNING;
            end
            
            RUNNING: begin
                write_now <= 1;
                current <= current + delta_y;
                cur_x <= cur_x + dx;
                if(current > 0) begin
                    cur_y <= cur_y + dy;
                    current <= current - delta_x;
                end
                if(cur_x == x1) begin
                    state <= IDLE;
                end
            end
       endcase
    end
    
    
endmodule

