module multiplier(input logic clk, reset,
                input logic calculate,
                input logic [31:0] a, b,
                input logic [3:0]row,
                output logic [31:0] result,
                output logic [3:0] tag,
                output logic broadcast);


    always @(posedge clk) begin
        broadcast <= 0;
        if (reset) begin
            tag <= 4'b1111;
            result <= 0;
        end
        else begin
            if (calculate) begin
                // tag <= row +4; //the plus 4 is to ensure that the tags are different from those in the adder unit //NOTE THIS CAN BE AN ALTERNATE IMPLEMENTATION
                tag <= row;
                broadcast <= 1;
                result <= a * b;
            end
        end
    end


endmodule