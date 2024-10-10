`timescale 1ns / 1ps

module rsa_module (
    input   [15:0]  private_key,    // Private key input for RSA calculation
    input   [15:0]  public_key,     // Public key input for RSA calculation
    input   [15:0]  message_val,    // Message value to be processed (encrypted or decrypted)
    input           clk,            // Clock signal
    input           start,          // Start signal to initiate the RSA operation
    input           rst,            // Reset signal (active-high)
    output  reg     Cal_done,       // Signal indicating RSA calculation is done
    output  reg [15:0] Cal_val      // Output value from the RSA process (result of encryption or decryption)
  );

  // State machine and internal registers
  reg  [2:0]  current_state, next_state;   // Current and next states of the FSM
  reg  [15:0] in_private_key, in_public_key, in_message_val; // Internal registers for the input keys and message
  wire [15:0] temp_O;                      // Intermediate output from the modulus function

  wire [15:0] exp_out;                     // Output from the exponentiation module
  wire exp_done, mod_done;                 // Signals indicating completion of exponentiation and modulus operations

  reg exp_ld, mod_ld;                      // Load signals for exponentiation and modulus operation

  // Exponentiation module instantiation
  myexp U1 (
          .A(in_message_val),
          .B(in_private_key),
          .rst(rst),
          .clk(clk),
          .ld(exp_ld),
          .Done(exp_done),
          .O(exp_out)
        );

  // Modular function module instantiation
  mymodfunc U2 (
              .A(in_public_key),
              .B(exp_out),
              .rst(rst),
              .clk(clk),
              .ld(mod_ld),
              .Done(mod_done),
              .O(temp_O)
            );

  // Combinational logic for state transitions and output logic
  always @(*)
  begin
    case (current_state)
      3'd0:
      begin
        Cal_done <= 1'b0;              // Clear done signal
        if (start)
        begin
          Cal_val <= 16'b0;            // Clear output
          Cal_done <= 1'b0;            // Clear done signal
          in_private_key <= private_key; // Capture input private key
          in_public_key <= public_key;  // Capture input public key
          in_message_val <= message_val; // Capture input message value
          next_state <= 3'd1;          // Transition to next state
        end
        else
        begin
          next_state <= 3'd0;          // Remain in idle state
        end
      end

      3'd1:
      begin
        exp_ld <= 1'b1;                // Enable exponentiation load signal
        next_state <= 3'd2;            // Move to next state for exponentiation
      end

      3'd2:
      begin
        exp_ld <= 1'b0;                // Disable exponentiation load signal
        if (exp_done)
        begin
          next_state <= 3'd3;          // If exponentiation done, move to modulus operation
        end
        else
        begin
          next_state <= 3'd2;          // Wait in current state until exponentiation is done
        end
      end

      3'd3:
      begin
        mod_ld <= 1'b1;                // Enable modulus load signal
        next_state <= 3'd4;            // Move to modulus operation state
      end

      3'd4:
      begin
        mod_ld <= 1'b0;                // Disable modulus load signal
        if (mod_done)
        begin
          next_state <= 3'd5;          // If modulus operation done, proceed to finish
        end
        else
        begin
          next_state <= 3'd4;          // Wait in current state until modulus is done
        end
      end

      3'd5:
      begin
        Cal_done <= 1'b1;              // Set done signal
        Cal_val <= temp_O;             // Output the result
        next_state = 3'd0;             // Return to idle state
      end

      default:
        next_state = 3'd0;      // Default case to handle unexpected states
    endcase
  end

  // Sequential logic for state machine and registers
  always @(posedge clk)
  begin
    if (rst)
    begin
      // Reset logic
      current_state <= 4'd0;           // Set state to idle
      next_state <= 4'd0;              // Set next state to idle
      in_private_key <= 16'b0;         // Clear private key register
      in_public_key <= 16'b0;          // Clear public key register
      in_message_val <= 16'b0;         // Clear message value register
      exp_ld <= 1'b0;                  // Clear exponentiation load signal
      mod_ld <= 1'b0;                  // Clear modulus load signal
      Cal_val <= 16'b0;                // Clear output value
      Cal_done <= 1'b0;                // Clear done signal
    end
    else
    begin
      current_state <= next_state;     // Update current state
    end
  end

endmodule
