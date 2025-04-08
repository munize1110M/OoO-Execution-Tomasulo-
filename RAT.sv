/*module RAT(input logic clk,
        input logic reset,
        input logic[4:0]rs1_I1,
        input logic[4:0]rs2_I1,
        input logic[4:0]rd_I1,
        input logic mem_1,
        input logic lwsw_1,
        input logic mul_1,
 

        input logic[3:0]add_available,
        output logic[3:0]add_res_space,
        output logic[3:0]rs1_add_tag_out,
        output logic[31:0]rs1_add_val_out,
        output logic[3:0]rs2_add_tag_out,
        output logic[31:0]rs2_add_val_out,

        input logic [3:0]mul_available,
        output logic[3:0]mul_res_space,
        output logic [3:0]rs1_mul_tag_out,
        output logic [31:0]rs1_mul_val_out,
        output logic [3:0]rs2_mul_tag_out,
        output logic [31:0]rs2_mul_val_out,
        input decinac,
        input logic [3:0]broadcast_tag,
        input logic [31:0]broadcast_value);

typedef struct packed{
    logic VALID;
    logic[3:0] TAG;
    logic[31:0]VALUE;
} RAT_LINE;
RAT_LINE rat[32:1];

logic [4:0]rd1;
assign rd1 = rd_I1;

assign STALL = (add_available == 0) ? 1'b1: 1'b0;
//set 00000 as default tag maybe??? 
//meaning that 00000 is not a valid tag

always_comb begin
   if (reset) begin
        for(int i = 0; i < 32 ; i++) begin
            rat[i].VALID = 1;
            rat[i].TAG = 4'bx;
            rat[i].VALUE = i;  //initially to test, all the values are simply initialized to their index
        end
    end
    else begin
        //default
        //POTENTIAL ERROR IN THE CODE
        //map rd to rat
        if (!decinac && mul_1 == 0) begin
            rat[rd_I1].TAG = add_available;
            rat[rd_I1].VALID = 1'b0;
            rat[rd_I1].VALUE = 32'bX;
            //index src1
            rs1_add_tag_out = rat[rs1_I1].TAG;
            rs1_add_val_out = rat[rs1_I1].VALUE;
            add_res_space = add_available;
            //index src2
            rs2_add_tag_out = rat[rs2_I1].TAG;
            rs2_add_val_out = rat[rs2_I1].VALUE;
        end
        else if (!decinac && mul_1 == 1) begin
            //assign out to new mul signals
            rat[rd_I1].TAG = mul_available;
            rat[rd_I1].VALID = 1'b0;
            rat[rd_I1].VALUE = 32'bX;

            rs1_mul_tag_out = rat[rs1_I1].TAG;
            rs1_mul_val_out = rat[rs1_I1].VALUE;
            mul_res_space = mul_available;
            rs2_mul_tag_out = rat[rs2_I1].TAG;
            rs2_mul_val_out = rat[rs2_I1].VALUE;
        end
        else begin
            rs1_add_tag_out = 'x;
            rs1_add_val_out = 'x;
            rs2_add_tag_out = 'x;
            rs2_add_val_out = 'x;
            add_res_space = 'x;
        end
        for (int i = 1; i < 33; i++) begin
            if (rat[i].TAG == broadcast_tag && broadcast_tag !== 4'bX) begin
                rat[i].TAG = 'x;
                rat[i].VALID = 1;
                rat[i].VALUE = broadcast_value;
            end
        end
    end
end



endmodule*/
/*module RAT (
        input logic clk,
        input logic reset,
        input logic[4:0]rs1_I1,
        input logic[4:0]rs2_I1,
        input logic[4:0]rd_I1,
        input logic mem_1,
        input logic lwsw_1,
        input logic mul_1,
 

        input logic[3:0]add_available,
        output logic[3:0]add_res_space,
        output logic[3:0]rs1_add_tag_out,
        output logic[31:0]rs1_add_val_out,
        output logic[3:0]rs2_add_tag_out,
        output logic[31:0]rs2_add_val_out,

        input logic [3:0]mul_available,
        output logic[3:0]mul_res_space,
        output logic [3:0]rs1_mul_tag_out,
        output logic [31:0]rs1_mul_val_out,
        output logic [3:0]rs2_mul_tag_out,
        output logic [31:0]rs2_mul_val_out,
        input decinac,
        input logic [3:0]broadcast_tag,
        input logic [31:0]broadcast_value
);

    typedef struct packed {
        logic VALID;
        logic [3:0] TAG;
        logic [31:0] VALUE;
    } RAT_LINE;

    RAT_LINE rat[32:1]; // 32 entries, from index 0 to 31

    // === Source Register Lookup ===
    always_comb begin
        // Default outputs
        rs1_add_tag_out = 4'bx;
        rs1_add_val_out = 32'bx;
        rs2_add_tag_out = 4'bx;
        rs2_add_val_out = 32'bx;
        add_res_space = add_available;

        rs1_mul_tag_out = 4'bx;
        rs1_mul_val_out = 32'bx;
        rs2_mul_tag_out = 4'bx;
        rs2_mul_val_out = 32'bx;
        mul_res_space = mul_available;

        if (!decinac && !mul_1) begin
            // ADD instruction
            rs1_add_tag_out = rat[rs1_I1].TAG;
            rs1_add_val_out = rat[rs1_I1].VALUE;
            rs2_add_tag_out = rat[rs2_I1].TAG;
            rs2_add_val_out = rat[rs2_I1].VALUE;
        end else if (!decinac && mul_1) begin
            // MUL instruction
            rs1_mul_tag_out = rat[rs1_I1].TAG;
            rs1_mul_val_out = rat[rs1_I1].VALUE;
            rs2_mul_tag_out = rat[rs2_I1].TAG;
            rs2_mul_val_out = rat[rs2_I1].VALUE;
        end
    end

    // === Sequential RAT Update (Decode Stage) ===
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                rat[i].VALID = 1'b1;
                rat[i].TAG = 4'bx;
                rat[i].VALUE = i; // test initialization
            end
        end else begin
            if (!decinac) begin
                if (!mul_1) begin
                    // ADD instruction maps rd to add reservation station
                    rat[rd_I1].TAG   = add_available;
                    rat[rd_I1].VALID = 1'b0;
                    rat[rd_I1].VALUE = 32'bx;
                end else begin
                    // MUL instruction maps rd to mul reservation station
                    rat[rd_I1].TAG   = mul_available;
                    rat[rd_I1].VALID = 1'b0;
                    rat[rd_I1].VALUE = 32'bx;
                end
            end
        end
    end

    // === Broadcast Update ===
    always_ff @(posedge clk) begin
        if (broadcast_tag !== 4'bx) begin
            for (int i = 0; i < 32; i++) begin
                if (rat[i].TAG == broadcast_tag && rat[i].VALID == 0) begin
                    rat[i].VALID = 1'b1;
                    rat[i].VALUE = broadcast_value;
                    rat[i].TAG   = 4'bx;
                end
            end
        end
    end

endmodule*/


module RAT (
        input logic clk,
        input logic reset,
        input logic[4:0]rs1_I1,
        input logic[4:0]rs2_I1,
        input logic[4:0]rd_I1,
        input logic mem_1,
        input logic lwsw_1,
        input logic mul_1,
 

        input logic[3:0]add_available,
        output logic[3:0]add_res_space,
        output logic[3:0]rs1_add_tag_out,
        output logic[31:0]rs1_add_val_out,
        output logic[3:0]rs2_add_tag_out,
        output logic[31:0]rs2_add_val_out,

        input logic [3:0]mul_available,
        output logic[3:0]mul_res_space,
        output logic [3:0]rs1_mul_tag_out,
        output logic [31:0]rs1_mul_val_out,
        output logic [3:0]rs2_mul_tag_out,
        output logic [31:0]rs2_mul_val_out,
        input decinac,
        input logic [3:0]broadcast_tag,
        input logic [31:0]broadcast_value,
        input logic [3:0]mul_broadcast_tag,
        input logic [31:0]mul_broadcast_value
);

    typedef struct packed {
        logic VALID;
        logic [3:0] TAG;
        logic [31:0] VALUE;
    } RAT_LINE;

    RAT_LINE rat[32:1];

    // Outputs registered
    logic [3:0] rs1_tag_q, rs2_tag_q;
    logic [31:0] rs1_val_q, rs2_val_q;

    // === RAT Register Read (clocked)
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                rat[i].VALID = 1'b1;
                rat[i].TAG = 4'bx;
                rat[i].VALUE = i; // test init
            end
            // Clear outputs
            rs1_add_tag_out <= 4'bx;
            rs1_add_val_out <= 32'bx;
            rs2_add_tag_out <= 4'bx;
            rs2_add_val_out <= 32'bx;

            rs1_mul_tag_out <= 4'bx;
            rs1_mul_val_out <= 32'bx;
            rs2_mul_tag_out <= 4'bx;
            rs2_mul_val_out <= 32'bx;
        end else begin
            // === Register Read and Output for Decode Stage
            if (!decinac && !mul_1) begin
                // ADD instruction
                rs1_add_tag_out <= rat[rs1_I1].TAG;
                rs1_add_val_out <= rat[rs1_I1].VALUE;
                rs2_add_tag_out <= rat[rs2_I1].TAG;
                rs2_add_val_out <= rat[rs2_I1].VALUE;
                add_res_space <= add_available;
            end else if (!decinac && mul_1) begin
                // MUL instruction
                rs1_mul_tag_out <= rat[rs1_I1].TAG;
                rs1_mul_val_out <= rat[rs1_I1].VALUE;
                rs2_mul_tag_out <= rat[rs2_I1].TAG;
                rs2_mul_val_out <= rat[rs2_I1].VALUE;
                mul_res_space <= mul_available;
            end
        end
    end

    // === RAT Register Write (for rd)
    always_ff @(posedge clk) begin
        if (!reset && !decinac) begin
            if (!mul_1) begin
                // ADD destination register gets new tag
                rat[rd_I1].TAG = add_available;
                rat[rd_I1].VALID = 1'b0;
                rat[rd_I1].VALUE = 32'bx;
            end else begin
                // MUL destination register gets new tag
                rat[rd_I1].TAG = mul_available;
                rat[rd_I1].VALID = 1'b0;
                rat[rd_I1].VALUE = 32'bx;
            end
        end
    end

    // === Broadcast Resolution
    always_ff @(posedge clk) begin
        if (broadcast_tag !== 4'bx) begin
            for (int i = 0; i < 32; i++) begin
                if (rat[i].TAG == broadcast_tag && rat[i].VALID == 0) begin
                    rat[i].VALID = 1;
                    rat[i].VALUE = broadcast_value;
                    rat[i].TAG = 4'bx;
                end
                else if (rat[i].TAG == mul_broadcast_tag && rat[i].VALID ==0) begin
                    rat[i].VALID = 1;
                    rat[i].VALUE = mul_broadcast_value;
                    rat[i].TAG = 4'bx;
                end
            end
        end
    end

endmodule

