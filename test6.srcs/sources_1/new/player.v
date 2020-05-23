`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2020 03:04:23 PM
// Design Name: 
// Module Name: player
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


module player(
    input wire [9:0] x0,y0,
    input wire [2:0] direc,
    input wire clk,
    output reg [9:0] x,y,r,hp
    );
    
    initial
    begin
        r = 7;
        hp = 100;
    end
    
    always @(posedge clk)
        begin
        x=x0;
        y=y0;
        if (direc==1 && y0>=145+r+4)
            y=y0-4;
        else if (direc==2 && x0>=225+r+4)
            x=x0-4;
        else if (direc==3 && y0<=340-r-4)
            y=y0+4;
        else if (direc==4 && x0<=420-r-4)
            x=x0+4;
        end
    
endmodule
