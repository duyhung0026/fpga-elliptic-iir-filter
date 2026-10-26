`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/20/2026 05:53:55 PM
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb;
    reg clk;
    reg trigger;
    reg [11:0] data_in;
    wire Tx;
    uart_block dut (
        .clk(clk),
        .trigger(trigger),
        .data_in(data_in),
        .Tx(Tx)
    );
    // clock 50MHz
    always #10 clk = ~clk;
    initial begin
        clk = 0;
        trigger = 0;
        data_in = 12'd0;
        #200;
        // sample 1
        data_in = 12'hABC;
        trigger = 1;
        #20;
        trigger = 0;
        // ch? UART g?i xong
        #200000;
        // sample 2
        data_in = 12'h555;
        trigger = 1;
        #20;
        trigger = 0;
        #200000;
        // sample 3
        data_in = 12'h800;
        trigger = 1;
        #20;
        trigger = 0;
        #200000;
        $stop;
    end
endmodule
