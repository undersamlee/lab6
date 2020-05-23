`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2020 09:23:37 PM
// Design Name: 
// Module Name: new_receiver
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


module new_receiver(
        output reg [7:0] RxData,
        input wire RsRx,
        input wire clk
    );
    
    reg [1:0]state;
    reg [8:0]RxBuffer;
    reg [3:0]ptr;
    reg [15:0]counter;
    reg bclk;
    
    initial
        begin
        state = 0;
        RxData = 8'h00;
        RxBuffer = 8'h00;
        ptr = 0;
        counter = 0;
        bclk = 0;
        end
        
    always @(posedge clk)
        begin
        counter=counter+1;
        if (counter>=5208)
            begin
            bclk = ~bclk;
            counter=1;
            end
        end    
    
    always @(posedge bclk)
        begin
        if (state==0 && RsRx==0)
            begin
            state=1;
            ptr=0;
            end
        else if (state==0)
            begin
            RxData = 8'bz;
            end
        else if (state==1)
            begin
            RxBuffer[ptr]=RsRx;
            ptr=ptr+1;
            if (ptr==9)
                begin
                ptr=0;
                RxData=RxBuffer[7:0];
                end
            end
        end
        
endmodule
