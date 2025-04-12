module IMEM(input logic clk,
        input logic reset,
        input logic [3:0]addr1,
        input logic addr2,
        output logic [31:0] data1, data2
);
    logic [31:0] instructionMem[31:0];

    always @(posedge clk) begin 
        if (reset) begin
            $readmemh("file", instructionMem);
        end
        else begin
            data1 <= instructionMem[addr1];
            data2 <= instrMem[addr2];
        end
    end
    
endmodule