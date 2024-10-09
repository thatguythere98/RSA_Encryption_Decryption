module proj2(input   [15:0]  private_key ,
               input  [15:0]  public_key ,
               input  [15:0]  message_val ,
               input          clk,
               input          start,
               input          rst,
               output  reg        Cal_done,
               output  reg [15:0] Cal_val
              );


  // regs and wires declaration
  reg  [2:0]  current_state, next_state;
  reg  [15:0]  in_private_key, in_public_key, in_message_val;
  wire  [15:0] temp_O; // register to store output

  wire [15:0] exp_out;
  wire exp_done, mod_done;

  reg exp_ld, mod_ld;

  // module instantiation
  myexp U1 (in_message_val, in_private_key, rst, clk, exp_ld, exp_done, exp_out);
  mymodfunc U2 (in_public_key , exp_out , rst, clk, mod_ld, mod_done, temp_O);

  // combinational
  always @(*)
  begin

    case (current_state)
      3'd0:
      begin //initial state
        Cal_done <= 1'b0;
        if (start)
        begin
          Cal_val <= 16'b0;
          Cal_done <= 1'b0;

          in_private_key <= private_key;
          in_public_key <= public_key;
          in_message_val <= message_val;

          next_state <= 3'd1;
        end
        else
        begin
          next_state <= 3'd0;
        end

      end
      3'd1:
      begin
        exp_ld <= 1'b1;
        next_state <= 3'd2;
      end
      3'd2:
      begin
        exp_ld <= 1'b0;
        if(exp_done)
        begin
          next_state <= 3'd3;
        end
        else
        begin
          next_state <= 3'd2;
        end

      end
      3'd3:
      begin

        mod_ld <= 1'b1;
        next_state <= 3'd4;

      end
      3'd4:
      begin
        mod_ld <= 1'b0;
        if(mod_done)
        begin

          next_state <= 3'd5;
        end
        else
        begin
          next_state <= 3'd4;
        end

      end
      3'd5:
      begin
        Cal_done <= 1'b1;

        Cal_val <= temp_O;
        next_state = 3'd0;

      end
      default:
        next_state = 3'd0;

    endcase // current_state
  end

  // sequential
  always @(posedge clk)
  begin
    if (rst)
    begin
      current_state <= 4'd0;
      next_state <= 4'd0;
      in_private_key <= 16'b0;
      in_public_key <= 16'b0;
      in_message_val <= 16'b0;
      exp_ld <= 1'b0;
      mod_ld <= 1'b0;

      Cal_val <= 16'b0;
      Cal_done <= 1'b0;
      //reset all registers
    end
    else
      current_state <= next_state;

  end

endmodule



module proj2_tb;
  reg clk,rst;
  reg start;
  reg [15:0] private_key, public_key, message_val;
  wire Cal_done;
  wire [15:0]Cal_val;


  proj2 dut(private_key, public_key, message_val, clk, start, rst, Cal_done, Cal_val);


  always
    #5  clk =  !clk;


  initial
  begin
    //encrypt
    private_key = 16'd3;
    public_key = 16'd33;
    message_val = 16'd9;



    clk=1'b0;
    rst=1'b1;


    #20 rst=1'b0;


    start = 1'b1;
    #10 start = 1'b0;

    #1500
     $display("Encoding...");
    $display("Input private key =  %d ", private_key);
    $display("Input public key =  %d ", public_key);
    $display("Input message key =  %d ", message_val);
    $display("Output value =  %d \n\n", Cal_val);

    //////////////////////////////////////////////

    //decrypt
    private_key = 16'd7;
    public_key = 16'd33;
    message_val = 16'd3;


    clk=1'b0;
    rst=1'b1;


    #20 rst=1'b0;

    start = 1'b1;
    #10 start = 1'b0;

    #2000
     $display("Decoding...");
    $display("Input private key =  %d ", private_key);
    $display("Input public key =  %d ", public_key);
    $display("Input message key =  %d ", message_val);
    $display("Output value =  %d \n\n", Cal_val);
    $finish;
  end


  always  @ (dut.current_state)
  begin
    $display("%0t Current State =  %d \n",$time ,dut.current_state);
  end




endmodule



module fullsubtractor(
    input [15:0] a,
    input [15:0] b,

    output [15:0] Out
  );

  assign Out =   b -  a;

endmodule

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


module fulladder
  (
    input [15:0] x,
    input [15:0] y,

    output [15:0] O
  );

  assign O =   y + x;

endmodule


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
