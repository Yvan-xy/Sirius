`include "defines.v"
module div(
    input wire       rst,
    input wire       clk,

    input wire       signed_div_i,
    input wire[31:0] opdata1_i,
    input wire[31:0] opdata2_i,
    input wire       start_i,
    input wire       annul_i,

    output reg[63:0] result_o,
    output reg       ready_o
);
    
    wire[32:0]  div_temp;
    reg [5:0]   cnt;
    reg [64:0]  dividend;
    reg [1:0]   state;
    reg [31:0]  divisor;
    reg [31:0]  temp_op1;
    reg [31:0]  temp_op2;

    assign div_temp = {1'b0, dividend[63:32]} - {1'b0, divisor};

    always @ (posedge clk) begin
        if(rst == `RstEnable) begin
            state       <=  `DivFree;
            ready_o     <=  `DivResultNotReady;
            result_o    <=  {`ZeroWord,`ZeroWord};
        end else begin

            case (state)

                /*
                * DivFree State
                * There are three situations:
                *   1) divisor == 0, then state change to DivByZero
                *
                *   2) divsior != 0, then state change to DivOn. Initialize
                *   cnt to 0. If signed_div_i == 1 and the dividend or divisor are
                *   negative, then obtain the their complements.
                *   
                *   3) The division is start. Keep the "ready_o
                *   = `DivResultNotReady" and "result_o = 0"
                */

                `DivFree: begin                                 // state == `DivFree
                    if(start_i == `DivStart && annul_i == 1'b0) begin

                        if(opdata2_i == `ZeroWord) begin
                            state   <=  `DivByZero;             // divisor is zero
                        end else begin
                            state   <=  `DivOn;                 // divisor isn't zero
                            cnt     <=  6'b000000;
                            if(signed_div_i == 1'b1 && opdata1_i[31] == 1'b1) begin
                                temp_op1 = ~opdata1_i + 1;      // get complement of divisor
                            end else begin
                                temp_op1 = opdata1_i;    
                            end
                            if(signed_div_i == 1'b1 && opdata2_i[31] == 1'b1) begin
                                temp_op2 = ~opdata2_i + 1;      // get complement of divisor
                            end else begin
                                temp_op2 = opdata2_i;    
                            end
                            dividend        <=  {`ZeroWord, `ZeroWord};
                            dividend[32:1]  <=  temp_op1;
                            divisor         <=  temp_op2;
                        end

                    end else begin                              // Division do not start
                        ready_o  <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                    end
                end

                /*
                * DivByZero State
                * 
                * If state change to `DivByZero then go to DivEnd straightly. 
                */

                `DivByZero: begin
                    dividend <= {`ZeroWord, `ZeroWord};
                    state    <= `DivEnd;
                end

                /*
                * DivOn State
                * There are three situations:
                *   1) If annul_i == 1, then cancel the division. And the
                *   state change to the DivFree state straightly.
                *
                *   2) If annul_i == 0 and cnt != 32, it stands for the
                *   divison is not over. At present, if div_temp is
                *   negative, then the result of this iteration is 0. If
                *   div_temp is positive, then the result of this iteration is
                *   1. The lowest bit of dividend save the results of
                *   iteration. Keep the state == `DivOn and let cnt + 1.
                *   
                *   3) If annul_i == 0 and cnt == 32, it stands the division
                *   is over. If signed_div_i == 1 and dividend and the divisor
                *   have the different signed, obtain the complement of the
                *   result. Quotient and the remainder both need to obtain
                *   complements. dividend[31:0] = quotient and
                *   dividend[63:32] = remainder. State go to DivEnd at the
                *   same time.
                *
                */
                
               `DivOn: begin
                    if(annul_i == 1'b0) begin
                        if(cnt != 6'b100000) begin
                            if(div_temp[32] == 1'b1) begin
                                
                                /*
                                * If div_temp[32] == 1, it stands for that
                                * minuend - n is negative.
                                *
                                * Shift the dividend once. The the dividend
                                * secondarily highest will join the next
                                * iteration. Add 0 to the middle result. 
                                *
                                */

                                dividend <= {dividend[63:0], 1'b0};
                            end else begin
                                
                                /*
                                * If div_temp[32] == 0, it stands for minuend
                                * - n is positive.
                                *   
                                * Then add the difference and the secondarily
                                * highes bit to the next iteration. 
                                * Add 1 to the middle result.
                                *
                                */

                                dividend <= {div_temp[31:0], dividend[31:0], 1'b1};
                            end
                            cnt <= cnt +1;
                        end else begin      // Division is over
                            if((signed_div_i == 1'b1) &&
                               (opdata1_i[31] ^ opdata2_i[31])) begin
                                dividend[31:0]  <= ~dividend[31:0] + 1;
                            end   
                            if((signed_div_i == 1'b1) &&
                               (opdata1_i[31] ^ dividend[64])) begin
                                dividend[64:33] <= ~dividend[64:33] +1;   
                            end
                            state <= `DivEnd;
                            cnt   <= 6'b000000;
                        end
                    end else begin
                        state <= `DivFree;  // If annul_i == 1, go back to DivFree straightly    
                    end   
                end

                /*
                * DivEnd State
                * result_o is 64 bits Width.
                * The high 32 bits save the result of remainder. The low 32
                * bits save the result of quotient.
                * 
                * Set ready_o to DivResultReady to indicate the end of
                * division. And wait the DivStop signal from EX Module. Then
                * div go back to DivFree state. 
                *
                */

                `DivEnd: begin
                    ready_o      <= `DivResultReady;
                    result_o     <= {dividend[64:33], dividend[31:0]};
                    if(start_i == `DivStop) begin
                        state    <= `DivFree;
                        ready_o  <= `DivResultNotReady;
                        result_o <= {`ZeroWord, `ZeroWord};
                    end
                end
            endcase
        end
    end

endmodule



































