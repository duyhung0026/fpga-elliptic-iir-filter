`timescale 1ns / 1ps

module uart_tx(
    input  wire       clk_50m,
    input  wire       clken,      // xung enable theo baudrate
    input  wire       Tx_en,      // active low: 0 = b?t ??u g?i
    input  wire [7:0] data_in,

    output reg        Tx = 1'b1,
    output wire       Tx_busy
);

    localparam TX_IDLE  = 2'd0;
    localparam TX_START = 2'd1;
    localparam TX_DATA  = 2'd2;
    localparam TX_STOP  = 2'd3;

    reg [1:0] state    = TX_IDLE;
    reg [7:0] data_reg = 8'd0;
    reg [2:0] bit_pos  = 3'd0;

    always @(posedge clk_50m) begin
        case (state)
            TX_IDLE: begin
                Tx <= 1'b1;

                if (~Tx_en) begin
                    data_reg <= data_in;
                    bit_pos  <= 3'd0;
                    state    <= TX_START;
                end
            end

            TX_START: begin
                if (clken) begin
                    Tx    <= 1'b0;
                    state <= TX_DATA;
                end
            end

            TX_DATA: begin
                if (clken) begin
                    Tx <= data_reg[bit_pos];

                    if (bit_pos == 3'd7)
                        state <= TX_STOP;

                    bit_pos <= bit_pos + 1'b1;
                end
            end

            TX_STOP: begin
                if (clken) begin
                    Tx    <= 1'b1;
                    state <= TX_IDLE;
                end
            end

            default: begin
                Tx    <= 1'b1;
                state <= TX_IDLE;
            end
        endcase
    end

    assign Tx_busy = (state != TX_IDLE);

endmodule
