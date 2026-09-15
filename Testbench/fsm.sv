module fsm( 
    input logic clk, reset, nickel, dime, quarter, candy, chips, soda, // candy = 20, chips = 25, soda = 30
    output logic [1:0] states,
    output logic [5:0] total,
    output logic notEnough, selCandy, selChips, selSoda
);
    logic [5:0] temp_change, change;
    typedef enum logic [1:0] {Idle, Candy, Chips, Soda} statetype;
    statetype state, nextstate;

    // Sequential logic: Update registered state and change on rising clock edge
    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            temp_change <= 6'd0;
            state <= Idle;
        end else begin
            temp_change <= change;
            state <= nextstate;
        end
    end

    // Combinational logic: Compute next state, outputs, and updated change
    always_comb begin
        change = temp_change;
        selCandy = 1'd0;
        selChips = 1'd0;
        selSoda = 1'd0;
        notEnough = 1'd0;
        nextstate = state;

        case (state)
            Idle: begin
                if (candy | chips | soda) begin
                    notEnough = 1'd1;
                end else if (nickel) begin
                    change = change + 6'd5;
                end else if (dime) begin
                    change = change + 6'd10;
                end else if (quarter) begin
                    change = change + 6'd25;
                end
            end

            Candy: begin
                if (chips | soda) begin
                    notEnough = 1'd1;
                end else if (nickel) begin
                    change = change + 6'd5;
                end else if (dime) begin
                    change = change + 6'd10;
                end else if (quarter) begin
                    change = change + 6'd25;
                end else if (candy) begin
                    selCandy = 1'd1;
                    change = change - 6'd20;
                end
            end

            Chips: begin
                if (soda) begin
                    notEnough = 1'd1;
                end else if (nickel) begin
                    change = change + 6'd5;
                end else if (dime) begin
                    change = change + 6'd10;
                end else if (quarter) begin
                    change = change + 6'd25;
                end else if (candy) begin
                    selCandy = 1'd1;
                    change = change - 6'd20;
                end else if (chips) begin
                    selChips = 1'd1;
                    change = change - 6'd25;
                end
            end

            Soda: begin
                if (change >= 6'd60) begin
                    change = 6'd60;
                end else if (nickel) begin
                    change = change + 6'd5;
                end else if (dime) begin
                    change = change + 6'd10;
                end else if (quarter) begin
                    change = change + 6'd25;
                end else if (candy) begin
                    selCandy = 1'd1;
                    change = change - 6'd20;
                end else if (chips) begin
                    selChips = 1'd1;
                    change = change - 6'd25;
                end else if (soda) begin
                    selSoda = 1'd1;
                    change = change - 6'd30;
                end
            end

            default: nextstate = Idle;
        endcase

        // Dynamically compute next state based on change amount
        if (change >= 6'd30)
            nextstate = Soda;
        else if (change >= 6'd25)
            nextstate = Chips;
        else if (change >= 6'd20)
            nextstate = Candy;
        else
            nextstate = Idle;

        // Output registered accumulated change (eliminates combinational glitches)
        total = temp_change;
        states = state;
    end

endmodule
