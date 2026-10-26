`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 07:38:04 PM
// Design Name: 
// Module Name: cnt
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
module cnt(
    output reg [31:0] out,
    output reg tc,
    input wire [31:0] data,
    input wire [31:0] lmt,
    input wire load,
    input wire en, 
    input wire clk,
    input wire reset
);
initial begin
    out = 32'b0;
    tc  = 1'b0;
end
always @(posedge clk) begin
    if (reset) begin
        out <= 32'b0;
        tc  <= 1'b0;
    end 
    else begin
        if (load)
            out <= data;
        else if (en)
            out <= out + 1'b1;
        if (out == lmt)
            tc <= 1'b1;
        else
            tc <= 1'b0;
    end
end
endmodule