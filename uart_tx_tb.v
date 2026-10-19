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

    localparam CLKS_PER_BIT = 16;
    integer pass_count = 0;
    integer fail_count = 0;

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


    // checker task
    task receive_and_check;
        input [7:0] expected;
        reg [7:0] got;
        integer i;
        begin
            @(negedge tx);                                  // start bit begins
            repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk); // middle of bit 0
            for (i = 0; i < 8; i = i + 1) begin
                got[i] = tx;                                // LSB first
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            // now in the middle of the stop bit
            if (got === expected && tx === 1'b1) begin
                pass_count = pass_count + 1;
                $display("PASS: sent 0x%h, received 0x%h", expected, got);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: sent 0x%h, received 0x%h, stop bit = %b", expected, got, tx);
            end
        end
    endtask
    
    task test_byte;
        input [7:0] data;
        begin
            fork
                send_byte(data);
                receive_and_check(data);
            join
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

        #50;
        reset = 0;
        repeat (5) @(posedge clk);

        test_byte(8'h00);
        test_byte(8'hFF);
        test_byte(8'h55);
        test_byte(8'hAA);
        test_byte(8'hA5);
        repeat (10) test_byte($random);      // random data
        // then the summary:
        $display("Tests passed: %0d, failed: %0d", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else                 $display("SOME TESTS FAILED");
    
        $finish;
    end

endmodule
