`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 31.05.2020 16:08:00
// Design Name: 
// Module Name: fight
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


module fight(
    input wire [9:0] x0,
    input wire clk,
    output reg [9:0] x
    );
    
    reg direc = 1; // 0 = left, 1 = right
    
    always @(posedge clk)
        begin
            if (direc==1 && x0<420)
                x = x0 + 4;
            else if (direc==1 && x0>=420)
                direc = 0;
            else if (direc==0 && x0>220)
                x = x0 - 4;
            else if (direc==0 && x0<=220)
                direc = 1;
        end
endmodule
