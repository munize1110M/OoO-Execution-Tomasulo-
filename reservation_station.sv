module reservation_station(input logic clk,
                        input logic reset,
                        input logic [31:0]VALUE_RAT,
                        input logic[3:0] rs1_tag,
                        input logic [31:0]VALUE_RAT2,
                        input logic[3:0] rs2_tag,
                        input logic[3:0] res_space,
                        output logic[3:0]available,
                        output logic [31:0]rs1_val,
                        output logic [31:0]rs2_val,
                        output logic [3:0]row,
                        output logic calculate,
                        input logic [3:0]broadcast_tag,
                        input logic [31:0]broadcast_value,
                        input logic [3:0]adderTAG,
                        input logic MUL_RES);

//TAG HAS TO BE SENT TO THE RAT, THIS CAN BE FORWARDED AS THE ROW OF THE.
//SO output logic[1:0]row    <<< this will tell the FU what tag to broadcast after its done with its operation.

typedef struct packed {
    //name section
    logic BUSY;
    logic[2:0]OPERATION;
    logic VALID_1;
    logic [4:0]SRC_OP1; //srcOP1 value
    logic [3:0]TAG1;

    logic VALID_2;
    logic [4:0]SRC_OP2; //srcOP2 value
    logic [3:0]TAG2;
    logic FU;
    //logic [3:0]ID;
} rs;

rs res1[7:0]; //Initializes 3 deep reservation station
logic[4:0]temp_rs1;
logic[4:0]temp_rs2;
logic[4:0]temp_rd;
logic[31:0]temp_rs1_val;
logic[31:0]temp_rs2_val;
//this logic takes in the already renamed registers. The mapping from IQ to RAT will be done with combination logic
//in a TopLevel file
//NEED TO ADD A MASTER BUSY SIGNAL THAT WILL AID IN TELLING THE INSTRUCTION DISPATCH UNIT WHEN TO STALL
logic[3:0]ready;

logic[3:0]waiting;
logic resfull;

logic tag1match;
logic tag2match;
logic tag3match;
logic tag4match;

logic check_busy1;
logic check_busy2;
logic check_busy3;
logic check_busy4;

logic flag0;
logic flag1;
logic flag2;
logic flag3;

logic[3:0]curr;
logic [3:0]next_avail;
logic [3:0]mul_curr;
logic [3:0]next_avail_mul;

assign check_busy1 = res1[0].BUSY;
assign check_busy2 = res1[1].BUSY;
assign check_busy3 = res1[2].BUSY;
assign check_busy4 = res1[3].BUSY;


assign waiting = {(res1[0].VALID_1 ==0 || res1[0].VALID_2 ==0) && res1[0].BUSY ==1, (res1[1].VALID_1 == 0 || res1[1].VALID_2 == 0) && res1[1].BUSY == 1,
                (res1[2].VALID_1 == 0 || res1[2].VALID_2 == 0) && res1[2].BUSY == 1, (res1[3].VALID_1 == 0 || res1[3].VALID_2 == 0) && res1[3].BUSY ==1};

assign temp_rs1_val = VALUE_RAT;
assign temp_rs2_val = VALUE_RAT2;
assign resfull = (res1[0].BUSY && res1[1].BUSY && res1[2].BUSY && res1[3].BUSY);
assign tag1match = broadcast_tag == res1[0].TAG1 || broadcast_tag == res1[0].TAG2;
assign tag2match = broadcast_tag == res1[1].TAG1 || broadcast_tag == res1[1].TAG2;
assign tag3match = broadcast_tag == res1[2].TAG1 || broadcast_tag == res1[2].TAG2;
assign tag4match = broadcast_tag == res1[3].TAG1 || broadcast_tag == res1[3].TAG2;

//assign ready = {res1[0].VALID_1&&res1[0].VALID_2, res1[1].VALID_1&&res1[1].VALID_2, res1[2].VALID_1&&res1[2].VALID_2, res1[3].VALID_1&&res1[3].VALID_2};

always@(*) begin
    next_avail = curr;
    case(curr)
        4'b0000: next_avail = 4'b0001;
        4'b0001: next_avail = 4'b0010;
        4'b0010: next_avail = 4'b0011;
        4'b0011: next_avail = 4'b0000;
    endcase
end
always @(*) begin
    next_avail_mul = mul_curr;
    case(mul_curr)
        4'b0100: next_avail_mul = 4'b0101;
        4'b0101: next_avail_mul = 4'b0110;
        4'b0110: next_avail_mul = 4'b0111;
        4'b0111: next_avail_mul = 4'b0100;
    endcase
end

always @(posedge clk) begin
    if (reset) begin
        curr <= 4'b0000;
        mul_curr <= 4'b0100;
    end
    else begin
        curr <= next_avail;
        mul_curr <= next_avail_mul;
    end
end
assign available = (MUL_RES) ? mul_curr : curr;

/*always @(posedge clk)begin
    if (reset) begin
        available <= 4'bx;
        flag0 <= 0;
        flag1 <= 0;
        flag2 <= 0;
        flag3 <= 0;
    end 
    else begin
        if (MUL_RES) begin
            if (res1[4].BUSY==0) begin
                available <= 4'b0100;
            end
            else if (res1[5].BUSY ==0) begin
                available <= 4'b0101;
            end
            else if (res1[6].BUSY ==0) begin
                available <= 4'b0110;
            end
            else if (res1[7].BUSY ==0) begin
                available <= 4'b0111;
            end
            else begin
                available <= 4'bxxx;
            end
        end
        else begin
            if (res1[0].BUSY==0 && !flag0) begin
                available <= 4'b0000;
                flag0 <= 1;
                flag1 <= 0;
                flag2 <= 0;
                flag3 <= 0;
            end
            else if (res1[1].BUSY ==0 && !flag1) begin
                available <= 4'b0001;
                flag0 <= 0;
                flag1 <= 1;
                flag2 <= 0;
                flag3 <= 0;
            end
            else if (res1[2].BUSY ==0 && !flag2) begin
                available <= 4'b0010;
                flag0 <= 0;
                flag1 <= 0;
                flag2 <= 1;
                flag3 <= 0;
            end
            else if (res1[3].BUSY ==0 && !flag3) begin
                available <= 4'b0011;
                flag0 <= 0;
                flag1 <= 0;
                flag2 <= 0;
                flag3 <= 1;
            end
            else begin
                available <= 4'bxxxx;
            end
        end
    end
end*/
//the logic here is that all the busy signals will be added together to form the available signal which will be decoded in the RAT
//a zero at each indicy will indicate that that spot in the resevation station is free.

    

always@(posedge clk) begin
    if (reset) begin
        for (int i =0; i <8; i++) begin
            res1[i].BUSY <= 0;
            res1[i].OPERATION <= 0;
            res1[i].VALID_1 <= 0;
            res1[i].SRC_OP1 <= 0;
            res1[i].VALID_2 <= 0;
            res1[i].SRC_OP2 <= 0;
            res1[i].TAG1 <= 'x;
            res1[i].TAG2 <= 'x;
            res1[i].FU <= 0;
        end
        //one hot encoding
        //res1[0].ID <= 5'b00001;
        //res1[1].ID <= 5'b00010;
        //res1[2].ID <= 5'b00100;
    end
    else begin
        //IF RAT READY (RAT WILL ONLY BE READY IF IT DECODES THE AVAILABLE SIGNAL & FINDS THAT THERE IS AN EMPTY SLOT IN THE RS)
            //READ SRC VALUES, SRC TAGS, AND SRC VALID
            //FIND A FREE SPACE IN THE RESERVATION STATION
                //ONCE A FREE SPACE IS FOUND, FORWARD THAT TAG TO THE RAT {MAY BE AN ISSUE LATER ON BC THIS WILL OCCUR ON THE NEXT CLK CYCLE}
        //if (RAT_READY) begin
            //we will use the TAG_RAT to index the RAT RS structure



            //SIDE NOTE:::::: MIGHT NEED TO MAKE CHANGES. IN THE EVENT THAT THE RES STATION ISNT COMPLETELY FULL, THEN THE (WAITING != 0) IF STATEMENT
            //WONT EXECUTE
            calculate <= 0;
            //if the reservation station is not full & (RAT VAL 1 or RAT VAL 2 are undefined)
                // set the ones that are undefined to not value and set the tag
                //CHECK current valid signals bc these should only execute if the current space in the rs is empty
            
            //replaced res_space with available
            
            if (resfull != 1 && (temp_rs1_val === 32'bX   || temp_rs2_val === 32'bX) ) begin
                    res1[res_space].BUSY <= 1;
                    //res1[TAG_RAT].OPERATION <= <<<<<<<<< might not need this signal
                    res1[res_space].VALID_1 <= (temp_rs1_val === 32'bX) ? 1'b0: 1'b1;
                    res1[res_space].SRC_OP1 <= temp_rs1_val;
                    res1[res_space].VALID_2 <= (temp_rs2_val === 32'bX) ? 1'b0: 1'b1;
                    res1[res_space].SRC_OP2 <= temp_rs2_val;
                    res1[res_space].TAG1 <= rs1_tag;
                    res1[res_space].TAG2 <= rs2_tag;
                
                /*else begin
                    res1[res_space].BUSY <= 1;
                    //res1[TAG_RAT].OPERATION <= <<<<<<<<< might not need this signal
                    res1[res_space].VALID_1 <= 1;
                    res1[res_space].SRC_OP1 <= temp_rs1_val;
                    res1[res_space].VALID_2 <= 1;
                    res1[res_space].SRC_OP2 <= temp_rs2_val;
                    res1[res_space].TAG1 <= rs1_tag;
                    res1[res_space].TAG2 <= rs2_tag;
                end*/
            end
            //if the reservation station is not full & ( RAT VAL 1 & RAT VAL 2 are NOT undefined)
                //set both values to valid and add both values to the RS
            if (resfull != 1 && (temp_rs1_val !==32'bx && temp_rs2_val !==32'bx) &&(res1[res_space].VALID_1 == 0 && res1[res_space].VALID_2 ==0)) begin
            res1[res_space].BUSY <= 1;
            //res1[TAG_RAT].OPERATION <= <<<<<<<<< might not need this signal
            res1[res_space].VALID_1 <= 1;
            res1[res_space].SRC_OP1 <= temp_rs1_val;
            res1[res_space].VALID_2 <= 1;
            res1[res_space].SRC_OP2 <= temp_rs2_val;
            res1[res_space].TAG1 <= rs1_tag;
            res1[res_space].TAG2 <= rs2_tag;
            end

            //CURRENT BUG IN THE CODE. 
            // --- ALL RESERVATION STATIONS ARE NOT ALWAYS FILLED BC OF THIS else if statement
            if (waiting != 0) begin
               
                if ((broadcast_tag === res1[0].TAG1 || broadcast_tag === res1[0].TAG2) && broadcast_tag !== 4'bX) begin
                    res1[0].BUSY <= 1;
                    res1[0].VALID_1 <= 1;
                    res1[0].SRC_OP1 <= (broadcast_tag === res1[0].TAG1) ? broadcast_value : res1[0].SRC_OP1;
                    res1[0].VALID_2 <= 1;
                    res1[0].SRC_OP2 <= (broadcast_tag === res1[0].TAG2) ? broadcast_value : res1[0].SRC_OP2;
                    res1[0].TAG1 <= (broadcast_tag === res1[0].TAG1) ? broadcast_tag : res1[0].TAG1;//set tag to x
                    res1[0].TAG2 <= (broadcast_tag === res1[0].TAG2) ? broadcast_tag : res1[0].TAG2;//set tag to x
                end
                else if ((broadcast_tag === res1[1].TAG1 || broadcast_tag === res1[1].TAG2) && broadcast_tag !== 4'bX) begin
                    res1[1].BUSY <= 1;
                    res1[1].VALID_1 <= 1;
                    res1[1].SRC_OP1 <= (broadcast_tag === res1[1].TAG1) ? broadcast_value : res1[1].SRC_OP1;
                    res1[1].VALID_2 <= 1;
                    res1[1].SRC_OP2 <= (broadcast_tag === res1[1].TAG2) ? broadcast_value : res1[1].SRC_OP2;
                    res1[1].TAG1 <= (broadcast_tag === res1[1].TAG1) ? broadcast_tag : res1[1].TAG1;//set tag to x
                    res1[1].TAG2 <= (broadcast_tag === res1[1].TAG2) ? broadcast_tag : res1[1].TAG2;//set tag to x
                end
                else if ((broadcast_tag === res1[2].TAG1 || broadcast_tag === res1[2].TAG2) && broadcast_tag !== 4'bX) begin

                    res1[2].BUSY <= 1;
                    res1[2].VALID_1 <= 1;
                    res1[2].SRC_OP1 <= (broadcast_tag === res1[2].TAG1) ? broadcast_value : res1[2].SRC_OP1;
                    res1[2].VALID_2 <= 1;
                    res1[2].SRC_OP2 <= (broadcast_tag === res1[2].TAG2) ? broadcast_value : res1[2].SRC_OP2;
                    res1[2].TAG1 <= (broadcast_tag === res1[2].TAG1) ? broadcast_tag : res1[2].TAG1;//set tag to x
                    res1[2].TAG2 <= (broadcast_tag === res1[2].TAG2) ? broadcast_tag : res1[2].TAG2;//set tag to x
                end
                else if((broadcast_tag === res1[3].TAG1 || broadcast_tag === res1[3].TAG2) && broadcast_tag !== 4'bX) begin
                    res1[3].BUSY <= 1;
                    res1[3].VALID_1 <= 1;
                    res1[3].SRC_OP1 <= (broadcast_tag === res1[3].TAG1) ? broadcast_value : res1[3].SRC_OP1;
                    res1[3].VALID_2 <= 1;
                    res1[3].SRC_OP2 <= (broadcast_tag === res1[3].TAG2) ? broadcast_value : res1[3].SRC_OP2;
                    res1[3].TAG1 <= (broadcast_tag === res1[3].TAG1) ? broadcast_tag : res1[3].TAG1; //set tag to X
                    res1[3].TAG2 <= (broadcast_tag === res1[3].TAG2) ? broadcast_tag : res1[3].TAG2; //set tag to X
                end
            end
            for(int i = 0; i < 8; i++) begin
                if(res1[i].VALID_1 == 1 && res1[i].VALID_2 == 1 && res1[i].FU != 1) begin
                    rs1_val <= res1[i].SRC_OP1;
                    rs2_val <= res1[i].SRC_OP2;
                    row <= i;
                    res1[i].FU <= 1;
                    calculate <= 1;
                    break;
                end
            end
            
            //NEW PSUEDO CODE NEEDED TO CHECK IF ANY VALID SLOTS (both valid signals high in a row) send to the FU

    end
end


//free up reservation space when the adder tag gets broadcasted

always @(posedge clk ) begin
    if(adderTAG != 4'b1111) begin
            res1[adderTAG].BUSY <= 0;
            res1[adderTAG].OPERATION <= 0;
            res1[adderTAG].VALID_1 <= 0;
            res1[adderTAG].SRC_OP1 <= 0;
            res1[adderTAG].VALID_2 <= 0;
            res1[adderTAG].SRC_OP2 <= 0;
            res1[adderTAG].TAG1 <= 'x;
            res1[adderTAG].TAG2 <= 'x;
            res1[adderTAG].FU <= 0;
    end
end

//this block will continue filling the reservation table as long as the res table has a free space.











endmodule