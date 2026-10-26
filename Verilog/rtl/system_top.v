`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 02:02:02 PM
// Design Name: 
// Module Name: system_top
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


module system_top(
    input  wire        clk,
    input  wire        ADC_out,
    output wire        ADC_in,
    output wire        ADCclk,
    output wire        conv,
    output wire        Tx
);
    wire        adc_done;
    wire [11:0] adc_data;
 
    adc_block adc0(
        .clk           (clk),
        .enable        (1'b1),
        .I1            (1'b0),
        .I2            (1'b0),
        .I3            (1'b0),
        .ADC_out       (ADC_out),
        .ADCclk        (ADCclk),
        .ADC_in        (ADC_in),
        .conv          (conv),
        .done_sync     (adc_done),
        .adc_data_sync (adc_data)
    );
 
    wire [11:0] filter_data;
 
    filter_block_tdf2_cascade filter0(
        .clk      (clk),
        .enable   (adc_done),
        .data_in  (adc_data),
        .data_out (filter_data)
    );
 
    reg [1:0] dec_cnt = 2'd0;
    always @(posedge clk) begin
        if (adc_done) dec_cnt <= dec_cnt + 1;
    end
    wire uart_trigger = adc_done && (dec_cnt == 2'd0);
 
    uart_block uart0(
        .clk      (clk),
        .trigger  (uart_trigger),
        .data_in  (filter_data),
        .Tx       (Tx)
    );
 
endmodule
