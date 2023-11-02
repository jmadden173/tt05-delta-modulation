
module delta (
    input wire reset,
    input wire [3:0] data,
    input wire [3:0] prev,
    input wire [3:0] threshold,
    input wire off_spike,
    output reg [1:0] spike
);

    // compares the difference between current data and previous against a threshold

    reg [3:0] diff;

    always @(*) begin
        if (reset) begin
            diff = 4'b0000;
        end

        diff = data - prev;

        // check if difference is above threshold
        if (diff > threshold) begin
            if (data > prev) begin
                // on a "rising" input
                spike = 2'b01;
            end else if (data < prev) begin
                // on a "falling" input
                // only valid with off_spike
                spike = off_spike ? 2'b10 : 2'b00;
            end else begin
                // when they are equal
                spike = 2'b00; 
            end
        end else begin
            spike = 2'b00;
        end
    end

endmodule

