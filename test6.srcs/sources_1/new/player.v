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
    input wire isHit,
    input wire isHeal,
    input wire clk,
    output reg [9:0] x,y,hp
    );
    
    initial
    begin
        hp = 100;
    end
    
    reg isDamaged = 0;
    reg isMended = 0;
    
    always @(posedge clk)
        begin
        x=x0;
        y=y0;
        if (direc==1 && y0>=145)
            y=y0-4;
        else if (direc==2 && x0>=225)
            x=x0-4;
        else if (direc==3 && y0<=340-8)
            y=y0+4;
        else if (direc==4 && x0<=420-8)
            x=x0+4;
            
        if(isDamaged==0 && isHit && hp>0)
        begin
            hp=hp-20;
            isDamaged = 1;
        end
        else if(isHit == 0)
            isDamaged = 0;
        
        if(isMended==0 && isHeal && hp<100)
        begin
            if(100-hp>10) hp=hp+10;
            else hp=100;
            isMended = 1;
        end
        else if(isHeal == 0)
            isMended = 0;
        end
        
endmodule
