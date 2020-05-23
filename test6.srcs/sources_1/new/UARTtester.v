`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/12/2020 09:02:50 PM
// Design Name: 
// Module Name: UARTtester
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


module UARTtester(
        input wire clk,
        input wire RsRx,
        output wire RsTx
    );
    
        wire [7:0]RxData;
        wire state;
        wire nextstate;
        receiver receiver_unit(RxData, state, nextstate, clk, 0, RsRx);
        //receiver new_receiver(RxData, RsRx, clk);
    
        reg [7:0]TxData;
        reg transmit;
        reg [15:0]counter;
        transmitter(RsTx, clk, 0, transmit, TxData);
        
        initial
            begin
            transmit = 0;
            counter = 0;
            end  
            
        always @(posedge clk)
            begin
            if (state==1 && nextstate==0)
                begin
                TxData = RxData;
                transmit = 1;
                counter = 0;
                end
            else if (transmit==1 && counter<=10415)
                counter=counter+1;
            else
                transmit = 0;
            end
endmodule
