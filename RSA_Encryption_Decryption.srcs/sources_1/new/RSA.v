`timescale 1ns / 1ps

module rsa_module(input   [15:0]  private_key ,
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
