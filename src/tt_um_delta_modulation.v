`default_nettype none

module tt_um_jmadden173_delta_modulation (
    input  wire [7:0] ui_in,    // Dedicated inputs - connected to the input switches
    output wire [7:0] uo_out,   // Dedicated outputs - connected to the 7 segment display
    input  wire [7:0] uio_in,   // IOs: Bidirectional Input path
    output wire [7:0] uio_out,  // IOs: Bidirectional Output path
    output wire [7:0] uio_oe,   // IOs: Bidirectional Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // will go high when the design is enabled
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // Reset signal
    wire reset = ! rst_n;

    // declarations

    reg [3:0] data;
    reg [3:0] threshold;

    reg [3:0] prev;

    wire [3:0] force_prev;
    
    wire [1:0] spike;

    wire load_prev;
    wire off_spike;

    // Assign inputs, outputs, bidirectional

    // dedicated outputs
    // constant values for unused output
    assign uo_out[7:4] = prev;
    assign uo_out[3:2] = 2'b00;
    assign uo_out[1:0] = spike;

    // set bidirectional pin direction
    assign uio_oe[7:4] = 4'b0000;
    assign uio_oe[3:2] = 2'b11;
    assign uio_oe[1:0] = 2'b00;

    // zero bidirectional output levels
    assign uio_out[7:0] = 8'b00000000; 

    // assign parameter wires to input pins 
    assign load_prev = uio_in[1];
    assign off_spike = uio_in[0];
    assign force_prev = uio_in[7:4];


    always @(posedge clk) begin
        // zero out reg on reset
        if (reset) begin
            data <= 4'b0000;
            threshold <= 4'b0000;
            prev <= 4'b0000;
        end

        // store data to reg
        data <= ui_in[7:4];
        // store threshold to reg
        threshold <= ui_in[3:0];

        // propogate prev
        if (load_prev) begin
            prev <= force_prev;
        end else begin
            prev <= data;
        end
    end

    delta delta(
        .reset(reset),
        .data(data),
        .threshold(threshold),
        .prev(prev),
        .off_spike(off_spike),
        .spike(spike)
    );
    
endmodule
