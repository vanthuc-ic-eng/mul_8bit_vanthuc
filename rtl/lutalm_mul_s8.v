//NGUYEN VAN THUC - 24161421
/*
 * Module: lutalm_mul_s8
 * Description: Fully combinational signed INT8 approximate logarithmic
 * multiplier using independently calibrated split LUTs.
 * Parameter LOW_W: fractional table width (3 or 4).
 * Parameter TRUNC_BITS: lower bits truncation for hardware optimization:
 *   0: Full precision (97 LUTs, MRED = 2.676%)
 *   4: IEEE TC 2026 paper matched (86 LUTs, 305.9 um2, MRED = 3.418%)
 *   5: Ultra-compact (70 LUTs, 275.0 um2, MRED = 4.396%)
 */

module lutalm_mul_s8 #(
    parameter integer LOW_W      = 3,
    parameter integer TRUNC_BITS = 0
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

    wire sign_prod_w = sign_a_w ^ sign_b_w;
    wire zero_prod_w = zero_a_w | zero_b_w;

    generate
        if (TRUNC_BITS == 0) begin : gen_exact_output
            log_output_sign_s16 u_output_sign (
                .mag_i             ( approx_mag_w           ),
                .sign_i            ( sign_prod_w            ),
                .zero_i            ( zero_prod_w            ),
                .product_o         ( p_o                    )
            );
        end else begin : gen_trunc_output
            localparam integer REM_BITS = 16 - TRUNC_BITS;
            wire [REM_BITS-1:0] trunc_mag_w  = approx_mag_w[15:TRUNC_BITS];
            wire [REM_BITS-1:0] eff_mag_w    = zero_prod_w ? {REM_BITS{1'b0}} : trunc_mag_w;
            wire [REM_BITS-1:0] signed_mag_w = sign_prod_w ? (~eff_mag_w + 1'b1) : eff_mag_w;
            assign p_o = {signed_mag_w, {TRUNC_BITS{1'b0}}};
        end
    endgenerate

endmodule
