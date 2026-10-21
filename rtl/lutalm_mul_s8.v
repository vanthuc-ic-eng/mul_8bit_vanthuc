//NGUYEN VAN THUC - 24161421
/*
 * Module: lutalm_mul_s8
 * Description: Fully combinational signed INT8 approximate logarithmic
 * multiplier using independently optimized split LUTs. This is a
 * LUT-ALM 0-style research implementation, not the author's original RTL.
 * LOW_W = 3 or 4 selects fractional precision.
 */

module lutalm_mul_s8 #(
    parameter integer LOW_W = 3
)(
    input  wire [7:0]  a_i,
    input  wire [7:0]  b_i,
    output wire signed [15:0] p_o
);

    wire [7:0] mag_a_w, mag_b_w;
    wire sign_a_w, sign_b_w, zero_a_w, zero_b_w;
    wire [LOW_W+5:0] log_a_w, log_b_w;
    wire [LOW_W+6:0] log_sum_w;
    wire [15:0] approx_mag_w;

    log_input_sign_u8 u_sign_a (
        .data_i            ( a_i                    ),
        .mag_o             ( mag_a_w                ),
        .sign_o            ( sign_a_w               ),
        .zero_o            ( zero_a_w               )
    );

    log_input_sign_u8 u_sign_b (
        .data_i            ( b_i                    ),
        .mag_o             ( mag_b_w                ),
        .sign_o            ( sign_b_w               ),
        .zero_o            ( zero_b_w               )
    );

    log_encoder_u8 #(
        .LOW_W             ( LOW_W                  )
    ) u_log_a (
        .mag_i             ( mag_a_w                ),
        .log_o             ( log_a_w                )
    );

    log_encoder_u8 #(
        .LOW_W             ( LOW_W                  )
    ) u_log_b (
        .mag_i             ( mag_b_w                ),
        .log_o             ( log_b_w                )
    );

    log_adder_u8 #(
        .LOW_W             ( LOW_W                  )
    ) u_log_add (
        .log_a_i           ( log_a_w                ),
        .log_b_i           ( log_b_w                ),
        .log_sum_o         ( log_sum_w              )
    );

    log_antilog_u16 #(
        .LOW_W             ( LOW_W                  )
    ) u_antilog (
        .log_sum_i         ( log_sum_w              ),
        .product_o         ( approx_mag_w           )
    );

    log_output_sign_s16 u_output_sign (
        .mag_i             ( approx_mag_w           ),
        .sign_i            ( sign_a_w ^ sign_b_w    ),
        .zero_i            ( zero_a_w | zero_b_w    ),
        .product_o         ( p_o                    )
    );

endmodule
