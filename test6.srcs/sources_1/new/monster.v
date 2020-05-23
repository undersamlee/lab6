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
    output reg [9:0] x,y,r,hp
    );
    
    initial
    begin
        r = 7;
        hp = 100;
    end
    
    reg direc = 0; // 0->down, 1->up
    
    always @(posedge clk)
        begin
        x=x0;
        if(y0>=340-4)
            direc = 0;
        else if(y0<=145+4)
            direc = 1;
        if (direc==0)
            y=y0;
        else if (direc==1)
            y=y0;
        end
endmodule
