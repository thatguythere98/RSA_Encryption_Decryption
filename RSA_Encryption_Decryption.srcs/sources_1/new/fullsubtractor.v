`timescale 1ns / 1ps

module fullsubtractor(
    input [15:0] a,
    input [15:0] b,

    output [15:0] Out
  );

  assign Out =   b -  a;

endmodule
