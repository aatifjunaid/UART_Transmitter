// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module uart_tx_tb;

    //============================================================
    // Testbench Signals
    reg clk;
    reg reset;
    reg tx_start;
    reg [7:0] tx_data;

    wire tx;
    wire busy;
    wire done;

    //============================================================
    // Instantiate UART Transmitter
    
    uart_tx #(
        .CLKS_PER_BIT(16)      // Small value for fast simulation
    ) uut (
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .busy(busy),
        .done(done)
    );

    //============================================================
    // Clock Generation (100 MHz -> 10 ns period)
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    //============================================================
    // Task to Transmit One Byte
    
    task send_byte;
        input [7:0] data;
        begin
            @(posedge clk);

            tx_data   = data;
            tx_start  = 1'b1;

            @(posedge clk);
            tx_start = 1'b0;

            // Wait until transmission completes
            wait(done);

            @(posedge clk);
        end
    endtask

    //============================================================
    // Test Sequence

    initial begin

        // Generate waveform file
        $dumpfile("waveform.vcd");
        $dumpvars(0, uart_tx_tb);

        // Initialize inputs
        reset = 1;
        tx_start = 0;
        tx_data = 8'h00;

        // Hold reset
        #50;

        reset = 0;

        // Wait a few clocks
        repeat(5) @(posedge clk);

        // Test Case 1
        $display("Sending 0x55");
        send_byte(8'h55);

        repeat(10) @(posedge clk);

        // Test Case 2
        $display("Sending 0xA5");
        send_byte(8'hA5);

        repeat(10) @(posedge clk);

        // Test Case 3
        $display("Sending 0xFF");
        send_byte(8'hFF);

        repeat(20) @(posedge clk);

        $display("Simulation Finished");

        $finish;

    end

endmodule
