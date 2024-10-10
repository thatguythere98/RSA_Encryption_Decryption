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

//How RSA parameters were chosen for this example

// 1. Modulus n (public key modulus):
//    The modulus n is the product of two prime numbers, p and q.
//    For this example, we assume p = 3 and q = 11, so the modulus n = p * q = 3 * 11 = 33.
//    The modulus n is part of the public key and is used in both encryption and decryption.

// 2. Euler's totient function φ(n):
//    φ(n) = (p - 1) * (q - 1), which in this case is φ(33) = (3 - 1) * (11 - 1) = 2 * 10 = 20.
//    This value is used to determine the private and public exponents (e and d).

// 3. Public exponent e (public key exponent):
//    The public exponent e must be coprime with φ(n), meaning gcd(e, φ(n)) = 1.
//    In this example, e = 3 is a small and commonly used value for public exponent, and it's coprime with φ(33) = 20.
//    This value is used during encryption to raise the message M to the power of e, modulo n.

// 4. Private exponent d (private key):
//    The private exponent d is the modular inverse of e mod φ(n), which satisfies (e * d) mod φ(n) = 1.
//    In this case, d = 7, because (3 * 7) mod 20 = 21 mod 20 = 1.
//    This private exponent is used during decryption to raise the ciphertext C to the power of d, modulo n.

// 5. Message M:
//    The message M to be encrypted must be smaller than the modulus n.
//    In this example, M = 9, which fits the requirement M < n (n = 33).

// 6. Encryption formula:
//    C = M^e mod n
//    Here, the message M is raised to the power of e (public exponent) and reduced modulo n to obtain the ciphertext C.
//    For example, C = 9^3 mod 33 = 729 mod 33 = 3.

// 7. Decryption formula:
//    M = C^d mod n
//    The ciphertext C is raised to the power of d (private exponent) and reduced modulo n to recover the original message M.
//    For example, M = 3^7 mod 33 = 2187 mod 33 = 9 (which is the original message).
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
