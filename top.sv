module top(input logic clk,
        input logic reset,
        input logic [31:0] instr);


logic mul;
logic lwsw;
logic mem;
logic [4:0]rs1;
logic [4:0]rs2;
logic [4:0]rd;
logic [3:0]add_avail;
logic [3:0]rs1_tag_out;
logic [31:0]rs1_val_out;
logic [3:0]rs2_tag_out;
logic [31:0]rs2_val_out;

logic [3:0]mul_avail;
logic [3:0]rs1_mul_tag_out;
logic [31:0]rs1_mul_val_out;
logic [3:0]rs2_mul_tag_out;
logic [31:0]rs2_mul_val_out;

logic[31:0]rs1_to_add;
logic[31:0]rs2_to_add;
logic[3:0]row;

logic[31:0]rs1_to_mul;
logic[31:0]rs2_to_mul;
logic[3:0]mul_row;

logic dec_inac;

logic[3:0]res_space;
logic add_calculate;

logic [3:0]mul_res_space;
logic mul_calculate;

logic [31:0]adder_result;
logic broadcast_add;
logic [3:0]broadcast_tag_add;


logic [3:0]cdb_tag;
logic [31:0]cdb_data;

logic[31:0]mul_result;
logic broadcast_mul;
logic [3:0]broadcast_tag_mul;

RAT rat(clk, reset,
        rs1,
        rs2,
        rd,
        mem,
        lwsw,
        mul,
        add_avail,
        res_space,
        rs1_tag_out,
        rs1_val_out,
        rs2_tag_out,
        rs2_val_out,
        mul_avail,
        mul_res_space,
        rs1_mul_tag_out,
        rs1_mul_val_out,
        rs2_mul_tag_out,
        rs2_mul_val_out,
        dec_inac,
        cdb_tag,// input broadcast_tag,
        cdb_data);// input broadcast_val);

reservation_station rs (clk,
                        reset,
                        rs1_val_out, //value rat
                        rs1_tag_out, //rs1 tag
                        rs2_val_out, // value rat2
                        rs2_tag_out, //rs2 tag
                        res_space, //res space
                        add_avail, //available
                        rs1_to_add, //rs1 val
                        rs2_to_add, //rs2 val
                        row, //row
                        add_calculate, //calc
                        cdb_tag, //broad_tag
                        cdb_data, //broad value
                        broadcast_tag_add, //adder tag
                        1'b0); //mul res

reservation_station mult_rs(clk,
                        reset,
                        rs1_mul_val_out,//input logic [31:0]VALUE_RAT,
                        rs1_mul_tag_out,// input logic[4:0] rs1_tag,
                        rs2_mul_val_out,// input logic [31:0]VALUE_RAT2,
                        rs2_mul_tag_out,// input logic[4:0] rs2_tag,
                        mul_res_space,// input logic[4:0] res_space,
                        mul_avail,// output logic[4:0]available,
                        rs1_to_mul,// output logic [31:0]rs1_val,
                        rs2_to_mul,// output logic [31:0]rs2_val,
                        mul_row,// output logic [1:0]row,
                        mul_calculate,// output logic calculate,
                        cdb_tag,// input logic [3:0]broadcast_tag,
                        cdb_data,// input logic [31:0]broadcast_value,
                        broadcast_tag_mul,// input logic [3:0]adderTAG);
                        1'b1); //is this a MUL_res

decoder dec (instr,
    mem, mul,
    lwsw,
    rs1, rs2, rd,
    dec_inac);

add_unit adding(clk, reset,
            add_calculate,
            rs1_to_add, rs2_to_add,
            row,
            adder_result,
            broadcast_tag_add,
            broadcast_add);

multiplier mult(clk, reset,
                mul_calculate,// input logic calculate,
                rs1_to_mul, rs2_to_mul,// input logic [31:0] a, b,
                mul_row,// input logic row,
                mul_result,// output logic [31:0] result, :::: to bus
                broadcast_tag_mul,// output logic [3:0] tag, ::://to bus
                broadcast_mul);// output logic broadcast); ::://to bus


bus b(clk, reset,
        broadcast_tag_add,// input logic [3:0] aFUTag, 
        adder_result,// input logic [31:0] aFUData,
        broadcast_add,// input logic aFUReady,  //this is the broadcast signal from the adder
        broadcast_tag_mul,// input mFUTag,
        mul_result,// input mFUData,
        broadcast_mul,// input mFUReady,
        cdb_tag,// output logic [3:0] broad_tag,
        cdb_data);// output logic [31:0] broad_data)


endmodule