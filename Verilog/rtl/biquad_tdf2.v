`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 02:51:24 PM
// Design Name: 
// Module Name: biquad_tdf2
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


module biquad_tdf2 #(
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

    reg signed [ACC_W-1:0] d1 = {ACC_W{1'b0}};
    reg signed [ACC_W-1:0] d2 = {ACC_W{1'b0}};

    wire signed [ACC_W-1:0] x_b0 = x_in_q28 * B0;
    wire signed [ACC_W-1:0] x_b1 = x_in_q28 * B1;
    wire signed [ACC_W-1:0] x_b2 = x_in_q28 * B2;

    wire signed [ACC_W-1:0] y_acc;
    assign y_acc = x_b0 + d1;

    assign y_out_q28 = y_acc >>> FRAC;

    wire signed [ACC_W-1:0] y_a1 = y_out_q28 * A1;
    wire signed [ACC_W-1:0] y_a2 = y_out_q28 * A2;

    wire signed [ACC_W-1:0] d1_next;
    wire signed [ACC_W-1:0] d2_next;

    assign d1_next = x_b1 + d2 - y_a1;
    assign d2_next = x_b2      - y_a2;

    always @(posedge clk) begin
        if (enable) begin
            d1 <= d1_next;
            d2 <= d2_next;
        end
    end

endmodule
