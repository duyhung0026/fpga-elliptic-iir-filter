`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 01:25:35 PM
// Design Name: 
// Module Name: biquad_df1
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


module biquad_df1 #(
    parameter integer FRAC     = 28,
    parameter integer SAMPLE_W = 52,
    parameter integer ACC_W    = 84,

    parameter signed [31:0] B0 = 32'sd0,
    parameter signed [31:0] B1 = 32'sd0,
    parameter signed [31:0] B2 = 32'sd0,
    parameter signed [31:0] A1 = 32'sd0,
    parameter signed [31:0] A2 = 32'sd0
)(
    input  wire                       clk,
    input  wire                       enable,
    input  wire signed [SAMPLE_W-1:0] x_in_q28,
    output wire signed [SAMPLE_W-1:0] y_out_q28
);

    reg signed [SAMPLE_W-1:0] xz1 = {SAMPLE_W{1'b0}};
    reg signed [SAMPLE_W-1:0] xz2 = {SAMPLE_W{1'b0}};
    reg signed [SAMPLE_W-1:0] yz1 = {SAMPLE_W{1'b0}};
    reg signed [SAMPLE_W-1:0] yz2 = {SAMPLE_W{1'b0}};

    wire signed [ACC_W-1:0] pb0 = x_in_q28 * B0;
    wire signed [ACC_W-1:0] pb1 = xz1      * B1;
    wire signed [ACC_W-1:0] pb2 = xz2      * B2;
    wire signed [ACC_W-1:0] pa1 = yz1      * A1;
    wire signed [ACC_W-1:0] pa2 = yz2      * A2;

    wire signed [ACC_W-1:0] sum;
    assign sum = pb0 + pb1 + pb2 - pa1 - pa2;

    assign y_out_q28 = sum >>> FRAC;

    always @(posedge clk) begin
        if (enable) begin
            xz2 <= xz1;
            xz1 <= x_in_q28;

            yz2 <= yz1;
            yz1 <= y_out_q28;
        end
    end

endmodule
