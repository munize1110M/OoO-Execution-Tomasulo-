module add_unit(input logic clk, reset,
            input logic calculate,
            input logic[31:0] a, b,
            input logic [3:0]row,
            output logic [31:0] result,
            output logic [3:0]tag,
            output logic broadcast); //write enable for the FIFO

always @(posedge clk ) begin
    broadcast <= 0;
    tag <= 4'b1111;
    result <= 0;
    if (reset) begin
        result <= 0;
        tag <= 4'b1111;
    end
    else begin
        if (calculate) begin
            broadcast <= 1;
            tag <= row;
            result <= a + b;
        end
        
    end
end

endmodule