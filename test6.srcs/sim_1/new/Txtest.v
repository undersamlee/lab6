`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 04:30:35 PM
// Design Name: 
// Module Name: Txtest
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


module Txtest(

    );
    
    reg clk;
    reg [7:0]TxData;
    wire RsTx;
    transmitter tnsmttr(RsTx, clk, 0, 1, TxData);
    
initial
    begin
    clk=0;
    TxData=8'b000000000;
    #10415 TxData=8'b00101101;
    #10415 TxData=8'b00000000;
    #10415 $finish;
    end

always
    #5 clk = ~clk;
endmodule
