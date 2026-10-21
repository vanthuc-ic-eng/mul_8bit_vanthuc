//NGUYEN VAN THUC - 24161421
/*
 * Module: exact_mul_s8
 * Description: Exact signed INT8 reference multiplier for PPA and
 * numerical error comparisons. Both operands are explicitly signed.
 */

module exact_mul_s8 (
    input  wire signed [7:0] a_i,
    input  wire signed [7:0] b_i,
    output wire signed [15:0] p_o
);

    assign p_o = a_i * b_i;

endmodule
