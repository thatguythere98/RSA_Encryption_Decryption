`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 10/08/2024 09:53:15 PM
// Design Name:
// Module Name: tb_RSA
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module tb_RSA();
  reg clk,rst;
  reg start;
  reg [15:0] private_key, public_key, message_val;
  wire Cal_done;
  wire [15:0]Cal_val;


  rsa_module dut(private_key, public_key, message_val, clk, start, rst, Cal_done, Cal_val);


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
