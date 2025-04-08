module FIFO #(parameter
    DATA_WIDTH=8
) (
    input clk,
    input reset,
    input [DATA_WIDTH-1:0] din, 
    input wr,
    //  input rd, //this signal will get red whenever the RS or RAT reads a value from teh CBD
    output logic [DATA_WIDTH-1:0] dout,
    output logic full,
    output logic empty
);

    //the FIFOs jobs are simply to broadcast data on to the bus
    //it is the responsibility of the RSs and RAT to listen and 
    //check to see if theres relevant data on the bus
    localparam FIFO_DEPTH = 3;

    logic [DATA_WIDTH-1:0] fifo [FIFO_DEPTH-1:0];
    logic [$clog2(FIFO_DEPTH):0] wr_count;

    always @(posedge clk)
    begin
        if (reset)
        begin
            wr_count <= '0;
            // fifo[0]  <= '1;
            for(int i = 0; i <FIFO_DEPTH; i++) begin
                fifo[i] <= 'x;
            end
        end
        else if (wr)
        begin
            fifo[0] <= din;
            for (int i=1; i < FIFO_DEPTH; i++) begin
                fifo[i] <= fifo[i-1];
            end
            if (wr_count != FIFO_DEPTH)
                wr_count <= wr_count + 1;
        end
    end

/*always @(posedge clk)
    begin
        if (reset)
        begin
            for (int i = 0; i < FIFO_DEPTH; i++) begin
                fifo[i] <= '0;
            end
        end
        else if (rd && !empty) // Prevent reading if FIFO is empty
        begin
            for (int i = 0; i < FIFO_DEPTH-1; i++) begin
                fifo[i] <= fifo[i+1]; // Shift data out
            end
            fifo[FIFO_DEPTH-1] <= '0; // Clear last position
            wr_count <= wr_count - 1; // Decrement write count
        end
    end*/


    assign empty = (wr_count == 0);
    assign full  = (wr_count == FIFO_DEPTH);
    assign dout  = empty ? '1 : fifo[0];
    //assign dout = empty ? '1 : fifo[wr_count-1];

endmodule