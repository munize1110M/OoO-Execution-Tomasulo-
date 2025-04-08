module bus(input clk, reset,
        input logic [3:0] aFUTag, 
        input logic [31:0] aFUData, 
        input logic aFUReady,  //this is the broadcast signal from the adder
        input logic [3:0] mFUTag,
        input logic [31:0] mFUData,
        input logic mFUReady,
        output logic [3:0] broad_tag,
        output logic [31:0] broad_data);
        //output logic broad_ready);

    logic [3:0]tagQ [3:0];
    logic [31:0] dataQ[3:0];
    logic [1:0]head, tail;

    //null regs for the FIFO status signals
    logic tagfull;
    logic datafull;
    logic tagempty;
    logic dataempty;  

    logic [31:0]masterData;
    logic [3:0]masterTag;
    logic masterReady;


// can add multiplexing logic before the FIFO. ENABLE signal
//determines whether the multiplier or adder writes to the 
//fifo
    always_comb begin
        if (aFUReady) begin
            //adder sends to data fifo
            masterData = aFUData;
            //adder sends to tag fifo
            masterTag = aFUTag;
            masterReady = aFUReady;
        end
        else if(mFUReady) begin
            //mult sends to data fifo
            masterData = mFUData;
            //mult sends to tag fifo
            masterTag = mFUTag;
            masterReady = mFUReady;
        end
        else if (aFUReady && mFUReady) begin
            for (int i = 0; i <2 ; i++) begin
                if (i == 0) begin
                    masterData = aFUData; 
                    masterTag = aFUTag;
                    masterReady = aFUReady;
                end
                else if (i ==1) begin
                    masterData = mFUData;
                    masterTag = mFUTag;
                    masterReady = mFUReady;
                end
                else begin
                    masterData = 'x;
                    masterTag = 'x;
                    masterReady = 'x;
                end
            end
        end
        else begin
            masterData = 'x;
            masterTag = 'x;
            masterReady = 'x;
        end
    end

//these FIFOs correspond to the adder Functional Unit
    FIFO #(4)tagFIFO(clk,
    reset,
    masterTag,//aFUTag, //FUNCTIONAL UNIT TAG
    masterReady,// aFUReady, //FUNCTIONAL UNIT READY (BROADCAST SIGNAL)
    broad_tag,// output logic [DATA_WIDTH-1:0] dout,
    tagfull,// output logic full,
    tagempty);// output logic empty);

    FIFO #(32)dataFIFO(clk,
    reset,
    masterData,// aFUData, //FUNCTIONAL UNIT DATA
    masterReady,// aFUReady, //FUNCTIONAL UNIT READY (BROADCAST SIGNAL)
    broad_data,// output logic [DATA_WIDTH-1:0] dout,
    datafull,// output logic full,
    dataempty);// output logic empty);


endmodule