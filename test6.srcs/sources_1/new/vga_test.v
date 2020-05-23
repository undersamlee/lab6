`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/11/2020 11:16:35 AM
// Design Name: 
// Module Name: vga_test
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

module vga_test
	(
		input wire clk, reset,
		input wire RsRx,
		output wire Hsync, Vsync,
		output wire [3:0] vgaRed,
		output wire [3:0] vgaGreen,
		output wire [3:0] vgaBlue,
		output wire RsTx
	);
	
	// register for Basys 2 8-bit RGB DAC {4R,4G,4B}
	reg [11:0] rgb_reg;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    reg [9:0] x_pos,y_pos;
    
    // move
    reg [2:0]direc;
    //color
    reg [1:0]color;
    //p_tick
    wire p_tick;
    //tell whether this is a new picture
    reg newpic;
    
        // instantiate vga_sync
        vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
   
        //Receiver
        wire [7:0]RxData;
        wire state;
        wire nextstate;
        receiver receiver_unit(RxData, state, nextstate, clk, 0, RsRx);
        
        //Transmitter
        reg [7:0]TxData;
        reg transmit;
        reg [15:0]counter;
        transmitter(RsTx, clk, 0, transmit, TxData);
        
        //initialize
        initial
        begin
            transmit = 0;
            counter = 0;
            direc = 0;
            color = 3;
            x_pos = 320;
            y_pos = 240;
        end
        // rgb buffer (color)
        always @(posedge p_tick, posedge reset)
        if (reset || (10000<((x-x_pos)**2)+((y-y_pos)**2)))
            rgb_reg <= 0;
        else if (color==0)
            rgb_reg <= 12'h0FF;
        else if (color==1)
            rgb_reg <= 12'hF0F;
        else if (color==2)
            rgb_reg <= 12'hFF0;
        else
            rgb_reg <= 12'hFFF;
        
        //newpic oscillator
        always @(posedge p_tick)
        if (x==0 && y==0)
            newpic=1;
        else
            newpic=0;
            
        //move
        always @(posedge newpic)
        begin
        if (direc==1 && y_pos>0)
            y_pos=y_pos-1;
        else if (direc==2 && x_pos>0)
            x_pos=x_pos-1;
        else if (direc==3 && y_pos<480)
            y_pos=y_pos+1;
        else if (direc==4 && x_pos<640)
            x_pos=x_pos+1;
        end
        
        //UART
        always @(posedge clk)
            begin
            if (newpic==1 && direc!=0) direc=0;
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin direc=1; TxData="W"; end
                "a": begin direc=2; TxData="A"; end
                "s": begin direc=3; TxData="S"; end
                "d": begin direc=4; TxData="D"; end
                "c": begin color=0; direc=0; TxData="C"; end
                "m": begin color=1; direc=0; TxData="M"; end
                "y": begin color=2; direc=0; TxData="Y"; end
                " ": begin color=3; direc=0; TxData="Z"; end
                default: begin TxData=""; end
                endcase 
                transmit = 1;
                counter = 0;
                end
            else if (transmit==1 && counter<=10415)
                counter=counter+1;
            else
                begin
                transmit = 0;
                end
            end

        // output
        assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule