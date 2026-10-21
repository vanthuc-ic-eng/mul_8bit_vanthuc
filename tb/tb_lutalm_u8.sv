//NGUYEN VAN THUC - 24161421
/*
 * Module: tb_lutalm_u8
 * Description: Exhaustive self-checking unsigned 8x8 regression test.
 * All 65,536 input pairs are compared against golden approximate vectors.
 */

`timescale 1ns/1ps

module tb_lutalm_u8;
    parameter integer LOW_W = 3;

    reg  [7:0]  a_i;
    reg  [7:0]  b_i;
    wire [15:0] p_o;
    reg  [15:0] golden [0:65535];
    integer ai;
    integer bi;
    integer idx;
    integer fails;

    lutalm_mul_u8 #(
        .LOW_W             ( LOW_W                  )
    ) dut (
        .a_i               ( a_i                    ),
        .b_i               ( b_i                    ),
        .p_o               ( p_o                    )
    );

    initial begin
        a_i = 8'd0;
        b_i = 8'd0;
        fails = 0;

        if (LOW_W == 3)
            $readmemh("vectors/lutalm_unsigned_ref_low3.hex", golden);
        else if (LOW_W == 4)
            $readmemh("vectors/lutalm_unsigned_ref_low4.hex", golden);
        else
            $fatal(1, "LOW_W must be 3 or 4");

        for (ai = 0; ai <= 255; ai = ai + 1) begin
            for (bi = 0; bi <= 255; bi = bi + 1) begin
                a_i = ai[7:0];
                b_i = bi[7:0];
                idx = ai * 256 + bi;
                #1;
                if (p_o !== golden[idx]) begin
                    if (fails < 10)
                        $display("FAIL: A=%0d B=%0d got=%04h expected=%04h",
                                 ai, bi, p_o, golden[idx]);
                    fails = fails + 1;
                end
            end
        end

        if (fails != 0)
            $fatal(1, "UNSIGNED FAIL: %0d of 65536 mismatches", fails);

        $display("UNSIGNED PASS: 65536/65536 cases, LOW_W=%0d", LOW_W);
        $finish;
    end
endmodule
