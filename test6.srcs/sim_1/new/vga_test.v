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
    reg [9:0] fight_x=220;
    
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
    wire [9:0] player_range,monster_range;
    wire [9:0] player_hp,monster_hp;
    wire [9:0] fight_x_next;
    
    reg [9:0] monHp = 400; // actual monster hp
    reg isAct = 0; // is monster acted
    reg isDamage=0;
    reg [1:0] gameState = 0; // 0=home 1=choose 2=dodge 3=attack
    reg [1:0] menuSelected = 0;
        
    player p1 (player_x,player_y,direc,isDamage,clk,player_x_next,player_y_next,player_range,player_hp);
    monster m1 (monster_x,monster_y,clk,monster_x_next,monster_y_next,monster_range,monster_hp);
    fight f1 (fight_x,clk,fight_x_next);
    
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
        
        wire isPlayer,isMonster,isHitPixel;
        
        reg isHit=0;
        
        
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
            //if ((player_range*player_range)>(((x-player_x)*(x-player_x))+(((y-player_y)*(y-player_y))))) //player
            if(gameState==2 && isPlayer && player_hp>0)
            //else if(player_x-player_range < x && x < player_x+player_range && player_y-player_range < y && y < player_y+player_range)
                rgb_reg <= 12'hF00; //red
            else if (gameState==2 && ((220<x && x<225) || (420<x && x<425)) && 140<y && y<345) //border
                rgb_reg <= 12'hFFF; //white
            else if (gameState==2 && ((140<y && y<145) || (340<y && y<345)) && 220<x && x<425) //border
                rgb_reg <= 12'hFFF; //white
            //else if ((monster_range*monster_range)>(((x-monster_x)*(x-monster_x))+(((y-monster_y)*(y-monster_y))))) //monster
            else if(gameState==2 && isMonster) // bullet (not monster)
            //else if(monster_x-monster_range < x && x < monster_x+monster_range && monster_y-monster_range < y && y < monster_y+monster_range)
                rgb_reg <= 12'hFFF; //white
            else if(gameState!=0 && 100<x && x<100+player_hp*4 && 370<y && y<380 && player_hp>0) //player_hp
                rgb_reg <= 12'hFF0; //yellow
            else if(isHit && isHitPixel)
                rgb_reg <= 12'hFAF;
            else if(gameState==3 && 345<y && y<355 && 318<x && x<322) // fight target
                rgb_reg <= 12'h0F0; // green
            else if(gameState==3 && 355<y && y<365 && fight_x-2<x && x<fight_x+2) // fight
                rgb_reg <= 12'hFFF; // white
            else if(gameState!=0 && 100<x && x<100+monHp && 110<y && y<130 && monHp>0) // monster hp
                rgb_reg <= 12'h0F0; // green
            else if(gameState==1 && menuSelected==0 && 400<y && y<415 && 100<x && x<115)
                rgb_reg <= 12'hF00; // red
            else if(gameState==1 && menuSelected==1 && 400<y && y<415 && 140<x && x<155)
                rgb_reg <= 12'hF00; // red
            else if(gameState==1 && menuSelected==2 && 400<y && y<415 && 180<x && x<195)
                rgb_reg <= 12'hF00; // red
            else //blackground
                rgb_reg <= 12'h000; // black
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
            
            if(isPlayer && isMonster)
                isHit <= 1;
        end
            
        //move
        always @(posedge newpic)
        begin
            if(gameState==2) begin
                player_x = player_x_next;
                player_y = player_y_next;
                monster_x = monster_x_next;
                monster_y = monster_y_next;
                end
            if(gameState==3)
                fight_x = fight_x_next;
        end
        
        //UART
        always @(posedge clk)
            begin
            if (newpic==1 && direc!=0)
                begin
                direc=0;
                isDamage = 0;
                end
            if (state==1 && nextstate==0)
                begin
                case (RxData)
                "w": begin if(gameState==2) direc=1; TxData="W"; end
                "a": begin if(gameState==2) direc=2; TxData="A"; end
                "s": begin if(gameState==2) direc=3; TxData="S"; end
                "d": begin if(gameState==2) direc=4; else if(gameState==1) menuSelected=menuSelected+1; if(menuSelected==3) menuSelected=0; TxData="D"; end
                "c": begin color=0; direc=0; TxData="C"; end
                "m": begin if(gameState==3) monHp=400; TxData="M"; end
                "y": begin gameState=gameState+1; if(gameState==4) gameState=0; TxData="Y"; end
                //monHp = (fight_x > 320)? monHp-(100-fight_x+320) : monHp-(100-320+fight_x);
                " ": begin if(gameState==3) monHp=monHp-100; TxData="Z"; end
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
            end

        // output
        assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule