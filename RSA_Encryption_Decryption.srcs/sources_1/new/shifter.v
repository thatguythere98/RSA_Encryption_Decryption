`timescale 1ns / 1ps

module shifter
  (
    input [15:0] in,
    input [3:0] N,
    output [15:0] O
  );
  reg [15:0] out_reg;
  assign O = out_reg;

  always @(N or in)
  begin
    case (N)
      15 :
        out_reg <= { in[15:0],15'b0};
      14 :
        out_reg <= { in[15:0],14'b0};
      13 :
        out_reg <= { in[15:0],13'b0};
      12 :
        out_reg <= { in[15:0],12'b0};
      11 :
        out_reg <= { in[15:0],11'b0};
      10 :
        out_reg <= { in[15:0],10'b0};
      9 :
        out_reg <= { in[15:0],9'b0};
      8 :
        out_reg <= { in[15:0],8'b0};

      7 :
        out_reg <= { in[15:0],7'b0};
      6 :
        out_reg <= { in[15:0],6'b0};
      5 :
        out_reg <= { in[15:0],5'b0};
      4 :
        out_reg <= { in[15:0],4'b0};
      3 :
        out_reg <= { in[15:0],3'b0};
      2 :
        out_reg <= { in[15:0],2'b0};
      1 :
        out_reg <= { in[15:0],1'b0};
      0 :
        out_reg <=   in[15:0];
    endcase
  end
endmodule
