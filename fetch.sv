module fetch(input logic clk,
        input logic reset,
        input logic stall,
        output logic [3:0]pc1,
        output logic [3:0]pc2);

        always @(posedge clk) begin
            if (reset) begin
                pc1 <= 0;
                pc2 <= 1;
            end
            else begin
                if (!stall) begin
                    pc1 <= pc1 +2;
                    pc2 <= pc2 +2;
                end
            end
        end

endmodule   