`timescale 1ns / 1ps

module myexp (
    input   [15:0]  A,       // Input operand A
    input   [15:0]  B,       // Input operand B (exponent)
    input           rst,     // Reset signal (active-high)
    input           clk,     // Clock signal
    input           ld,      // Load signal to initialize values and start operation
    output  reg     Done,    // Done signal indicating completion of exponentiation
    output  reg [15:0] O     // Output result of exponentiation
  );

  // Internal registers and wires declaration
  reg  [2:0]  current_state, next_state;     // State machine registers (current and next states)
  reg  [15:0] in_A, in_A_temp;               // Internal registers to store input A and its temporary value
  reg  [15:0] in_B;                          // Internal register to store input B (exponent)
  reg  [3:0]  C;                             // Counter for bit-wise operations on A
  reg  [15:0] add_x, add_y;                  // Inputs to the adder module
  wire [15:0] add_O;                         // Output of the adder module
  reg  [15:0] temp_O;                        // Temporary register to hold intermediate results
  reg  [15:0] shift_in;                      // Input to the shifter module
  reg  [3:0]  shift_N;                       // Shift amount for the shifter module
  wire [15:0] shift_O;                       // Output of the shifter module

  reg [7:0] expC;                            // Exponentiation counter

  // Instantiate the full adder module (external module)
  fulladder f(
              .x(add_x),
              .y(add_y),
              .O(add_O)
            );

  // Instantiate the shifter module (external module)
  shifter s(
            .in(shift_in),
            .N(shift_N),
            .O(shift_O)
          );

  // Combinational logic block for state transitions and operations
  always @(*)
  begin
    add_x   = temp_O;         // Set adder input x to temporary output
    add_y   = shift_O;        // Set adder input y to the shifted result
    shift_in = 0;             // Initialize shifter input to 0
    shift_N = C;              // Shift amount is controlled by counter C
    Done = 0;                 // Clear Done signal by default

    case (current_state)
      3'd0:
      begin // Idle state, waiting for load signal
        if (ld)
        begin
          Done = 0;           // Clear Done signal on load
          next_state = 3'd1;  // Move to state 1 to start operations
          add_x = in_A;       // Initialize adder input x with input A
        end
        else
        begin
          next_state = 3'd0;  // Stay in idle state if no load signal
        end
      end

      3'd1:
      begin // Shift and add state
        next_state = 3'd2;    // Move to state 2 after shift and add
        if (in_A_temp[C])     // Check if the C-th bit of in_A_temp is set
          shift_in = in_A;    // Set shifter input to A
        else
          add_y = 0;          // Otherwise, set adder input y to 0
      end

      3'd2:
      begin // Continue addition
        if (C == 3'd7)        // If counter C reaches 7
          next_state = 3'd3;  // Move to state 3 to check exponentiation counter
        else
          next_state = 3'd1;  // Otherwise, loop back to state 1
      end

      3'd3:
      begin // Check if exponentiation is complete
        if (expC == (in_B - 8'd2))  // Compare expC with (B - 2)
          next_state = 3'd4;        // If exponentiation is complete, move to state 4
        else
          next_state = 3'd1;        // Otherwise, loop back to state 1 to continue
      end

      3'd4:
      begin // Final state, output the result
        O = in_A;            // Output the final value of A
        Done = 1;            // Set Done signal to indicate completion
        next_state = 3'd0;   // Return to idle state
      end

      default:
      begin // Default case to handle unexpected states
        O = 16'd0;           // Default output value
        next_state = 3'd0;   // Return to idle state
      end

    endcase
  end

  // Sequential logic block for state transitions and register updates
  always @(posedge clk)
  begin
    if (rst)
    begin
      // Reset all internal registers and state machine
      current_state <= 3'd0;      // Set initial state to idle
      temp_O <= 16'd0;            // Clear temporary output
    end
    else
    begin
      current_state <= next_state; // Update current state with next state
    end

    // State-specific register updates
    case (current_state)
      3'd0:
      begin // Idle state, initialize inputs on load
        temp_O <= 16'd0;          // Clear temporary output
        if (ld)
        begin
          in_A <= A;              // Latch input A
          in_A_temp <= A;         // Store temporary copy of A
          in_B <= B;              // Latch input B (exponent)
          C <= 3'b0;              // Initialize counter C to 0
          expC <= 8'd0;           // Initialize exponentiation counter expC
        end
      end

      3'd1:
      begin // Shift and add step
        C <= C + 3'b1;            // Increment counter C
        temp_O <= add_O;          // Store adder output in temp_O
      end

      3'd3:
      begin // Exponentiation update step
        expC <= expC + 8'd1;      // Increment exponentiation counter expC
        in_A <= temp_O;           // Update A with temp_O
        temp_O <= 16'd0;          // Reset temp_O for next iteration
        C <= 3'b0;                // Reset counter C for next round
      end

    endcase
  end

endmodule
