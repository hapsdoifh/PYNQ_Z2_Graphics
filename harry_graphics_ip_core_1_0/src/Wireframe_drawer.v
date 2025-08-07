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
    input wire [15:0] x0, //256 bit
    input wire [15:0] y0, //256 bit
    input wire [15:0] x1, //256 bit
    input wire [15:0] y1, //256 bit
    input wire start,
    
    output wire[31:0] fb_addr,
    output wire[15:0] fb_data,
    output wire w_en,
    output wire [31:0] debug_info,
    
    input wire [1:0] axi_master_state,
    input wire axi_master_writes_done
    );
    
    function [15:0] abs;
        input signed [15:0] in_val;
        begin
            abs = (in_val >= 0) ? in_val : in_val * -1;
        end
    endfunction
    
    reg [2:1] ticks_to_hold = 0;
    
    localparam  IDLE = 2'b00,
                INIT = 2'b01,
                RUNNING = 2'b10,
                FINISHED = 2'b11;
                
    reg [1:0] state = IDLE;
    reg [1:0] draw_state = IDLE;
                
    reg signed [15:0] dx;
    reg signed [15:0] dy;
    
    reg signed [15:0] delta_x = 0;
    reg signed [15:0] delta_y = 0;
    
    reg signed [15:0] cur_x = 0;
    reg signed [15:0] cur_y = 0;
    
    reg signed [15:0] current;   
    
    reg write_now = 0;
    reg [31:0] pixel_color = 32'hffffffff;
    reg start_latch = 0;
    
    reg [15:0] aliased_x0;
    reg [15:0] aliased_y0;
    reg [15:0] aliased_x1;
    reg [15:0] aliased_y1;
    reg signed [15:0] aliased_delta_x;
    reg signed [15:0] aliased_delta_y;
    
    reg write_latch = 0; 
    
    assign fb_addr = (delta_x > delta_y) ? {cur_x, cur_y} : {cur_y, cur_x};
    assign fb_data = 16'hffff;
    assign w_en = write_now;
//    assign debug_info[15:8] = aliased_delta_x;
//    assign debug_info[15:0] = aliased_delta_y;
//    assign debug_info[23:16] = current;
    assign debug_info = 0;
       
    always @(posedge clk) begin
        case(state)
            IDLE: begin
                if(start & start_latch) begin //latch is 1 (ready) and start is 1 (start)
                    state <= INIT;
                    start_latch <= 0;
                
                    aliased_x0 <= (delta_x > delta_y) ? x0 : y0;
                    aliased_x1 <= (delta_x > delta_y) ? x1 : y1;
                    aliased_y0 <= (delta_x > delta_y) ? y0 : x0;
                    aliased_y1 <= (delta_x > delta_y) ? y1 : x1;
                    aliased_delta_x <= (delta_x > delta_y) ? delta_x : delta_y;
                    aliased_delta_y <= (delta_x > delta_y) ? delta_y : delta_x;
                end
                else if(start == 0) begin //latch is 0/1 -> start becomes 0 to reset latch to 1
                    state <= IDLE;  
                    start_latch <= 1;               
                end
                else begin //latch is 0 (not ready) -> already triggered waiting for reset
                    state <= IDLE;
                    start_latch <= 0;
                end
                delta_x <= abs($signed(x1) - $signed(x0));
                delta_y <= abs($signed(y1) - $signed(y0));
            end
            
            INIT: begin
//                cur_x <= x0;
//                cur_y <= y0;
//                dx <= (x0 < x1) ? 1 : -1;
//                dy <= (y0 < y1) ? 1 : -1;
                cur_x <= aliased_x0;
                cur_y <= aliased_y0;
                dx <= (aliased_x0 < aliased_x1) ? 1 : -1;
                dy <= (aliased_y0 < aliased_y1) ? 1 : -1;
                current <= 0;
                state <= RUNNING;
                draw_state <= IDLE;
                ticks_to_hold <= 0;
            end
            
            RUNNING: begin
                if(draw_state == IDLE) begin
                    if(axi_master_state == IDLE) draw_state <= INIT;
                    else draw_state <= IDLE;                
                    write_latch <= 0;
                end
                else if(draw_state == INIT) begin
                    if(current >= 0) begin
                        cur_y <= cur_y + dy;
                        current <= current - aliased_delta_x + aliased_delta_y;
                    end
                    else begin
                        cur_y <= cur_y;
                        current <= current + aliased_delta_y;
                    end
                    cur_x <= cur_x + dx;
                    draw_state <= RUNNING;
                    write_now <= 1;
                    ticks_to_hold <= 0;
                end
                else if(draw_state == RUNNING) begin
                    if(ticks_to_hold < 3) begin
                        draw_state <= RUNNING;
                        ticks_to_hold <= ticks_to_hold + 1;
                    end
                    else begin
                        write_now <= 0;
                        draw_state <= FINISHED;
                    end
                end 
                else begin
                    write_latch <= write_latch || axi_master_writes_done;
                    if(write_latch) begin
                        if(cur_x == aliased_x1)  begin
                            state <= IDLE;
                        end
                        else begin
                            state <= RUNNING;
                        end
                        draw_state <= IDLE;
                    end
                    else draw_state <= FINISHED;
                end
                
             end
       endcase
    end
    
    
endmodule

