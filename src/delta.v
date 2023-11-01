
module delta (
    input wire reset,
    input reg [3:0] data,
    input reg [3:0] prev,
    input reg [3:0] threshold,
    input wire off_spike,
    output wire [1:0] spike
);

    // compares the difference between current data and previous against a threshold

    reg [3:0] diff;

    always @(*) begin
        if (reset) begin
            diff = 4'b0000;
        end

        diff = data - prev;

        spike[1] = off_spike ? (diff < -threshold) : 0;
        spike[0] = (diff > threshold) | spike[1]; 
    end

endmodule

