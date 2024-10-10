`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:       [Your Company Name]
// Engineer:      [Your Name]
//
// Create Date:   10/08/2024 09:53:15 PM
// Design Name:   RSA Encryption/Decryption Testbench
// Module Name:   tb_RSA
// Project Name:  RSA Encryption/Decryption System
// Target Devices: [Specify Target Device, e.g., FPGA, ASIC]
// Tool Versions: [Specify Tool Version, e.g., Vivado 2024.1]
// Description:   Testbench for simulating the RSA encryption and decryption
//                operations using an RSA module. It tests both encryption
//                (encoding) and decryption (decoding) using different keys
//                and message values.
//
// Dependencies:  rsa_module (Unit Under Test)
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// - The clock signal is generated with a period of 10ns.
// - Reset is applied at the beginning of both encryption and decryption tests.
// - Results are displayed using $display for verification of output.
//
//////////////////////////////////////////////////////////////////////////////////

module tb_RSA();

  // Declare testbench signals
  reg clk, rst;                           // Clock and reset signals
  reg start;                              // Start signal to initiate RSA process
  reg [15:0] private_key, public_key, message_val; // Input key and message signals
  wire Cal_done;                          // Done signal indicating process completion
  wire [15:0] Cal_val;                    // Output value after RSA operation

  // Instantiate the DUT (Device Under Test)
  rsa_module dut(
               .private_key(private_key),
               .public_key(public_key),
               .message_val(message_val),
               .clk(clk),
               .start(start),
               .rst(rst),
               .Cal_done(Cal_done),
               .Cal_val(Cal_val)
             );

  // Clock generation: toggles every 5ns
  always
    #5  clk =  !clk;

  // Initial block to simulate encryption and decryption tests
  initial
  begin
    // Test encryption process
    private_key = 16'd3;          // Set private key for encryption
    public_key = 16'd33;          // Set public key
    message_val = 16'd9;          // Set message to encrypt

    clk = 1'b0;                   // Initialize clock
    rst = 1'b1;                   // Assert reset

    #20 rst = 1'b0;               // De-assert reset after 20ns

    start = 1'b1;                 // Start encryption process
    #10 start = 1'b0;             // De-assert start after 10ns

    #1500;                        // Wait for encryption process to complete
    $display("Encoding...");      // Display message indicating encoding
    $display("Input private key = %d", private_key);  // Display input private key
    $display("Input public key = %d", public_key);    // Display input public key
    $display("Input message value = %d", message_val); // Display input message
    $display("Encrypted output value = %d\n\n", Cal_val); // Display encrypted output

    // Test decryption process
    private_key = 16'd7;          // Set private key for decryption
    public_key = 16'd33;          // Set public key
    message_val = 16'd3;          // Set message to decrypt

    clk = 1'b0;                   // Reinitialize clock
    rst = 1'b1;                   // Assert reset

    #20 rst = 1'b0;               // De-assert reset after 20ns

    start = 1'b1;                 // Start decryption process
    #10 start = 1'b0;             // De-assert start after 10ns

    #2000;                        // Wait for decryption process to complete
    $display("Decoding...");      // Display message indicating decoding
    $display("Input private key = %d", private_key);  // Display input private key
    $display("Input public key = %d", public_key);    // Display input public key
    $display("Input message value = %d", message_val); // Display input message
    $display("Decrypted output value = %d\n\n", Cal_val); // Display decrypted output

    $finish;                      // End simulation
  end

  // Monitor and display the current state of the DUT
  always @ (dut.current_state)
  begin
    $display("%0t Current State = %d\n", $time, dut.current_state);
  end

endmodule
