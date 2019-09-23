`include "../../defines/defines.v"
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
    reg [`RegBus]            arithmeticres;      // Save the result of arithmetic
    wire[`RegBus]           reg2_i_mux;         // Save the complement code of reg2_i
    wire[`RegBus]           reg1_i_not;         // Save ~reg1_i
    wire[`RegBus]           result_sum;         // Save the result of "add" operation
    wire[`RegBus]           opdata1_mult;       // Multipilicand in "Multiply" operation
    wire[`RegBus]           opdata2_mult;       // Multipilier in "Multiply" operation
    wire[`DoubleRegBus]     mulres;             // Result of "Multiply" operation 

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

    /****    According to 'alusel_i, select the result    ****/
    always @ (*) begin
        wd_o        <=      wd_i;
        wreg_o      <=      wreg_i;
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
