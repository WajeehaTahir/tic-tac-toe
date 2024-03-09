// VGA CODE IS DEVELOPED BY COLTON_BEERY: https://github.com/ColtonBeery/Basys3_VGA_Testbench
// FOR TESTING THE ALGORITHM: https://cledersonbc.github.io/tic-tac-toe-minimax/

`default_nettype none

module top(
    input wire clk,                // board clock: 100 MHz on Arty/Basys3/Nexys
    input wire IO_BTN_C,           // reset button
    input wire [3:0] IO_SWITCH,    // switches for selecting the position (0000b - 1000b)
    output wire VGA_Hsync,         // horizontal sync output
    output wire VGA_Vsync,         // vertical sync output
    input wire btn,
    output reg [2:0] VGA_Red,      // 4-bit VGA red output
    output reg [2:0] VGA_Green,    // 4-bit VGA green output
    output reg [1:0] VGA_Blue,     // 4-bit VGA blue output
    output reg [2:0] led
);

wire rst;
button reset(clk, IO_BTN_C, rst);
reg [15:0] cnt;
reg pix_stb;

always @(posedge clk)
    if(rst)
        cnt <= 0;
    else
        {pix_stb, cnt} <= cnt + 16'h4000;  // divide by 4: (2^16)/4 = 0x4000

wire [9:0] x;  // current pixel x position: 10-bit value: 0-1023
wire [8:0] y;  // current pixel y position:  9-bit value: 0-511
wire animate;  // high when we're ready to animate at end of drawing

localparam SCREENSIZE_X = 640; //Number of X pixels in the screen
localparam SCREENSIZE_Y = 480; //Number of Y pixels in the screen

vga640x480 display (
    .i_clk(clk),            // base clock
    .i_pix_stb(pix_stb),    // pixel clock strobe
    .i_rst(rst),            // reset: restarts frame
    .o_hs(VGA_Hsync),       // horizontal sync
    .o_vs(VGA_Vsync),       // vertical sync
    .o_x(x),                // current pixel x position
    .o_y(y),                // current pixel y position
    .o_animate(animate)     // high for one tick at end of active drawing
);

//**
// begin commenting here 

wire [11:0] sq_a_x1, sq_a_x2, sq_a_y1, sq_a_y2;  // 12-bit values: 0-4095 
square #(.IX(160), .IY(120), .H_SIZE(60)) sq_a_anim ( // start
    .i_clk(clk),            // base clock
    .i_ani_stb(pix_stb),    // animation clock: pixel clock is 1 pix/frame
    .i_rst(rst),            // reset: returns animation to starting position
    .i_animate(animate),    // animate when input is high
    .o_x1(sq_a_x1),         // square left edge: 12-bit value: 0-4095
    .o_x2(sq_a_x2),         // square right edge
    .o_y1(sq_a_y1),         // square top edge
    .o_y2(sq_a_y2)          // square bottom edge
);

reg [22:0] prod1, prod2; 
reg [9:0] offsetx;
reg [9:0] offsety;
reg [17:0] board; 
wire btn_o;
reg [1:0] result;
reg [3:0] AIpos;
button b0(clk, btn, btn_o); //Reset button
reg [3:0] i;

initial begin 
    led = 0;
    result = 0;
    board = 18'd0;
end

always @(posedge clk) begin
    VGA_Red <= 0;
    VGA_Green <= 0;
    VGA_Blue <= 0;

    if(rst) begin
        board = 18'd0;
        led = 0;
        result = 0;
    end

    if(btn_o == 1 && result == 0) begin
        if (!board[IO_SWITCH * 2 + 1 -: 2]) begin
            board[IO_SWITCH * 2 + 1 -: 2] = 1; // User plays square
            #100 AIpos = findmove(board);
            board[AIpos * 2 + 1 -: 2] = 2;     // AI plays with circle
        end
    end 

    result = eval(board);
    if (result == 1) led[0] = 1;
    if (result == 2) led[1] = 1;
    if (result == 3) led[2] = 1;

    if (((x > 199) & (x < 219)) || ((x > 419) & (x < 439))) begin
        VGA_Red <= 7;
        VGA_Green <= 7;
        VGA_Blue <= 3; 
    end // white

    if (((y > 144) & (y < 164)) || ((y > 364) & (y < 384))) begin
        VGA_Red <= 7;
        VGA_Green <= 7;
        VGA_Blue <= 3; 
    end // white

    for (i = 0; i < 9; i = i + 1) begin
        offsetx = 220 * (i % 3);
        offsety = 190 * (i / 3);

        if (board[i * 2 + 1 -: 2] == 1) begin
            if ((x > 49 + offsetx & x < 149 + offsetx) & (y > 22 + offsety & y < 122 + offsety)) begin
                VGA_Red <= 7;
                VGA_Green <= 0;
                VGA_Blue <= 0;
            end
        end

        if (board[i * 2 + 1 -: 2] == 2) begin
            offsetx = 220 * (i % 3);
            offsety = 190 * (i / 3);
            prod1 = (x - 100 - offsetx) * (x - 100 - offsetx) + (y - 72 - offsety) * (y - 72 - offsety); 
            
            if ((prod1 < 2500)) begin // 100^2 + 100^2                    
                VGA_Red <= 7;
                VGA_Green <= 0;
                VGA_Blue <= 0; 
            end // redish circle
        end                
    end
end  

function automatic [1:0] eval;
    // Evaluate the state of the board 
    // 00 => Game not over
    // 01 => Game over player 1 won
    // 10 => Game over player 2 won
    // 11 => Game over game drawn 
    input [17:0] board ; 
    reg [1:0] result;
    reg [3:0] i;
    begin
        result = 0;
        if (!result) result = board[0 * 2 + 1 -: 2] & board[1 * 2 + 1 -: 2] & board[2 * 2 + 1 -: 2];
        if (!result) result = board[3 * 2 + 1 -: 2] & board[4 * 2 + 1 -: 2] & board[5 * 2 + 1 -: 2];
        if (!result) result = board[6 * 2 + 1 -: 2] & board[7 * 2 + 1 -: 2] & board[8 * 2 + 1 -: 2];
    // vertical
        if (!result) result = board[0 * 2 + 1 -: 2] & board[3 * 2 + 1 -: 2] &board[6 * 2 + 1 -: 2];
        if (!result) result = board[1 * 2 + 1 -: 2] & board[4 * 2 + 1 -: 2] &board[7 * 2 + 1 -: 2];
        if (!result) result = board[2 * 2 + 1 -: 2] & board[5 * 2 + 1 -: 2] &board[8 * 2 + 1 -: 2];
    // diagonal
        if (!result) result = board[0 * 2 + 1 -: 2] & board[4 * 2 + 1 -: 2] &board[8 * 2 + 1 -: 2];
        if (!result) result = board[6 * 2 + 1 -: 2] & board[4 * 2 + 1 -: 2] &board[2 * 2 + 1 -: 2];
    //check for draw
        if (!result) begin
            result = 3;
            for (i = 0; i < 9; i = i + 1) begin
                if (board[i * 2 + 1 -: 2] == 0) result = 0;
            end        
        end
        eval = result;
    end
endfunction

function automatic [3:0] findmove;
    // Find the best move (Recursive function setup)
    input [17:0] board; 
    reg signed [3:0] bestvalue, newvalue;
    reg [3:0] bestmove;
    reg [3:0] i;
    begin    
        bestvalue = -2;
        for (i = 0; i < 9; i = i + 1) begin
            if (board[i * 2 + 1 -: 2] == 0) begin 
                board[i * 2 + 1 -: 2] = 2;
                newvalue = findmoveRecursive(board, 1, 1, -2, 2);
                board[i * 2 + 1 -: 2] = 0;
                if (newvalue > bestvalue) begin
                    bestvalue = newvalue;
                    bestmove = i;
                end
            end
        end 
        findmove = bestmove;
    end
endfunction

function automatic signed[3:0] findmoveRecursive;
    // Find the best move recursively (MiniMax Tree Search)
    input [17:0] board; 
    input turn;
    input [3:0]  depth;
    input signed [3:0]  alpha, beta; 
    reg   signed [3:0]  bestvalue, newvalue;
    reg [3:0] i;
    reg [1:0] result;
    begin    
        result = eval(board);
        // MINIMIZE CASE
        if (result == 0 & depth < 2) begin                
            if (turn == 1) begin
                bestvalue = 2;
                for (i = 0; i < 9; i = i + 1) begin
                    if (board[i * 2 + 1 -: 2] == 0) begin     
                            board[i * 2 + 1 -: 2] = 1;
                            newvalue = findmoveRecursive(board, 2, depth + 1, alpha, beta);
                            board[i * 2 + 1 -: 2] = 0;
                            if (newvalue < bestvalue) bestvalue = newvalue;
                    end 
                end
            end
            
            // MAXIMIZE CASE
            if (turn == 2) begin
              bestvalue = -2;
              for (i = 0; i < 9; i = i + 1) begin
                 if (board[i * 2 + 1 -: 2] == 0) begin 
                    board[i * 2 + 1 -: 2] = 2;
                    newvalue = findmoveRecursive(board, 1, depth + 1, alpha, beta);
                    board[i * 2 + 1 -: 2] = 0;
                    if (newvalue > bestvalue) bestvalue = newvalue;
                    end 
                end 
            end
        end
        
        // BASE CASE
        else if (result == 1)  bestvalue = -1; 
        else if (result == 2)  bestvalue = 1; 
        else  bestvalue = 0;
        findmoveRecursive = bestvalue;
    end
endfunction
endmodule

module button(input wire clk, in, output wire out);
    // Pushbutton debouncer 
    reg r1, r2, r3;
    initial begin 
    end

    always @(posedge clk)
    begin
        r1 <= in;
        r2 <= r1;
        r3 <= r2;
    end

    assign out = ~r3 & r2;

endmodule
