//NGUYEN VAN THUC - 24161421
/*
 * Module: log_output_sign_s16
 * Description: Restore the signed 16-bit multiplication result using
 * exact two's-complement sign handling and force products with zero to 0.
 */

module log_output_sign_s16 (
    input  wire [15:0] mag_i,
    input  wire        sign_i,
    input  wire        zero_i,
    output wire [15:0] product_o
);

    wire [15:0] signed_mag_w;
    assign signed_mag_w = sign_i ? (~mag_i + 16'd1) : mag_i;
    assign product_o    = zero_i ? 16'd0 : signed_mag_w;

endmodule
