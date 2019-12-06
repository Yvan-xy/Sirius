`include "defines.v"
module ex(
    input wire                  rst,

    // Data from id_ex register
    input wire[`AluOpBus]       aluop_i,
    input wire[`AluSelBus]      alusel_i,
    input wire[`RegBus]         reg1_i,
    input wire[`RegBus]         reg2_i,
    input wire[`RegAddrBus]     wd_i,
    input wire                  wreg_i,

    // Data of HI and LO
    input wire[`RegBus]         hi_i,
    input wire[`RegBus]         lo_i,

    // Enable signal of write HILO from WRITEBACK stage
    input wire[`RegBus]         wb_hi_i,
    input wire[`RegBus]         wb_lo_i,
    input wire                  wb_whilo_i,

    // Enable signal of write HILO from MEMROY stage
    input wire[`RegBus]         mem_hi_i,       // value of HI to write
    input wire[`RegBus]         mem_lo_i,       // value of LO to write
    input wire                  mem_whilo_i,    // Write Enable signal

    // Data from ex_mem
    input wire[`DoubleRegBus]   hilo_temp_i,
    input wire[1:0]             cnt_i,

    // Data to ex_mem of mult-arithmetic
    output reg[`DoubleRegBus]   hilo_temp_o,
    output reg[1:0]             cnt_o,

    // Stall request
    output reg                  stallreq,

    // Request of writeing to HI and LO
    output reg[`RegBus]         hi_o,           // value of HI to write
    output reg[`RegBus]         lo_o,           // value of LO to write
    output reg                  whilo_o,        // Write Enable signal

    // Execute result
    output reg[`RegBus]         wdata_o,
    output reg[`RegAddrBus]     wd_o,
    output reg                  wreg_o

); 

    // The result of logic operation
    reg[`RegBus] logicout;
    
    // The result of shift operation 
    reg[`RegBus] shiftres;

    // The result of move operation
    reg[`RegBus] moveres;

    // Lastest value of HILO
    reg[`RegBus] HI;
    reg[`RegBus] LO;

    // 
    wire                    ov_sum;             // Save the state of overflow
    wire                    reg1_eq_reg2;       // If reg1 == reg2
    wire                    reg1_lt_reg2;       // If reg1 < reg2 
    reg [`RegBus]           arithmeticres;      // Save the result of arithmetic
    wire[`RegBus]           reg2_i_mux;         // Save the complement code of reg2_i
    wire[`RegBus]           reg1_i_not;         // Save ~reg1_i
    wire[`RegBus]           result_sum;         // Save the result of "add" operation
    wire[`RegBus]           opdata1_mult;       // Multipilicand in "Multiply" operation
    wire[`RegBus]           opdata2_mult;       // Multipilier in "Multiply" operation
    wire[`RegBus]           hilo_temp;          // Save temp result
    reg [`DoubleRegBus]     hilo_temp1;         // Save temp result of the second cycle
    reg [`DoubleRegBus]     mulres;             // Result of "Multiply" operation 
    reg                     stallreq_for_madd_msub;

    always @ (*) begin
        stallreq <= stallreq_for_madd_msub;    
    end

    /****    Fetch the lastest value of HILO   ****/
    always @ (*) begin
        if(rst == `RstEnable) begin
            {HI, LO} <= {`ZeroWord, `ZeroWord};    
        end else if(mem_whilo_i == `WriteEnable) begin
            {HI, LO} <= {mem_hi_i, mem_lo_i};    
        end else if (wb_whilo_i == `WriteEnable) begin
            {HI, LO} <= {wb_hi_i, wb_lo_i};    
        end else begin
            {HI, LO} <= {hi_i, lo_i};    
        end
    end

    /****    According to 'aluop_i',execute 'or' operation    ****/
    always @ (*) begin
        if(rst == `RstEnable) begin
            logicout <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_OR_OP: begin
                    logicout <= reg1_i | reg2_i;
                end
                `EXE_AND_OP: begin
                    logicout <= reg1_i & reg2_i;
                end
                `EXE_NOR_OP: begin
                    logicout <= ~(reg1_i | reg2_i);
                end
                `EXE_XOR_OP: begin
                    logicout <= reg1_i ^ reg2_i;
                end
                default: begin
                    logicout <= `ZeroWord;
                end
            endcase
        end
    end

    /****   Shift Operation   ****/
    always @ (*) begin
        if(rst == `RstEnable) begin
            shiftres <= `ZeroWord;
        end else begin
            case (aluop_i)
                `EXE_SLL_OP: begin
                    shiftres <= reg2_i << reg1_i[4:0];    
                end
                `EXE_SRL_OP: begin
                    shiftres <= reg2_i >> reg1_i[4:0];
                end
                `EXE_SRA_OP: begin
                    shiftres <= ({32{reg2_i[31]}} << (6'd32 - {1'b0, reg1_i[4:0]}))
                                | reg2_i >> reg1_i[4:0];
                end
                default: begin
                    shiftres <= `ZeroWord;
                end
            endcase
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            moveres <= `ZeroWord;     
        end else begin
            moveres <= `ZeroWord;
            case (aluop_i)
                `EXE_MFHI_OP: begin
                    moveres <= HI;    
                end
                `EXE_MFLO_OP: begin
                    moveres <= LO;    
                end
                `EXE_MOVZ_OP: begin
                    moveres <= reg1_i;
                end
                `EXE_MOVN_OP: begin
                    moveres <= reg1_i;
                end
                default: begin
                end
            endcase
        end
    end


    /****   Arithmetic   ****/

    /*          stage one           */

    // If opcode if "SUB", assign the complement code of reg2_i to reg2_i_mux.
    // Otherwise reg2_i_mux equals to reg2_i.
    assign reg2_i_mux = ((aluop_i == `EXE_SUB_OP)  ||
                         (aluop_i == `EXE_SUBU_OP) ||
                         (aluop_i == `EXE_SLT_OP)) ?
                         (~reg2_i) + 1 : reg2_i;


    /*
    *   1. If operation is "add", reg2_i_mux is just the second operand
    *   reg2_i and the "result_sum" is its result.
    *   
    *   2. If operation is "sub", reg2_i_mux is the complement code of 
    *   reg2_i.So the "result_sum" is its result.
    *
    *   3. If operation is "slt", which compare two numbers,reg2_i_mux 
    *   is also the complement code of reg2_i.Because you can do sub operate
    *   to get the comparison result.
    */

    assign result_sum = reg1_i + reg2_i_mux;

    /*
    *   Judge if the result of "add" or "sub" is overflow:
    *   
    *   1. reg1_i is positive number and reg2_i is positive number, but the
    *   result of "add" operation is negative.
    *   
    *   2. reg1_i is negative number and reg2_i is negative number, but the
    *   result of "sub" operation is positive.
    */

    assign ov_sum = ((!reg1_i[31] && !reg2_i_mux[31]) && result_sum[31]) || 
                    ((reg1_i[31] && reg2_i_mux[31]) && (!result_sum[31]));

    /*
    *   Judge if oprand 1 is less than oprand 2:
    *
    *   1. aluop_i is EXE_SLT_OP 
    *       
    *       1) reg1_i is negative and reg2_i is positive, then reg1_i < reg2_i
    *
    *       2) reg1_i is positive and reg2_i is positive, meanwhile reg1_i - reg2_i < 0
    *       (result_sum < 0), then reg1_i < reg2_i
    *
    *       3) reg1_i is negative and reg2_i is negative, meanwhile reg1_i - reg2_i < 0
    *       (result_sum < 0), then reg1_i < reg2_i
    *   
    *   2. aluop_i is EXE_SLTU_OP, just use "<" to Judge two numbers 
    */

    assign reg1_lt_reg2 = (aluop_i  ==  `EXE_SLT_OP) ?
                            ((reg1_i[31]  &&  !reg2_i[31])  ||
                             (!reg1_i[31]  &&  !reg2_i[31]  &&  result_sum[31])  ||
                             (reg1_i[31]  && reg2_i[31]  &&  result_sum[31])) : (reg1_i < reg2_i);

    assign reg1_i_not = ~reg1_i;

    /*          stage two           */
    always @ (*) begin
        if(rst == `RstEnable) begin
            arithmeticres <= `ZeroWord;    
        end else begin
            case (aluop_i)
                `EXE_SLT_OP, `EXE_SLTU_OP: begin
                    arithmeticres <= reg1_lt_reg2;    
                end
                `EXE_ADD_OP, `EXE_ADDU_OP, `EXE_ADDI_OP, `EXE_ADDIU_OP: begin
                    arithmeticres <= result_sum;    
                end
                `EXE_SUB_OP, `EXE_SUBU_OP: begin
                    arithmeticres <= result_sum;
                end
                `EXE_CLZ_OP: begin
                    arithmeticres <= reg1_i[31] ? 0 : reg1_i[30] ? 1 :
                                     reg1_i[29] ? 2 : reg1_i[28] ? 3 :
                                     reg1_i[27] ? 4 : reg1_i[26] ? 5 :
                                     reg1_i[25] ? 6 : reg1_i[24] ? 7 :
                                     reg1_i[23] ? 8 : reg1_i[22] ? 9 :
                                     reg1_i[21] ? 10: reg1_i[20] ? 11:
                                     reg1_i[19] ? 12: reg1_i[18] ? 13:
                                     reg1_i[17] ? 14: reg1_i[16] ? 15:
                                     reg1_i[15] ? 16: reg1_i[14] ? 17:
                                     reg1_i[13] ? 18: reg1_i[12] ? 19:
                                     reg1_i[11] ? 20: reg1_i[10] ? 21:
                                     reg1_i[9]  ? 22: reg1_i[8]  ? 23:
                                     reg1_i[7]  ? 24: reg1_i[6]  ? 25:
                                     reg1_i[5]  ? 26: reg1_i[4]  ? 27:
                                     reg1_i[3]  ? 28: reg1_i[2]  ? 29:
                                     reg1_i[1]  ? 30: reg1_i[0]  ? 31:32;
                end
                `EXE_CLO_OP: begin
                    arithmeticres <= (
                        reg1_i_not[31] ? 0 :
                        reg1_i_not[30] ? 1 :
                        reg1_i_not[29] ? 2 :
                        reg1_i_not[28] ? 3 :
                        reg1_i_not[27] ? 4 :
                        reg1_i_not[26] ? 5 :
                        reg1_i_not[25] ? 6 :
                        reg1_i_not[24] ? 7 :
                        reg1_i_not[23] ? 8 :
                        reg1_i_not[22] ? 9 :
                        reg1_i_not[21] ? 10:
                        reg1_i_not[20] ? 11:
                        reg1_i_not[19] ? 12:
                        reg1_i_not[18] ? 13:
                        reg1_i_not[17] ? 14:
                        reg1_i_not[16] ? 15:
                        reg1_i_not[15] ? 16:
                        reg1_i_not[14] ? 17:
                        reg1_i_not[13] ? 18:
                        reg1_i_not[12] ? 19:
                        reg1_i_not[11] ? 20:
                        reg1_i_not[10] ? 21:
                        reg1_i_not[9]  ? 22:
                        reg1_i_not[8]  ? 23:
                        reg1_i_not[7]  ? 24:
                        reg1_i_not[6]  ? 25:
                        reg1_i_not[5]  ? 26:
                        reg1_i_not[4]  ? 27:
                        reg1_i_not[3]  ? 28:
                        reg1_i_not[2]  ? 29:
                        reg1_i_not[1]  ? 30:
                        reg1_i_not[0]  ? 31:32
                    );
                end
                                      
                default: begin
                    arithmeticres <= `ZeroWord;    
                end

            endcase
        end
    end

    /****           stage three         ****/

    // If Multiplicand is negative, then take its complement code.
    assign opdata1_mult = (((aluop_i == `EXE_MUL_OP)  || 
                            (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) ||
                            (aluop_i == `EXE_MSUB_OP))&& 
                            (reg1_i[31] == 1'b1)) ? (~reg1_i + 1) : reg1_i;

    // If Multiplier is negative, then take its complement code.
    assign opdata2_mult = (((aluop_i == `EXE_MUL_OP)  || 
                            (aluop_i == `EXE_MULT_OP) ||
                            (aluop_i == `EXE_MADD_OP) ||
                            (aluop_i == `EXE_MSUB_OP))&&
                            (reg2_i[31] == 1'b1)) ? (~reg2_i + 1) : reg2_i;

    // Save the temp_result
    assign hilo_temp = opdata1_mult * opdata2_mult;

    /*
    *   Fix the multiply result, save the result to "mulres": 
    *   
    *   1. If aluop_i is mult or mul,then we need to fix the temp_result:
    *       A. If multiplicand and multiplier have different signs, we need to
    *       take the complement code of hilo_temp as the result.
    *
    *       B. If Multipilicand and Multiplier have the same sign, hilo_temp
    *       is the final result.
    *
    *   2. If aluop_i is multu, then hilo_temp is the final result.       
    */
    always @ (*) begin
        if(rst == `RstEnable) begin
            mulres <= {`ZeroWord, `ZeroWord};    
        end else if((aluop_i == `EXE_MULT_OP) || 
                    (aluop_i == `EXE_MUL_OP)  ||
                    (aluop_i == `EXE_MADD_OP) ||
                    (aluop_i == `EXE_MSUB_OP)) begin
            if(reg1_i[31] ^ reg2_i[31] == 1'b1) begin
                mulres <= ~hilo_temp + 1;    
            end else begin
                mulres <= hilo_temp;    
            end
        end else begin
            mulres <= hilo_temp;    
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            hilo_temp_o <= {`ZeroWord, `ZeroWord};
            cnt_o       <= 2'b00;
            stallreq_for_madd_msub <= `NoStop;
        end else begin
            case (aluop_i)
                `EXE_MADD_OP, `EXE_MADDU_OP: begin  // madd maddu instruction
                    if(cnt_i == 2'b00) begin        // First cycle
                        hilo_temp_o <= mulres;
                        cnt_o       <= 2'b01;
                        hilo_temp1  <= {`ZeroWord, `ZeroWord};
                        stallreq_for_madd_msub <= `Stop;
                    end else if(cnt_i == 2'b01) begin           // Second cycle
                        hilo_temp_o <= {`ZeroWord, `ZeroWord};
                        cnt_o       <=  2'b10;
                        hilo_temp1  <= hilo_temp_i + {HI, LO};
                        stallreq_for_madd_msub <= `NoStop;
                    end
                end

                `EXE_MSUB_OP, `EXE_MSUBU_OP: begin  // msub msubu instruction
                    if(cnt_i == 2'b00) begin        // First cycle
                        hilo_temp_o <= ~mulres + 1;
                        cnt_o       <= 2'b01;
                        stallreq_for_madd_msub <= `Stop;
                    end else if(cnt_i == 2'b01) begin   // Second cycle
                        hilo_temp_o <=  ~mulres + 1;
                        cnt_o       <= 2'b10;
                        hilo_temp1  <= hilo_temp_i + {HI, LO};
                        stallreq_for_madd_msub <= `NoStop;
                    end
                end

            endcase
        end
    end

    /****    According to 'alusel_i', select the result    ****/
    always @ (*) begin
        wd_o <= wd_i;
        if(((aluop_i == `EXE_ADD_OP) || (aluop_i == `EXE_ADDI_OP) ||
            (aluop_i == `EXE_SUB_OP)) && (ov_sum == 1'b1)) begin        // check overflow
            wreg_o <= `WriteDisable;    
        end else begin
            wreg_o <= wreg_i;
        end
        case (alusel_i)
            `EXE_RES_LOGIC: begin
                wdata_o <= logicout;
            end
            `EXE_RES_SHIFT: begin
                wdata_o <= shiftres;
            end
            `EXE_RES_MOVE: begin
                wdata_o <= moveres;
            end
            `EXE_RES_ARITHMETIC: begin
                wdata_o <= arithmeticres;    
            end
            `EXE_RES_MUL: begin
                wdata_o <= mulres[31:0];    
            end
            default: begin
                wdata_o <= `ZeroWord;
            end
        endcase
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            whilo_o <=  `WriteDisable;
            hi_o    <=  `ZeroWord;
            lo_o    <=  `ZeroWord; 
        end else if((aluop_i == `EXE_MSUB_OP)  ||
                    (aluop_i == `EXE_MSUBU_OP)) begin
            whilo_o <=  `WriteEnable;
            hi_o    <=  hilo_temp1[63:32];
            lo_o    <=  hilo_temp1[31:0];
        end else if((aluop_i == `EXE_MADD_OP)  ||
                    (aluop_i == `EXE_MADDU_OP)) begin
            whilo_o <=  `WriteEnable;
            hi_o    <=  hilo_temp1[63:32];
            lo_o    <=  hilo_temp1[31:0];
        end else if ((aluop_i == `EXE_MULT_OP) ||
                     (aluop_i == `EXE_MULTU_OP)) begin
            whilo_o <= `WriteEnable;
            hi_o    <= mulres[63:32];
            lo_o    <= mulres[31:0];
        end else if (aluop_i == `EXE_MTHI_OP) begin
            whilo_o <=  `WriteEnable;
            hi_o    <=  reg1_i;
            lo_o    <=  LO; 
        end else if (aluop_i == `EXE_MTLO_OP) begin
            whilo_o <=  `WriteEnable;
            hi_o    <=  HI;
            lo_o    <=  reg1_i;
        end else begin
            whilo_o <=  `WriteDisable;
            hi_o    <=  `ZeroWord;
            lo_o    <=  `ZeroWord;
        end
    end

endmodule
