//`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/13/2021 10:19:00 AM
// Design Name: 
// Module Name: TopTop
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


module TopTop #(parameter[15:0] DIM = 16'h0505, parameter MAX_WORD_LENGTH = 32)
(
    input clk,
    input reset,
    input start,
    // input[5:0] LENGTH,
    input[31:0] instruction,
    input external,
    input[7:0] Tile_i,
    input[7:0] Tile_j,
    input[7:0] Block_i,
    input[7:0] Block_j,
    input WEA,
    input WEB,
    input[9:0] ADDRA,
    input[9:0] ADDRB,
    input[15:0] DIA,
    input[15:0] DIB,
    output[15:0] DOA,
    output[15:0] DOB,
    input[1:0] Activation_Function,
    input Tanh_In
    
//    output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] debug_EAST_O,
//    output[0:ARRAY_DIM*TILE_DIM*8-1] debug_EOUT,
//    output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] debug_NORTH_I,
//    output[0:ARRAY_DIM*TILE_DIM*8-1] debug_NIN,
//    output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] debug_EAST_I,
//    output[0:ARRAY_DIM*TILE_DIM*8-1] debug_EIN,
//    output[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] debug_NORTH_O,
//    output[0:ARRAY_DIM*TILE_DIM*8-1] debug_NOUT,
//    output west_debug_in_mode_1,
//    output west_debug_in_mode_2,
//    output east_debug_in_mode_1,
//    output east_debug_in_mode_2,
//    output north_debug_in_mode_1,
//    output north_debug_in_mode_2,
//    output south_debug_in_mode_1,
//    output south_debug_in_mode_2
    );

parameter[7:0] ARRAY_DIM = DIM[15:8];
parameter[7:0] TILE_DIM = DIM[7:0];

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] EAST_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] WEST_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SOUTH_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] NORTH_I;

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SIG_O;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] TANH_O;

wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] SIG_I;
wire[0:4*ARRAY_DIM*TILE_DIM*MAX_WORD_LENGTH-1] TANH_I;  

wire [0:4*ARRAY_DIM*TILE_DIM-1] Ready_Sig;
wire [0:4*ARRAY_DIM*TILE_DIM-1] Ready_Tanh;

Top #({ARRAY_DIM,TILE_DIM}, MAX_WORD_LENGTH) top
    (
        clk,
        reset,
        start,
        instruction,
        external,
        Tile_i,
        Tile_j,
        Block_i,
        Block_j,
        WEA,
        WEB,
        ADDRA,
        ADDRB,
        DIA,
        DIB,
        DOA,
        DOB,
        EAST_I,
        WEST_I,
        SOUTH_I,
        NORTH_I,
        EAST_O,
        WEST_O,
        SOUTH_O,
        NORTH_O
        
//        debug_EAST_O,
//        debug_EOUT,
//        debug_NORTH_I,
//        debug_NIN,
//        debug_EAST_I,
//        debug_EIN,
//        debug_NORTH_O,
//        debug_NOUT,
//        west_debug_in_mode_1,
//        west_debug_in_mode_2,
//        east_debug_in_mode_1,
//        east_debug_in_mode_2,
//        north_debug_in_mode_1,
//        north_debug_in_mode_2,
//        south_debug_in_mode_1,
//        south_debug_in_mode_2
    );


assign SIG_I = EAST_O;
Sigmoid_Array #(MAX_WORD_LENGTH, 4*ARRAY_DIM*TILE_DIM) sig
    (
        clk,
        SIG_I,
        SIG_O,
        Ready_Sig //debug:
    );
assign TANH_I = Tanh_In == 0? EAST_O : NORTH_O;
Tanh_Array #(MAX_WORD_LENGTH, 4*ARRAY_DIM*TILE_DIM) tanh
    (
        clk,
        TANH_I,
        TANH_O,
        Ready_Tanh //debug:
    );

assign WEST_I = 0;
assign EAST_I = 0;
assign SOUTH_I = 0;
assign NORTH_I = Activation_Function == 0? EAST_O : (Activation_Function == 1 && Ready_Sig[0] == 1'b1)? SIG_O : (Activation_Function == 2 && Ready_Tanh[0] == 1'b1)? TANH_O : 'hz;

//debug: tryting to remove AF from the middle
//assign NORTH_I = EAST_O; //debug: tryting to remove AF from the middle

endmodule
