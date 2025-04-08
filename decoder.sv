module decoder(input logic [31:0]instruction,
    output logic mem, mul,
    output logic lwSw,
    output logic [4:0]rs1, rs2, rd,
    output logic inactive);

    logic [6:0]op;
    logic [7:0]funct3;
    logic [7:0]funct7;


    assign op = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign mul = funct7[7:0];

    always_comb begin
        case(op)
            7'b0000011: begin
                inactive <= 0;
                mem <= 1;
                lwSw <= 1;
                rd <= instruction[11:7];
                rs1 <= instruction[19:15];
            end
            7'b1000011: begin
                inactive <= 0;
                mem <= 1;
                lwSw <= 0;
                rs1 <= instruction[19:15];
                rs2 <= instruction[24:20];
            end
            7'b0110011: begin
                inactive <= 0;
                mem <= 0;
                rd <= instruction[11:7];
                rs1 <= instruction[19:15];
                rs2 <= instruction[24:20];
            end
            default: begin
                mem <= 0;
                inactive <= 1;
            end
        endcase
    end

endmodule

