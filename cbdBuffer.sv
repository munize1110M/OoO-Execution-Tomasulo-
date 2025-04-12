module cbdBuffer (input clk, reset,
                input logic [3:0] aFUTag,
                input logic [31:0] aFUData,
                input logic aFUReady,
                input logic [3:0] mFUTag,
                input logic [31:0] mFUData,
                input logic mFUReady,
                output logic [3:0] AddBroadTag,
                output logic [31:0] AddBroadData,
                output logic [3:0] MulBroadTag,
                output logic [31:0] MulBroadData);
                // output logic [3:0]broad_tag,
                // output logic [31:0]broad_data);

//forward the row value that gets outputted from the 
// rs into the FUs. Meaning forward the row to become
// an output of each FU

//that way the Row will be the dedicated space in the buffer

//since theres only 1 FU and 1 Multiplier
    // two buff registers

typedef struct packed {
    logic [31:0] Data;
    logic [3:0] Tag;
} buffer;

buffer addbuff;

buffer multbuff;

always @(posedge clk) begin
    if (reset) begin
        addbuff.Data <= 'x;
        addbuff.Tag <= 'x;
        multbuff.Data <= 'x;
        multbuff.Tag <= 'x;
    end
    else begin
        if (aFUReady & !mFUReady) begin
            addbuff.Data <= aFUData;
            addbuff.Tag <= aFUTag;
            AddBroadTag <= addbuff.Tag;
            AddBroadData <= addbuff.Data;
        end
        if (mFUReady & !aFUReady) begin
            multbuff.Data <= mFUData;
            multbuff.Tag <= mFUTag;
            MulBroadTag <= multbuff.Tag;
            MulBroadData <= multbuff.Data;
        end
        else if (aFUReady && mFUReady) begin
            addbuff.Data <= aFUData;
            addbuff.Tag <= aFUTag;
            AddBroadTag <= addbuff.Tag;
            AddBroadData <= addbuff.Data;
            multbuff.Data <= mFUData;
            multbuff.Tag <= mFUTag;
            MulBroadTag <= multbuff.Tag;
            MulBroadData <= multbuff.Data;
        end
    end
end



endmodule