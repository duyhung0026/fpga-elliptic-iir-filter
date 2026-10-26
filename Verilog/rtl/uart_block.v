`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/14/2026 02:00:58 PM
// Design Name: 
// Module Name: uart_block
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

module uart_block(
    input  wire        clk,
    input  wire        trigger,
    input  wire [11:0] data_in,
    output wire        Tx
);

    wire Txclk_en;
    wire tx_busy;

    reg        tx_start_n = 1'b1;
    reg [7:0]  tx_data    = 8'd0;

    reg [7:0] frame [0:1];
    reg byte_idx = 1'd0;

    localparam IDLE = 2'd0;
    localparam SEND = 2'd1;
    localparam WAIT = 2'd2;

    reg [1:0] state = IDLE;

    baudrate baud_inst (
        .clk_50m  (clk),
        .Txclk_en (Txclk_en)
    );

    uart_tx tx_inst (
        .clk_50m (clk),
        .clken   (Txclk_en),
        .Tx_en   (tx_start_n),
        .data_in (tx_data),
        .Tx      (Tx),
        .Tx_busy (tx_busy)
    );

    always @(posedge clk) begin
        tx_start_n <= 1'b1;

        case (state)
            IDLE: begin
                byte_idx <= 2'd0;

                if (trigger) begin
                    //frame[0] <= 8'hAA;
                    frame[0] <= {4'b0000, data_in[11:8]};
                    frame[1] <= data_in[7:0];
                    state    <= SEND;
                end
            end

            SEND: begin
                if (!tx_busy) begin
                    tx_data    <= frame[byte_idx];
                    tx_start_n <= 1'b0;
                    state      <= WAIT;
                end
            end

            WAIT: begin
                if (!tx_busy) begin
                    if (byte_idx == 1'd1) begin
                        state <= IDLE;
                    end else begin
                        byte_idx <= byte_idx + 1'b1;
                        state    <= SEND;
                    end
                end
            end

            default: begin
                state <= IDLE;
            end
        endcase
    end

endmodule