`timescale 1ns / 1ps

module mymodfunc(input   [15:0]  A,
                   input   [15:0]  B,
                   input          rst,
                   input          clk,
                   input          ld,
                   output  reg        Done,
                   output  reg [15:0] O
                  );

  // regs and wires declaration
  reg  [1:0]  current_state, next_state;
  reg  [15:0]  in_A, in_B;
  wire  [15:0] temp_O; // register to store output


  // module instantiation
  fullsubtractor f(in_A, in_B, temp_O);

  // combinational
  always @(*)
  begin
    Done = 0;

    case (current_state)
      2'd0:
      begin //initial state
        if (ld)
        begin
          Done = 0;
          next_state = 2'd1;
        end
        else
          next_state = 2'd0;
      end

      2'd1:
      begin //subtraction
        O = temp_O;

        if(temp_O < in_A)
        begin
          next_state = 2'd0;
          Done = 1;
        end
        else
        begin
          next_state = 2'd1;
        end
      end
      default:
        next_state = 2'd0;

    endcase // current_state
  end

  // sequential
  always @(posedge clk)
  begin
    if (rst)
    begin
      current_state <= 2'd0;
    end
    else
      current_state <= next_state;

    case (current_state)
      2'd0:
      begin
        if (ld)
        begin
          in_A <= A;
          in_B <= B;
        end
      end
      2'd1:
      begin
        in_B <= temp_O;
      end
    endcase

  end
endmodule
