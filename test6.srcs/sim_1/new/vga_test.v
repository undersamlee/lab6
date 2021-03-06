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
// This code is based on vga_test.v from https://embeddedthoughts.com/2016/07/29/driving-a-vga-monitor-using-an-fpga/
//////////////////////////////////////////////////////////////////////////////////

module vga_test
	(
		input wire clk, reset,
		input wire PS2Clk,
		input wire PS2Data,
		output wire Hsync, Vsync,
		output wire [3:0] vgaRed,
		output wire [3:0] vgaGreen,
		output wire [3:0] vgaBlue,
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
    wire [9:0] player_hp;
    wire [9:0] fight_x_next;
    
    reg [9:0] monHp = 400; // actual monster hp
    reg isAct = 0; // is monster acted
    reg isDamage=0;
    reg isHeal=0;
    reg isActed=0;
    reg [2:0] potionCount=4;
    reg isCounted=0;
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

        
    player p1 (player_x,player_y,direc,isDamage,isHeal,clk,player_x_next,player_y_next,player_hp);
    monster m1 (monster_x,monster_y,clk,monster_x_next,monster_y_next);
    reg [2:0] gameState = 0; // 0=home 1=choose 2=dodge 3=attackqy 4=item 5=act 6=mercy
    reg [1:0] menuSelected = 0;

    fight f1 (fight_x,clk,fight_x_next);
    
        // instantiate vga_sync
        vga_sync vga_sync_unit (.clk(clk), .reset(reset), .hsync(Hsync), .vsync(Vsync),
                                .video_on(video_on), .p_tick(p_tick), .x(x), .y(y));
   
        //Keyboard
        wire [7:0] keyData;
        Keyboard(clk, PS2Clk, PS2Data, keyData);
        
        wire isPlayer,isMonster,isHitPixel,isEndPixel;
        wire isBumpPixel,isAuPixel,isSmoothPixel,isTigerPixel,isTitlePixel,isShowPressEnterPixel;
        wire isFightPixel, isActPixel, isItemPixel, isMercyPixel;
        wire isPotionPixel0, isPotionPixel1, isPotionPixel2, isPotionPixel3;
        wire isActingPixel, isSparePixel;
        
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
            
        Pixel_On_Text2 #(.displayText("Purinut Thedwichienchai    6031046721")) showSmooth(
                clk,
                170, // text position.x (top left)
                250, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isSmoothPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
            
        Pixel_On_Text2 #(.displayText("Tanakorn Pisnupoomi        6031017521")) showTiger(
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
     
        Pixel_On_Text2 #(.displayText("Fight")) showFight(
                clk,
                140, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isFightPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
        
        Pixel_On_Text2 #(.displayText("Act")) showAct(
                clk,
                240, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isActPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
         Pixel_On_Text2 #(.displayText("Item")) showItem(
                clk,
                340, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isItemPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
            
         Pixel_On_Text2 #(.displayText("Mercy")) showMercy(
                clk,
                440, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isMercyPixel  // result, 1 if current pixel is on text, 0 otherwise
            );
         
         Pixel_On_Text2 #(.displayText("HP Potion")) showPotion0(
                clk,
                140, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isPotionPixel0  // result, 1 if current pixel is on text, 0 otherwise
            );
            
         Pixel_On_Text2 #(.displayText("HP Potion")) showPotion1(
                clk,
                240, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isPotionPixel1  // result, 1 if current pixel is on text, 0 otherwise
            ); 
            
         Pixel_On_Text2 #(.displayText("HP Potion")) showPotion2(
                clk,
                340, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isPotionPixel2  // result, 1 if current pixel is on text, 0 otherwise
            ); 
            
         Pixel_On_Text2 #(.displayText("HP Potion")) showPotion3(
                clk,
                440, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isPotionPixel3  // result, 1 if current pixel is on text, 0 otherwise
            );
            
          Pixel_On_Text2 #(.displayText("Acting")) showActing(
                clk,
                140, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isActingPixel  // result, 1 if current pixel is on text, 0 otherwise
            );  
            
          Pixel_On_Text2 #(.displayText("Spare")) showSpare(
                clk,
                140, // text position.x (top left)
                400, // text position.y (top left)
                x, // current position.x
                y, // current position.y
                isSparePixel  // result, 1 if current pixel is on text, 0 otherwise
            ); 
                   
        //initialize
        initial
        begin
            direc = 0;
            color = 3;
            player_x = 320;
            player_y = 240;
        end
        // rgb buffer (color)
        always @(posedge p_tick)
        begin
        if(gameState==0)
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
        else
        begin
            if(gameState==2 && isPlayer && player_hp>0)
                rgb_reg <= 12'hF00; //red
            else if (gameState==2 && ((215<x && x<220) || (420<x && x<425)) && 135<y && y<345) //border
                rgb_reg <= 12'hFFF; //white
            else if (gameState==2 && ((135<y && y<140) || (340<y && y<345)) && 215<x && x<425) //border
                rgb_reg <= 12'hFFF; //white
            else if(gameState==2 && isMonster && !isHit) // bullet (not monster)
                rgb_reg <= 12'hFFF; //white
            else if(gameState!=0 && 100<x && x<100+player_hp*4 && 370<y && y<380 && player_hp>0) //player_hp
                rgb_reg <= 12'hFF0; //yellow
            else if(gameState==3 && 345<y && y<355 && 318<x && x<322) // fight target
                rgb_reg <= 12'h0F0; // green
            else if(gameState==3 && 355<y && y<365 && fight_x-2<x && x<fight_x+2) // fight
                rgb_reg <= 12'hFFF; // white
            else if(gameState!=0 && 100<x && x<100+monHp && 110<y && y<130 && monHp>0) // monster hp
                rgb_reg <= 12'h0F0; // green
            else if((gameState==1 || gameState==4) && menuSelected==0 && 400<y && y<415 && 120<x && x<135)
                rgb_reg <= 12'hF00; // red
            else if((gameState==1 || gameState==4) && menuSelected==1 && 400<y && y<415 && 220<x && x<235)
                rgb_reg <= 12'hF00; // red
            else if((gameState==1 || gameState==4) && menuSelected==2 && 400<y && y<415 && 320<x && x<335)
                rgb_reg <= 12'hF00; // red
            else if((gameState==1 || gameState==4) && menuSelected==3 && 400<y && y<415 && 420<x && x<435)
                rgb_reg <= 12'hF00; // red
            else if(gameState==1 && isFightPixel)
                if (menuSelected==0) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==1 && isActPixel)
                if (menuSelected==1) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==1 && isItemPixel)
                if (menuSelected==2) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==1 && isMercyPixel)
                if (menuSelected==3) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==4 && isPotionPixel0 && potionCount>0)
                if (menuSelected==0) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==4 && isPotionPixel1 && potionCount>1)
                if (menuSelected==1) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==4 && isPotionPixel2 && potionCount>2)
                if (menuSelected==2) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==4 && isPotionPixel3 && potionCount>3)
                if (menuSelected==3) rgb_reg <= 12'hFFF; // white
                else rgb_reg <= 12'hF82; // dark orange
            else if(gameState==5 && isActingPixel)
                rgb_reg <= 12'hFFF; //white
            else if(gameState==5 && 400<y && y<415 && 120<x && x<135)
                rgb_reg <= 12'hF00; // red
            else if(gameState==6 && isSparePixel && !isActed)
                rgb_reg <= 12'hFFF; //white
            else if(gameState==6 && isSparePixel && isActed)
                rgb_reg <= 12'hFF0; //yellow
            else if(gameState==6 && 400<y && y<415 && 120<x && x<135)
                rgb_reg <= 12'hF00; // red
            else //blackground
                rgb_reg <= 12'h000; // black
        end
        end
        
        //newpic oscillator
        always @(posedge p_tick)
        begin
            if (x==0 && y==0)
            begin
                newpic <= 1;
            end
            else
                newpic <= 0;
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
        
        //Control
        always @(posedge clk)
            begin
            if (newpic==1 && direc!=0)
                begin
                direc=0;
                isDamage = 0;
                isHeal = 0;
                end
                case (keyData)
                "w": begin if(gameState==2) direc=1; end
                "a": begin if(gameState==2) direc=2;
                else if(gameState==1 || gameState==4) menuSelected=menuSelected-1;
                if(gameState==4 && menuSelected>=potionCount) menuSelected=0; end
                "s": begin if(gameState==2) direc=3; end
                "d": begin if(gameState==2) direc=4;
                else if(gameState==1 || gameState==4) menuSelected=menuSelected+1;
                if(gameState==4 && menuSelected>=potionCount) menuSelected=0; end
                10: begin //Enter
                    case (gameState)
                    0: gameState=1; //home
                    1: begin if(menuSelected==0)gameState=3;
                    else if(menuSelected==1) gameState=5;
                    else if(menuSelected==2) begin gameState=4; menuSelected=0; end //choose
                    else if(menuSelected==3) gameState=6; end
                    3: begin monHp = (fight_x > 320)? monHp-(100-fight_x+320) : monHp-(100-320+fight_x); if(monHp>400) gameState=0; else gameState=2; end //attack
                    4: if(potionCount>0) begin gameState=2; potionCount=potionCount-1; isHeal=1; end//item
                    5: begin gameState=2; isActed=1; end //act
                    6: if(isActed) gameState=0; //mercy
                    endcase
                    end
                27: begin //Esc
                    case (gameState)
                    4: gameState=1; //item
                    5: gameState=1; //act
                    6: gameState=1; //mercy
                    endcase
                    end
                endcase 
            if(isPlayer && isMonster && player_hp>0 && !isHit)
                begin
                isHit = 1;
                isDamage = 1;
                end
            if(clkS && !isCounted && gameState==2)
                begin
                xCounter = xCounter+1;
                isCounted = 1;
                end
            else if(!clkS) isCounted = 0;
            if(gameState!=2) xCounter = 0;
            if (player_hp > 100 || player_hp <= 0) gameState = 0;
            else if(gameState ==2 && xCounter>=5)
                begin
                gameState =1;
                isHit = 0;
                end
            end
 
        // output
        assign {vgaRed,vgaGreen,vgaBlue} = (video_on) ? rgb_reg : 12'b0;
endmodule