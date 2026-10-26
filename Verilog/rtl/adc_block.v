`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 01:56:49 PM
// Design Name: 
// Module Name: adc_block
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


module adc_block(
    input  wire        clk,  
    input  wire        enable,
    input  wire        I1,
    input  wire        I2,
    input  wire        I3,
    input  wire        ADC_out,
 
    output wire        ADCclk,
    output wire        ADC_in,
    output wire        conv,
    output wire        done_sync,
    output reg  [11:0] adc_data_sync
);
    wire [31:0] cnt_out;
    wire        tc;
    cnt counter(
        .out   (cnt_out),
        .data  (32'b0),
        .load  (tc),
        .en    (enable),
        .clk   (clk),
        .reset (1'b0),
        .tc    (tc),
        .lmt   (32'hFFFFFFFF)
    );
    assign ADCclk = cnt_out[5];
    wire        done_raw;
    wire [11:0] data_raw;
 
    spi_master m1(
        .I1       (I1),
        .I2       (I2),
        .I3       (I3),
        .clk      (ADCclk),
        .enable   (enable),
        .ADC_out  (ADC_out),
        .ADC_in   (ADC_in),
        .conv     (conv),
        .done     (done_raw),
        .data_out (data_raw)
    );
    wire [11:0] data_latched;
 
    ffd m2(
        .a     (data_raw),
        .clk   (ADCclk),
        .en    (done_raw),
        .reset (1'b0),
        .y     (data_latched)
    );
reg done_ff1 = 1'b0;
reg done_ff2 = 1'b0;
    reg done_ff3 = 1'b0;
 
    always @(posedge clk) begin
        done_ff1 <= done_raw;
        done_ff2 <= done_ff1;
        done_ff3 <= done_ff2;
    end
    assign done_sync = done_ff2 & ~done_ff3;
    always @(posedge clk) begin
        if (done_sync)
            adc_data_sync <= data_latched;
    end
 
endmodule
