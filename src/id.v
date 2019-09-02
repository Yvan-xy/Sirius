module id(
    input   wire                    rst,
    input   wire [`InstAddrBus]     pc_i,
    input   wire [`InstBus]         inst_i,

    // read the value of Regfile
    input   wire [`RegBus]          reg1_data_i,    // The first value from Regfile
    input   wire [`RegBus]          reg2_data_i,    // The second value from Regfile


    output  reg                    reg1_read_o,     // The Enable signal of the first port of the Regfile
    output  reg                    reg2_read_o,     // The Enable signal of the second port of the Regfile
    output  reg [`RegAddrBus]      reg1_addr_o,     // The address of the first register in Regfile
    output  reg [`RegAddrBus]      reg2_addr_o,     // The address of the second register in Regfile

    output  reg [`AluOpBus]        aluop_o,         // The subtype of the instruction in decode stage
    output  reg [`AluSelBus]       alusel_o,        // The type of the instruction in decode stage
    output  reg [`RegBus]          reg1_o,          // The source "reg_1" in decode stage
    output  reg [`RegBus]          reg2_o,          // The source "reg_2" in decode stage
    output  reg [`RegAddrBus]      wd_o,            // The address of destination in Regfile in decode stage
    output  reg                    wreg_o           // if exist destination to write back
);

    // fetch opcode and ifun
    // judge if the instruction is ori by checking 26-31bits
    wire [5:0] op = inst_i[31:26];
    wire [4:0] op2 = inst_i[10:6];
    wire [5:0] op3 = inst_i[5:0];
    wire [4:0] op4 = inst_i[20:16];

    // save the immediate number
    reg [`RegBus] imm;

    // if the ins is valid
    reg instvalid;

    
    /****   decode   ****/
    always @ (*) begin
        if(rst == `RstEnable) begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= `NOPRegAddr;
            wreg_o      <= `WriteDisable;
            instvalid   <= `Instvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= `NOPRegAddr;
            reg2_addr_o <= `NOPRegAddr;
            imm         <= 32'h0;
        end else begin
            aluop_o     <= `EXE_NOP_OP;
            alusel_o    <= `EXE_RES_NOP;
            wd_o        <= inst_i[15:11];
            wreg_o      <= `WriteDisable;
            instvalid   <= `InstInvalid;
            reg1_read_o <= 1'b0;
            reg2_read_o <= 1'b0;
            reg1_addr_o <= inst_i[25:21];
            reg2_addr_o <= inst_i[20:16];
            imm         <= `ZeroWord;
        
        
            case (op)
                `EXE_ORI:   begin   // judge if opcode is "ori"
                    // set write enable
                    wreg_o <= `WriteEnable;

                    // Subtype of operation is "or operation"
                    aluop_o <= `EXE_OR_OP;

                    // Type of operation is "Login Operation"
                    alusel_o <= `EXE_RES_LOGIC;

                    // Read register_1 from port_1 of Regfile
                    // Send the Enable signal
                    reg1_read_o <= 1'b1;

                    // No need to read register_2 from port_2 of Regfile
                    // Send the Disable signal
                    reg2_read_o <= 1'b0;
                
                    // Get immediate number
                    imm     <=      {16'h0, inst_i[15:0]};

                    // Destination to write
                    wd_o    <=      inst_i[20:16];

                    // "ori" is valid instruction
                    instvalid    <=     `Instvalid;

                end
                default:    begin
                end

            endcase
        end
    end

    /****    determine the operand_1     ****/
    always @ (*) begin
        if(rst == `RstEnable) begin
            reg1_o  <=  `ZeroWord;
        end else if(reg1_read_o == 1'b1) begin
            reg1_o  <=  reg1_data_o;
        end else if(reg1_read_o == 1'b0) begin
            reg1_o  <=  imm;
        end else begin
            reg1_o  <=  `ZeroWord;
        end
    end

    always @ (*) begin
        if(rst == `RstEnable) begin
            reg2_o  <=  `ZeroWord;
        end else if(reg2_read_o == 1'b1) begin
            reg2_o  <=  reg2_data_i;
        end else if(reg2_read_o == 1'b0) begin
            reg2_o  <=  imm;
        end else begin
            reg2_o  <= `ZeroWord;
        end
    end

endmodule





































