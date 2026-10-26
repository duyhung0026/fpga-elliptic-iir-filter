`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 07:42:19 PM
// Design Name: 
// Module Name: spi_master
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
module spi_master(
    input  wire        I1,        // Channel bit D2
    input  wire        I2,        // Channel bit D1
    input  wire        I3,        // Channel bit D0
    input  wire        clk,       // ADC clock (SPI clock)
    input  wire        enable,   
    input  wire        ADC_out,   // MISO
    output reg         ADC_in,    // MOSI
    output reg         conv,      // CS (active low khi conv=0)
    output reg         done,      
    output reg [11:0]  data_out 
);
    // State encoding
    localparam S_START   = 4'd0;  //Start bit
    localparam S_SGL     = 4'd1;  // SGL/DIFF bit
    localparam S_D2      = 4'd2; 
    localparam S_D1      = 4'd3; 
    localparam S_D0      = 4'd4; 
    localparam S_WAIT    = 4'd5;  // Don't care bo qua Null bit
    localparam S_DATA    = 4'd6; 
    localparam S_DONE    = 4'd7; 
    localparam S_CSH     = 4'd8;  // Giu CS=1 it nhat 1 clock
 
    reg [3:0] state = S_START;
    reg [4:0] count = 5'd0;       // Dem so falling edge tu khi bat dau
 
    always @(negedge clk) begin
        if (!enable) begin
            state    <= S_START;
            count    <= 5'd0;
            conv     <= 1'b1;     // CS=1 (inactive)
            done     <= 1'b0;
            ADC_in   <= 1'b0;
            data_out <= 12'd0;
        end
        else begin
            case (state)
                //Falling edge 1: CS xuong, gui Start bit
                S_START: begin
                    conv     <= 1'b0;   // CS = 0 (active)
                    ADC_in   <= 1'b1;   // Start bit
                    done     <= 1'b0;
                    data_out <= 12'd0;
                    count    <= 5'd1;
                    state    <= S_SGL;
                end
 
                //Falling edge 2: Gui SGL/DIFF
                S_SGL: begin
                    ADC_in <= 1'b1;
                    count  <= 5'd2;
                    state  <= S_D2;
                end
 
                //Falling edge 3: Gui D2
                S_D2: begin
                    ADC_in <= I3;
                    count  <= 5'd3;
                    state  <= S_D1;
                end
 
                //Falling edge 4: Gui D1
                S_D1: begin
                    ADC_in <= I2;
                    count  <= 5'd4;
                    state  <= S_D0;
                end
 
                //Falling edge 5: Gui D0
                S_D0: begin
                    ADC_in <= I1;
                    count  <= 5'd5;
                    state  <= S_WAIT;
                end
            S_WAIT: begin
                ADC_in <= 1'b0;
                count  <= count + 5'd1;
                // count=5 vao: tang len 6 → don't-care clock, stay
                // count=6: tang len 7 → null bit, stay (bo qua)
                // count=7: tang len 8 → chuyen S_DATA, count=8 tai negedge tiep
                if (count == 5'd5 || count == 5'd6)
                    state <= S_WAIT;
                else
                    state <= S_DATA;   // count=7 xong bat dau count=8
            end
                S_DATA: begin
                    ADC_in <= 1'b0;
                    data_out[5'd19 - count] <= ADC_out;
                    count <= count + 5'd1;
                    if (count == 5'd19) 
                        state <= S_DONE;
                end
                S_DONE: begin
                    ADC_in <= 1'b0;
                    done   <= 1'b1;
                    count  <= 5'd0;
                    state  <= S_CSH;
                end
                //giu CS=1 it nhat 1 clock de dam bao tCSH >= 500ns
                // (voi SPI clock 1.5625MHz -> chu ky 640ns > 500ns: 1 clock la du)
                S_CSH: begin
                    conv  <= 1'b1;   // CS = 1 (inactive)
                    done  <= 1'b0;
                    state <= S_START;
                end
                default: begin
                    state <= S_START;
                    conv  <= 1'b1;
                    done  <= 1'b0;
                end
 
            endcase
        end
    end
endmodule