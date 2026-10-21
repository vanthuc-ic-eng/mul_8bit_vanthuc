//NGUYEN VAN THUC - 24161421
/*
 * Module: log_antilog_u16
 * Description: Approximate the inverse logarithm with a fixed-point
 * mantissa and exponent-controlled left shift.
 * Formula: product = ((2^F + fraction) << exponent) >> F.
 * The intermediate bus is sized to preserve all relevant shifted bits.
 */

module log_antilog_u16 #(
    parameter integer LOW_W = 3
)(
    input  wire [LOW_W+6:0] log_sum_i,
    output wire [15:0]      product_o
);

    localparam integer F = 3 + LOW_W;

    wire [3:0]  exponent_w;
    wire [F:0]  mantissa_w;
    wire [23:0] mantissa_ext_w;
    wire [23:0] shifted_w;
    wire [23:0] value_w;

    assign exponent_w     = log_sum_i[F+3:F];
    assign mantissa_w     = {1'b1, log_sum_i[F-1:0]};
    assign mantissa_ext_w = {{(23-F){1'b0}}, mantissa_w};
    assign shifted_w      = mantissa_ext_w << exponent_w;
    assign value_w        = shifted_w >> F;
    assign product_o      = value_w[15:0];

endmodule
