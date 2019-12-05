#include "../../defines/defines.v"

module ctrl(
    input wire      rst,
    input wire      stallreq_from_id,
    input wire      stallreq_from_ex,
    output reg[5:0] stall
);

    always @ (*) begin
        if(rst == `RstEnable) begin
            stall <= 6'b000000;    
        end else if(stallreq_from_ex == `Stop) begin
            stall <= 6'b001111;   // stall from pc to ex 
        end else if(stallreq_from_id == `Stop) begin
            stall <= 6'b000111;   // stall from pc to id
        end else begin
            stall <= 6'b000000;    
        end
    end
