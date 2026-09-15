`timescale 1s/1ms

module tb;
    logic clk;
    logic reset;
    logic nickel;
    logic dime;
    logic quarter;
    logic candy;
    logic chips;
    logic soda;

    logic [1:0] states;
    logic [5:0] total;
    logic notEnough;
    logic selCandy;
    logic selChips;
    logic selSoda;

    // Instantiate Unit Under Test (UUT)
    fsm uut (
        .clk(clk),
        .reset(reset),
        .nickel(nickel),
        .dime(dime),
        .quarter(quarter),
        .candy(candy),
        .chips(chips),
        .soda(soda),
        .states(states),
        .total(total),
        .notEnough(notEnough),
        .selCandy(selCandy),
        .selChips(selChips),
        .selSoda(selSoda)
    );

    // Clock Generation: 1-second period (toggles every 0.5s)
    always #0.5 clk = ~clk;

    // Monitor signal values in decimal in the terminal output
    initial begin
        $monitor("Time = %02ts | State = %0d | Total = %02d cents | selCandy=%b selChips=%b selSoda=%b notEnough=%b",
                 $time, states, total, selCandy, selChips, selSoda, notEnough);
    end

    initial begin
        $dumpfile("output.vcd");
        $dumpvars(0, tb);

        // Initialize signals
        clk = 0;
        reset = 1;
        nickel = 0;
        dime = 0;
        quarter = 0;
        candy = 0;
        chips = 0;
        soda = 0;

        // Apply Reset
        @(posedge clk);
        #0.1;
        reset = 0;

        // 1. Insert Nickel (5 cents)
        @(posedge clk);
        nickel = 1;
        @(posedge clk);
        nickel = 0;

        // 2. Insert Dime (10 cents, total becomes 15)
        @(posedge clk);
        dime = 1;
        @(posedge clk);
        dime = 0;

        // 3. Try to buy Candy (costs 20, total = 15 -> notEnough=1)
        @(posedge clk);
        candy = 1;
        @(posedge clk);
        candy = 0;

        // 4. Insert Quarter (25 cents, total becomes 40 -> Soda state)
        @(posedge clk);
        quarter = 1;
        @(posedge clk);
        quarter = 0;

        // 5. Buy Soda (costs 30, remaining total becomes 10 -> Idle state)
        @(posedge clk);
        soda = 1;
        @(posedge clk);
        soda = 0;

        // 6. Insert Quarter (25 cents, total becomes 35 -> Soda state)
        @(posedge clk);
        quarter = 1;
        @(posedge clk);
        quarter = 0;

        // 7. Buy Chips (costs 25, remaining total becomes 10 -> Idle state)
        @(posedge clk);
        chips = 1;
        @(posedge clk);
        chips = 0;

        repeat (2) @(posedge clk);
        $display("Simulation complete. Waveform saved to output.vcd");
        $finish;
    end

endmodule
