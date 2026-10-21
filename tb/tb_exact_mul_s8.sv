//NGUYEN VAN THUC - 24161421
/*
 * Module: tb_exact_mul_s8
 * Description: Exhaustive 65536-case check for the exact signed 8x8 baseline.
 */
`timescale 1ns/1ps

module tb_exact_mul_s8;
    reg signed [7:0] a_i;
    reg signed [7:0] b_i;
    wire signed [15:0] p_o;
    reg signed [15:0] expected;
    integer a, b, fails;

    exact_mul_s8 dut (
        .a_i               ( a_i                    ),
        .b_i               ( b_i                    ),
        .p_o               ( p_o                    )
    );

    initial begin
        fails = 0;
        a_i = 0;
        b_i = 0;
        for (a = -128; a <= 127; a = a + 1) begin
            for (b = -128; b <= 127; b = b + 1) begin
                a_i = a;
                b_i = b;
                expected = a * b;
                #1;
                if (p_o !== expected) begin
                    if (fails < 8)
                        $display("EXACT FAIL A=%0d B=%0d got=%0d exp=%0d", a, b, p_o, expected);
                    fails = fails + 1;
                end
            end
        end
        if (fails != 0)
            $fatal(1, "EXACT FAIL: %0d mismatches", fails);
        $display("EXACT PASS: 65536/65536 signed INT8 combinations");
        $finish;
    end
endmodule
