`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/08/2026 11:33:17 AM
// Design Name: 
// Module Name: baudrate
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


module baudrate #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 921600
)(
    input  wire clk_50m,
    output wire Txclk_en
);

    localparam BAUD_DIV = CLK_FREQ / BAUD_RATE;
    localparam CNT_W    = $clog2(BAUD_DIV);

    reg [CNT_W-1:0] baud_cnt = 0;

    assign Txclk_en = (baud_cnt == 0);

    always @(posedge clk_50m) begin
        if (baud_cnt == BAUD_DIV - 1)
            baud_cnt <= 0;
        else
            baud_cnt <= baud_cnt + 1'b1;
    end

endmodule
