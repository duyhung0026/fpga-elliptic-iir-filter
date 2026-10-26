`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/17/2026 01:15:55 PM
// Design Name: 
// Module Name: filter_block_df1
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


module filter_block_df1(
    input  wire        clk,
    input  wire        enable,
    input  wire [11:0] data_in,
    output wire [11:0] data_out
);

    localparam integer FRAC     = 28;
    localparam integer SAMPLE_W = 52;
    localparam integer ACC_W    = 84;
    localparam [8:0] WARMUP_SAMPLES = 9'd256;

    localparam signed [31:0] S1_B0 =  32'sd2838627;
    localparam signed [31:0] S1_B1 = -32'sd4619415;
    localparam signed [31:0] S1_B2 =  32'sd2838627;
    localparam signed [31:0] S1_A1 = -32'sd514298356;
    localparam signed [31:0] S1_A2 =  32'sd246932988;

    wire signed [12:0] x_center_int;
    wire signed [SAMPLE_W-1:0] x_q28;

    assign x_center_int = $signed({1'b0, data_in}) - 13'sd2048;
    assign x_q28 = {{(SAMPLE_W-13){x_center_int[12]}}, x_center_int} <<< FRAC;

    wire signed [SAMPLE_W-1:0] s1_out_q28;

    biquad_df1 #(
        .FRAC(FRAC), .SAMPLE_W(SAMPLE_W), .ACC_W(ACC_W),
        .B0(S1_B0), .B1(S1_B1), .B2(S1_B2),
        .A1(S1_A1), .A2(S1_A2)
    ) stage1 (
        .clk(clk),
        .enable(enable),
        .x_in_q28(x_q28),
        .y_out_q28(s1_out_q28)
    );

    reg [8:0] warmup_cnt = 9'd0;
    reg warmup_done = 1'b0;

    always @(posedge clk) begin
        if (enable) begin
            if (!warmup_done) begin
                if (warmup_cnt >= WARMUP_SAMPLES)
                    warmup_done <= 1'b1;
                else
                    warmup_cnt <= warmup_cnt + 1'b1;
            end
        end
    end

    wire signed [SAMPLE_W-1:0] y_center_int_q;
    wire signed [63:0] y_center_int;
    wire signed [63:0] y_unsigned_int;
    wire [11:0] y_clamped;

    assign y_center_int_q = s1_out_q28 >>> FRAC;
    assign y_center_int = {{(64-SAMPLE_W){y_center_int_q[SAMPLE_W-1]}}, y_center_int_q};
    assign y_unsigned_int = y_center_int + 64'sd2048;

    assign y_clamped = (y_unsigned_int < 64'sd0)    ? 12'd0 :
                       (y_unsigned_int > 64'sd4095) ? 12'd4095 :
                                                       y_unsigned_int[11:0];

    assign data_out = (!warmup_done) ? 12'd2048 : y_clamped;

endmodule
