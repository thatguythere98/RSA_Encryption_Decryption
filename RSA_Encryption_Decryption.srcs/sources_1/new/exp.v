`timescale 1ns / 1ps

module myexp(input   [15:0]  A,
               input   [15:0]  B,
               input          rst,
               input          clk,
               input          ld,
               output  reg        Done,
               output  reg [15:0] O
              );

  // regs and wires declaration
  reg  [2:0]  current_state, next_state;
  reg  [15:0] in_A, in_A_temp;
  reg  [15:0]  in_B;
  reg  [3:0]  C;
  reg  [15:0] add_x, add_y; // adder input x, y
  wire [15:0] add_O; // adder output O
  reg  [15:0] temp_O; // register to store the global output
  reg  [15:0] shift_in; // shifter input in
  reg  [3:0]  shift_N;  // shifter input N
  wire [15:0] shift_O;  // shifter output O

  reg [7:0] expC;

  // module instantiation
  fulladder f(add_x, add_y, add_O);
  shifter   s(shift_in, shift_N, shift_O);

  // combinational
  always @(*)
  begin

    add_x   = temp_O;
    add_y   = shift_O;
    shift_in = 0;
    shift_N = C;
    Done = 0;

    case (current_state)
      3'd0:
      begin
        if (ld)
        begin
          Done = 0;
          next_state = 3'd1;
          add_x   = in_A;
        end
        else
          next_state = 3'd0;
      end

      3'd1:
      begin
        next_state = 3'd2;
        if (in_A_temp[C])
          shift_in = in_A;
        else
          add_y = 0;
      end

      3'd2:
      begin
        //O = temp_O;
        if (C == 3'd7)
          next_state = 3'd3;
        else
          next_state = 3'd1;
      end

      3'd3:
      begin
        //next_state = 3'd0;
        //Done = 1;
        if(expC == (in_B-8'd2))
          next_state = 3'd4;
        else
          next_state = 3'd1;
      end

      ///
      3'd4:
      begin
        O = in_A;
        Done = 1;
        next_state = 3'd0;
      end
      ////

      default:
      begin
        O = 16'd0;
        next_state = 3'd0;
      end

    endcase // current_state
  end

  // sequential
  always @(posedge clk)
  begin
    if (rst)
    begin
      current_state <= 3'd0;
      temp_O <= 16'd0;
    end
    else
      current_state <= next_state;

    case (current_state)
      3'd0:
      begin
        temp_O <= 16'd0;
        if (ld)
        begin
          in_A <= A;
          in_A_temp <= A;
          in_B <= B;
          C <= 3'b0;
          expC <= 8'd0;
        end
      end
      3'd1:
      begin
        C <= C + 3'b1;
        temp_O <= add_O;
      end

      3'd3:
      begin
        expC <= expC + 8'd1;
        in_A <= temp_O;
        temp_O <= 16'd0;
        C <= 3'b0;
      end

    endcase

  end
endmodule
