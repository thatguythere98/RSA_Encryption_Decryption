`timescale 1ns / 1ps

module mymodfunc (
    input   [15:0]  A,        // Input operand A
    input   [15:0]  B,        // Input operand B
    input           rst,      // Reset signal (active-high)
    input           clk,      // Clock signal
    input           ld,       // Load signal to start the operation
    output  reg     Done,     // Done signal indicating completion of modulus operation
    output  reg [15:0] O      // Output result of the modulus operation
  );

  // Internal registers and wires
  reg  [1:0]  current_state, next_state;  // Current and next state registers for the state machine
  reg  [15:0] in_A, in_B;                 // Registers to store inputs A and B
  wire [15:0] temp_O;                     // Wire to hold the result from the fullsubtractor module

  // Instantiate the full subtractor module
  // This module performs the subtraction between in_A and in_B
  fullsubtractor f(in_A, in_B, temp_O);   // Subtract in_B from in_A, result stored in temp_O

  // Combinational logic for state transitions and output logic
  always @(*)
  begin
    Done = 0;  // Default: Done signal is 0 (not done)

    case (current_state)
      2'd0:
      begin
        // Initial state: wait for the load signal (ld)
        if (ld)
        begin
          Done = 0;             // Clear the Done signal when starting
          next_state = 2'd1;    // Move to state 1 to begin subtraction
        end
        else
        begin
          next_state = 2'd0;    // Stay in the initial state if no load signal
        end
      end

      2'd1:
      begin
        // Subtraction state: perform the subtraction
        O = temp_O;             // Output the result of the subtraction (temp_O)

        if (temp_O < in_A)
        begin
          // If the result of subtraction (temp_O) is less than A
          next_state = 2'd0;    // Return to the initial state
          Done = 1;             // Set Done signal to indicate completion
        end
        else
        begin
          next_state = 2'd1;    // Otherwise, stay in the subtraction state
        end
      end

      default:
        next_state = 2'd0;  // Default case: return to the initial state
    endcase
  end

  // Sequential logic for state transitions and register updates
  always @(posedge clk)
  begin
    if (rst)
    begin
      // If reset is active, reset the state to the initial state
      current_state <= 2'd0;
    end
    else
    begin
      // Update the current state to the next state
      current_state <= next_state;
    end

    // Register updates based on the current state
    case (current_state)
      2'd0:
      begin
        // In the initial state, load the inputs A and B if ld is asserted
        if (ld)
        begin
          in_A <= A;            // Load input A into the internal register
          in_B <= B;            // Load input B into the internal register
        end
      end

      2'd1:
      begin
        // In the subtraction state, update B with the result of the subtraction
        in_B <= temp_O;          // Store the result of the subtraction (temp_O) back into in_B
      end
    endcase
  end

endmodule
