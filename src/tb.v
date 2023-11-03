`default_nettype none
`timescale 1ns/1ps

/*
this testbench just instantiates the module and makes some convenient wires
that can be driven / tested by the cocotb test.py
*/

// testbench is controlled by test.py
module tb ();

    // this part dumps the trace to a vcd file that can be viewed with GTKWave
    initial begin
        $dumpfile ("tb.vcd");
        $dumpvars (0, tb);
        #1;
    end

    // wire up the inputs and outputs
    reg  clk;
    reg  rst_n;
    reg  ena;
    reg  [7:0] ui_in;
    reg  [7:0] uio_in;

    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;


    // utility wires
    wire [3:0] threshold;
    assign ui_in[3:0] = threshold;

    wire [3:0] data;
    assign ui_in[7:4] = data;

    wire [1:0] spike = uo_out[1:0];
    wire [3:0] prev = uo_out[7:4];

    wire off_spike;
    assign uio_in[0] = off_spike;

    wire load_prev;
    assign uio_in[1] = load_prev;

    wire [3:0] force_prev;
    assign uio_in[7:4] = force_prev;


    tt_um_jmadden173_delta_modulation tt_um_jmadden173_delta_modulation (
    // include power ports for the Gate Level test
    `ifdef GL_TEST
        .VPWR( 1'b1),
        .VGND( 1'b0),
    `endif
        .ui_in      (ui_in),    // Dedicated inputs
        .uo_out     (uo_out),   // Dedicated outputs
        .uio_in     (uio_in),   // IOs: Input path
        .uio_out    (uio_out),  // IOs: Output path
        .uio_oe     (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
        .ena        (ena),      // enable - goes high when design is selected
        .clk        (clk),      // clock
        .rst_n      (rst_n)     // not reset
        );

endmodule
