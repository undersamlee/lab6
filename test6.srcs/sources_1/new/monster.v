`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/22/2020 03:20:59 PM
// Design Name: 
// Module Name: monster
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


module monster(
    input wire [9:0] x0,y0,
    input wire clk,
    output reg [9:0] x,y
    );
    
    reg direcX = 0; // 0->left, 1->right
    reg direcY = 0; // 0->down, 1->up
    
    always @(posedge clk)
        begin
        x=x0;
        if(y0>=340-4)
            direcY = 0;
        else if(y0<=145+4)
            direcY = 1;
        if (direcY==0)
            y=y0-4;
        else if (direcY==1)
            y=y0+4;
            
        if(x0>=420-4)
            direcX = 0;
        else if(x0<=225+4)
            direcX = 1;
        if (direcX==0)
            x=x0-1;
        else if (direcX==1)
            x=x0+1;
        end
endmodule
