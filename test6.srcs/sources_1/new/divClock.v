`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/02/2020 03:24:31 PM
// Design Name: 
// Module Name: divClock
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


module divClock(
    output divClk,
    input clk
    );
    
    reg divClk;
    
    initial
    begin
        divClk=0;
    end
    
    always @(posedge clk)
    begin
        divClk=~divClk;
    end
endmodule
