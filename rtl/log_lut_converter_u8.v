//NGUYEN VAN THUC - 24161421
/*
 * Module: log_lut_converter_u8
 * Description: Convert a seven-bit normalized fraction to a compact
 * logarithmic fraction by concatenating the identity-mapped upper
 * three bits with a calibrated three- or four-bit lower LUT output.
 * The least significant source fraction bit is omitted from the index.
 */

module log_lut_converter_u8 #(
    parameter integer LOW_W = 3
)(
    input  wire [6:0]       frac_i,
    output wire [LOW_W+2:0] log_frac_o
);

    wire [2:0] high_w;
    wire [2:0] low_addr_w;
    wire [LOW_W-1:0] low_w;

    assign high_w     = frac_i[6:4];
    assign low_addr_w = frac_i[3:1];
    assign log_frac_o = {high_w, low_w};

    generate
        if (LOW_W == 2) begin : gen_low2
            log_lut_low2 u_lut (
                .addr_i            ( low_addr_w             ),
                .data_o            ( low_w                  )
            );
        end else if (LOW_W == 3) begin : gen_low3
            log_lut_low3 u_lut (
                .addr_i            ( low_addr_w             ),
                .data_o            ( low_w                  )
            );
        end else if (LOW_W == 4) begin : gen_low4
            log_lut_low4 u_lut (
                .addr_i            ( low_addr_w             ),
                .data_o            ( low_w                  )
            );
        end else begin : gen_unsupported
            assign low_w = {LOW_W{1'b0}};
        end
    endgenerate

endmodule
