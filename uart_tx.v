module uart_tx #(
    parameter CLKS_PER_BIT = 10416       // 100 MHz clock -> 9600 baud
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       tx_start,
    input  wire [7:0] tx_data,

    output reg        tx,
    output reg        busy,
    output reg        done
);

    //============================================================
    // State Encoding
    
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    //============================================================
    // Registers

    reg [1:0] state;
    reg [7:0] shift_reg;
    reg [2:0] bit_index;
    reg [15:0] baud_counter;

    //============================================================
    // UART Transmitter FSM

    always @(posedge clk or posedge reset)
    begin

        //--------------------------------------------------------
        // Asynchronous Reset

        if(reset)
        begin
            state        <= IDLE;
            tx           <= 1'b1;
            busy         <= 1'b0;
            done         <= 1'b0;
            shift_reg    <= 8'd0;
            bit_index    <= 3'd0;
            baud_counter <= 16'd0;
        end

        //--------------------------------------------------------
        // Normal Operation
        
        else
        begin

            // done should only be HIGH for one clock cycle
            done <= 1'b0;

            case(state)

            // IDLE STATE
            IDLE:
            begin
                tx <= 1'b1;
                busy <= 1'b0;

                baud_counter <= 0;
                bit_index <= 0;

                if(tx_start)
                begin
                    busy <= 1'b1;
                    shift_reg <= tx_data;
                    state <= START;
                end
            end

            // START BIT

            START:
            begin
                tx <= 1'b0;

                if(baud_counter < CLKS_PER_BIT-1)
                begin
                    baud_counter <= baud_counter + 1;
                end
                else
                begin
                    baud_counter <= 0;
                    state <= DATA;
                end
            end


            // SEND 8 DATA BITS (LSB FIRST)
            DATA:
            begin
                tx <= shift_reg[0];

                if(baud_counter < CLKS_PER_BIT-1)
                begin
                    baud_counter <= baud_counter + 1;
                end
                else
                begin
                    baud_counter <= 0;

                    shift_reg <= shift_reg >> 1;

                    if(bit_index < 7)
                    begin
                        bit_index <= bit_index + 1;
                    end
                    else
                    begin
                        bit_index <= 0;
                        state <= STOP;
                    end
                end
            end

              
            // STOP BIT
            STOP:
            begin
                tx <= 1'b1;

                if(baud_counter < CLKS_PER_BIT-1)
                begin
                    baud_counter <= baud_counter + 1;
                end
                else
                begin
                    baud_counter <= 0;
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end
            end

            // Default State
            default:
            begin
                state <= IDLE;
            end

            endcase

        end

    end

endmodule
