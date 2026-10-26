`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/19/2026 11:42:29 PM
// Design Name: 
// Module Name: spi_master_tb
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


module spi_master_tb;
    reg clk;
    reg enable;
    reg ADC_out;
    reg I1, I2, I3;
 
    wire        conv;
    wire        done_sync;
    wire        ADC_in;
    wire        ADCclk;
    wire [11:0] adc_data_sync; 
 
    adc_block uut (
        .clk     (clk),
        .enable  (enable),
        .I1      (I1),
        .I2      (I2),
        .I3      (I3),
        .conv    (conv),
        .done_sync    (done_sync),
        .ADC_in  (ADC_in),
        .ADC_out (ADC_out),
        .ADCclk  (ADCclk),
        .adc_data_sync(adc_data_sync)   
    );
 
    initial clk = 0;
    always #5 clk = ~clk;
    task send_bit;
        input bit_val;
        begin
            @(posedge ADCclk);
            #1;
            ADC_out = bit_val;
        end
    endtask
    task send_transaction;
        input [11:0] val;
        integer i;
        begin
            repeat(8) @(negedge ADCclk);
            for (i = 11; i >= 0; i = i - 1)
                send_bit(val[i]);
            @(posedge conv);
        end
    endtask
 
    initial begin
        enable  = 0;
        ADC_out = 0;
        I1 = 1; I2 = 0; I3 = 1;
 
        #100;
        enable = 1;
        
        send_transaction(12'hABD);
        #200;
        //0x000
        send_transaction(12'h000);
        #200;
 
        //0xFFF
        send_transaction(12'hFFF);
        #200;
 
        //0xACD = 1010_1100_1101
        send_transaction(12'hACD);
        #20000;
        $finish;
    end
    initial begin
        $monitor("t=%0t enable=%b conv=%b done_sync=%b adc_data_sync=%h",
                 $time, enable, conv, done_sync, adc_data_sync);
    end
endmodule
