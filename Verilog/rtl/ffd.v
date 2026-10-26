`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2026 07:30:25 PM
// Design Name: 
// Module Name: ffd
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

module fdce1(    
input wire d,
input wire clk,
input wire ce,
input wire reset,
output reg q);

initial begin 
q=0; 
end
always @ (posedge clk) begin
if (reset)
  q <= 1'b0;
 else if (ce)
  q <= d;
end
endmodule

module ffd(
input wire [11:0] a,
input wire clk,en,reset,
output wire [11:0] y);
fdce1 d1(.q(y[0]),.clk(clk),.ce(en),.reset(reset),.d(a[0]));
fdce1 d2(.q(y[1]),.clk(clk),.ce(en),.reset(reset),.d(a[1]));
fdce1 d3(.q(y[2]),.clk(clk),.ce(en),.reset(reset),.d(a[2]));
fdce1 d4(.q(y[3]),.clk(clk),.ce(en),.reset(reset),.d(a[3]));
fdce1 d5(.q(y[4]),.clk(clk),.ce(en),.reset(reset),.d(a[4]));
fdce1 d6(.q(y[5]),.clk(clk),.ce(en),.reset(reset),.d(a[5]));
fdce1 d7(.q(y[6]),.clk(clk),.ce(en),.reset(reset),.d(a[6]));
fdce1 d8(.q(y[7]),.clk(clk),.ce(en),.reset(reset),.d(a[7]));
fdce1 d9(.q(y[8]),.clk(clk),.ce(en),.reset(reset),.d(a[8]));
fdce1 d10(.q(y[9]),.clk(clk),.ce(en),.reset(reset),.d(a[9]));
fdce1 d11(.q(y[10]),.clk(clk),.ce(en),.reset(reset),.d(a[10]));
fdce1 d12(.q(y[11]),.clk(clk),.ce(en),.reset(reset),.d(a[11]));
endmodule
