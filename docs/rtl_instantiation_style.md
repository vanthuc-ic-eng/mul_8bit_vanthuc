# RTL instantiation style

All named parameter and port connections use one connection per line.
Parameter and port names, opening parentheses, and closing parentheses are column-aligned.
Use named ports, not positional connections. Keep the trailing comma on all except the final connection.

Example:

```verilog
    log_encoder_u8 #(
        .LOW_W            ( LOW_W                  )
    ) u_log_a (
        .mag_i            ( mag_a_w                ),
        .log_o            ( log_a_w                )
    );
```

This release modifies formatting only. Numerical behavior is unchanged.
