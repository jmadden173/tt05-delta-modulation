
module delta (    
    input reg [4:0] data,
    input reg [4:0] prev,
    input reg [4:0] threshold,
    input wire off_spike,
    output wire spike[1:0]
);

    // compares the difference between current data and previous against a threshold

    wire [4:0] delta;

    always @(*) begin
        assign delta = data - prev;

        assign spike[1] = off_spike : (delta < -threshold) ? 0;
        assign spike[0] = (delta > threshold) | spike[1]; 
    end

endmodule

