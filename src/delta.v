
module delta (    
    input reg [4:0] data,
    input reg [4:0] prev,
    input reg [4:0] threshold,
    input wire off_spike,
    output wire [1:0] spike
);

    // compares the difference between current data and previous against a threshold

    wire [4:0] diff;

    always @(*) begin
        diff = data - prev;

        spike[1] = off_spike ? (diff < -threshold) : 0;
        spike[0] = (diff > threshold) | spike[1]; 
    end

endmodule

