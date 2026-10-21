//NGUYEN VAN THUC - 24161421
/*
 * Module: log_normalizer_u8
 * Description: Detect the leading one, left-normalize an 8-bit unsigned
 * magnitude, and extract the seven normalized fractional bits.
 * The zero input produces k=0, fraction=0; zero bypass is external.
 */

module log_normalizer_u8 (
    input  wire [7:0] mag_i,
    output reg  [2:0] k_o,
    output wire [6:0] frac_o
);

    wire [2:0] shift_w;
    wire [7:0] normalized_w;

    always @(*) begin
        if      (mag_i[7]) k_o = 3'd7;
        else if (mag_i[6]) k_o = 3'd6;
        else if (mag_i[5]) k_o = 3'd5;
        else if (mag_i[4]) k_o = 3'd4;
        else if (mag_i[3]) k_o = 3'd3;
        else if (mag_i[2]) k_o = 3'd2;
        else if (mag_i[1]) k_o = 3'd1;
        else               k_o = 3'd0;
    end

    assign shift_w     = 3'd7 - k_o;
    assign normalized_w = mag_i << shift_w;
    assign frac_o       = normalized_w[6:0];

endmodule
