module tb();

logic clk;
logic reset;
logic [31:0]vectornum, errors;
logic [31:0] testvectors [10000:0];
logic [31:0]instruction;


top DUT(clk, reset, instruction);


  initial begin
    //$readmemb("cache_inputs.tv", testvectors);
    //$readmemb("mem_test.tv", testvectors);
    $readmemh("tom.tv",testvectors);
    vectornum = 0; errors = 0;
    reset <= 1; #10; reset <= 0; #10; // Wait for reset to de-assert
    $display("Initialization complete, starting test...");
  end

  // generate clock to sequence tests
  always begin
    clk <= 1; #5; clk <= 0; #5;
  end

  always @(posedge clk) begin
    if (~reset) begin
      instruction = testvectors[vectornum];
      $display("INSTRUCTION: %h", instruction);
    end
  end

  // check results
  always @(negedge clk) if (~reset) begin
    $display("Processing test vector %d", vectornum);
    vectornum = vectornum + 1;
    $display("Incremented vectornum to %d", vectornum);
    //$display("state: %b   next_state: %b", state, next_state);
    if (vectornum >= 10000) begin
      $display("End of test vectors");
      $finish;
    end
  end




endmodule