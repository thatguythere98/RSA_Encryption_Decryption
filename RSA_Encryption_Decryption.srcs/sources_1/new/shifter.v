`timescale 1ns / 1ps

module shifter
  (
    input [15:0] in,  // 16-bit input value to be shifted
    input [3:0] N,    // 4-bit shift amount (number of positions to shift)
    output [15:0] O   // 16-bit shifted output
  );

  reg [15:0] out_reg;     // Register to hold the shifted output
  assign O = out_reg;     // Assign the output of the module to the internal register

  // Combinational logic block that shifts the input value based on the shift amount (N)
  always @(N or in)
  begin
    case (N)
      15 :
        out_reg <= { in[15:0], 15'b0 };   // Shift input by 15 positions
      14 :
        out_reg <= { in[15:0], 14'b0 };   // Shift input by 14 positions
      13 :
        out_reg <= { in[15:0], 13'b0 };   // Shift input by 13 positions
      12 :
        out_reg <= { in[15:0], 12'b0 };   // Shift input by 12 positions
      11 :
        out_reg <= { in[15:0], 11'b0 };   // Shift input by 11 positions
      10 :
        out_reg <= { in[15:0], 10'b0 };   // Shift input by 10 positions
      9  :
        out_reg <= { in[15:0], 9'b0  };   // Shift input by 9 positions
      8  :
        out_reg <= { in[15:0], 8'b0  };   // Shift input by 8 positions
      7  :
        out_reg <= { in[15:0], 7'b0  };   // Shift input by 7 positions
      6  :
        out_reg <= { in[15:0], 6'b0  };   // Shift input by 6 positions
      5  :
        out_reg <= { in[15:0], 5'b0  };   // Shift input by 5 positions
      4  :
        out_reg <= { in[15:0], 4'b0  };   // Shift input by 4 positions
      3  :
        out_reg <= { in[15:0], 3'b0  };   // Shift input by 3 positions
      2  :
        out_reg <= { in[15:0], 2'b0  };   // Shift input by 2 positions
      1  :
        out_reg <= { in[15:0], 1'b0  };   // Shift input by 1 position
      0  :
        out_reg <=   in[15:0];            // No shift (N=0), output is the same as input
    endcase
  end
endmodule
