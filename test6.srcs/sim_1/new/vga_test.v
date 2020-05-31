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
		output wire RsTx,
		output reg dp
	);
	
	// register for Basys 2 8-bit RGB DAC {4R,4G,4B}
	reg [11:0] rgb_reg;
	
	// video status output from vga_sync to tell when to route out rgb signal to DAC
	wire video_on;

    // x and y
    wire [9:0] x, y;
    reg [9:0] player_x=320,player_y=240;
    reg [9:0] monster_x=300,monster_y=300;
    
    // move
    reg [2:0]direc=0;
    //color
    reg [1:0]color;
    //p_tick
    wire p_tick;
    //tell whether this is a new picture
    reg newpic;
    
    wire [9:0] player_x_next,player_y_next;
    wire [9:0] monster_x_next,monster_y_next;
    wire [9:0] player_hp,monster_hp;
    
    reg isDamage=0;
    wire [26:0] tclk;
    assign tclk[0] =clk;
    wire clkS;
    
    reg [2:0] xCounter =0;
    
    genvar i;
    generate for(i=0;i<26;i=i+1)
    begin
        divClock dClock(tclk[i+1],tclk[i]);
    end
    endgenerate
    
    divClock dClock(clkS,tclk[26]);

        
    player p1 (player_x,player_y,direc,isDamage,clk,player_x_next,player_y_next,player_hp);
    monster m1 (monster_x,monster_y,clk,monster_x_next,monster_y_next,monster_hp);
    
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
        
        wire isPlayer,isMonster,isHitPixel,isEndPixel;
        wire isBumpPixel,isAuPixel,isSmoothPixel,isTigerPixel,isTitlePixel,isShowPressEnterPixel;
        
        reg isHit=0,isStart=0;
        reg [1:0] scene=0;
        /*
            scene 0-> show member
            scene 1-> game //to be edited
        */
        
        
        Pixel_On_Text2 #(.displayText("*")) player_pixel(
                clk,
                player_x, // text position.x (top left)
                player_y, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isPlayer  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("+")) monster_pixel(
                clk,
                monster_x, // text position.x (top left)
                monster_y, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isMonster  // result, 1 if current pixel is on text, 0 otherwise
            );
        
        Pixel_On_Text2 #(.displayText("HIT")) hit_pixel(
                clk,
                400, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isHitPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("Dolwijit Jiradilok         6031310321")) showBump(
                clk,
                170, // text position.x (top left)
                210, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isBumpPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("Sumet Chorthongdee         6031058221")) showAu(
                clk,
                170, // text position.x (top left)
                230, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isAuPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("Purinut Thedwichienchai    60310xxx21")) showSmooth(
                clk,
                170, // text position.x (top left)
                250, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isSmoothPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
            
        Pixel_On_Text2 #(.displayText("Tanakoen Pisnupoomi        60310xxx21")) showTiger(
                clk,
                170, // text position.x (top left)
                270, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isTigerPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("UNDERSAMLEE")) showTitle(
                clk,
                260, // text position.x (top left)
                75, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isTitlePixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        Pixel_On_Text2 #(.displayText("press ENTER to start")) showPressEnter(
                clk,
                240, // text position.x (top left)
                360, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isShowPressEnterPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
        //initialize
        initial
        begin
            transmit = 0;
            counter = 0;
            direc = 0;
            color = 3;
            player_x = 320;
            player_y = 240;
        end
        // rgb buffer (color)
        always @(posedge p_tick)
        begin
        if(scene==1)
        begin
            //if ((player_range*player_range)>(((x-player_x)*(x-player_x))+(((y-player_y)*(y-player_y))))) //player
            if(isPlayer && player_hp>0)
            //else if(player_x-player_range < x && x < player_x+player_range && player_y-player_range < y && y < player_y+player_range)
                rgb_reg <= 12'hF00; //red
            else if (((220<x && x<225) || (420<x && x<425)) && 140<y && y<345) //border
                rgb_reg <= 12'hFFF; //white
            else if (((140<y && y<145) || (340<y && y<345)) && 220<x && x<425) //border
                rgb_reg <= 12'hFFF; //white
            //else if ((monster_range*monster_range)>(((x-monster_x)*(x-monster_x))+(((y-monster_y)*(y-monster_y))))) //monster
            else if(isMonster)
            //else if(monster_x-monster_range < x && x < monster_x+monster_range && monster_y-monster_range < y && y < monster_y+monster_range)
                rgb_reg <= 12'hFFF; //white
            else if(100<x && x<100+player_hp*4 && 370<y && y<380 && player_hp>0) //player_hp
                rgb_reg <= 12'hFF0; //yellow
            else if(isHit && isHitPixel)
                rgb_reg <= 12'hFAF;
            else //blackground
                rgb_reg <= 12'h000; //black
        end
        else if(scene==0)
        begin
            if(40<y && y<120 && !isTitlePixel)
                rgb_reg <= 12'hFFF;
            else if(isBumpPixel)
                rgb_reg <= 12'hFFF;
            else if(isAuPixel)
                rgb_reg <= 12'hFFF;
            else if(isSmoothPixel)
                rgb_reg <= 12'hFFF;
            else if(isTigerPixel)
                rgb_reg <= 12'hFFF;
            else if(isShowPressEnterPixel)
                rgb_reg <= {tclk[25:22],4'h7,4'hF};
            else //blackground
                rgb_reg <= 12'h000; //black
        end
        end
        
        //newpic oscillator
        always @(posedge p_tick)
        begin
            if (x==0 && y==0)
            begin
                newpic <= 1;
                if(isHit)
                    
                isHit <= 0;
            end
            else
                newpic <= 0;
            
            if(isPlayer && isMonster && player_hp>0)
                isHit <= 1;
        end
            
        //move
        always @(posedge newpic)
        begin
            player_x = player_x_next;
            player_y = player_y_next;
            monster_x = monster_x_next;
            monster_y = monster_y_next;
        end
        
        //UART
        always @(posedge clk)
            begin
            if (newpic==1 && direc!=0)
                begin
                direc=0;
                isDamage = 0;
                isStart=0;
                end
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
                "q": begin isStart=1; TxData="Z"; end
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
            if(isHit)
                isDamage = 1;
            if(scene ==0 && isStart)
                scene =1;
            else if(scene ==1 && xCounter>=5)
                scene =0;
            end
            
        always @(posedge clkS)
            begin
            if(scene==1)
                xCounter = xCounter+1;
            else
                xCounter = 0;
            end

        // output
        assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule