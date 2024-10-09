`timescale 1ns / 1ps

module fulladder
  (
    input [15:0] x,
    input [15:0] y,

    output [15:0] O
  );

  assign O =   y + x;

endmodule
