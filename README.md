# AI vs User Tic-Tac-Toe on FPGA

This project implements a Tic-Tac-Toe game where an AI player competes against a human player on an FPGA board. The game utilizes a VGA monitor for graphical output and FPGA switches and buttons for user input. The AI player is powered by the minimax algorithm with alpha-beta pruning for efficient move computation.

## Features

- AI vs User gameplay: Pit your skills against an AI opponent or play against a friend.
- VGA Graphics: Enjoy the game on a VGA monitor with clear and crisp graphics.
- FPGA Interfacing: Use switches and buttons on the FPGA board for user moves.
- Minimax with Alpha-Beta Pruning: The AI player employs an optimized algorithm for strategic move selection.
- Resource Optimization: Due to limitations on the Nexys 3 FPGA board, the algorithm does not fully search the game tree. Resource constraints necessitate folding and retiming the circuit for enhanced performance.

## Code Structure
- **top**: Top-level module that integrates VGA, user input, and Tic-Tac-Toe logic.
- **button**: Module to handle button input debouncing.
- **eval**: Function to evaluate the current game state.
- **findmove**: Function to find the best move using minimax and alpha-beta pruning.
- **findmoveRecursive**: Recursive function for minimax with alpha-beta pruning.

## Gameplay Instructions

- Connect your VGA monitor to the FPGA board.
- Use the FPGA switches and buttons to make your moves.
- The LED indicators show the game status: Player 1 wins (LED 0), Player 2 wins (LED 1), Draw (LED 2).
- Enjoy the classic Tic-Tac-Toe experience with an added challenge against the AI.

## How to Run

1. Set up your FPGA board with the necessary connections.
2. Compile and synthesize the Verilog code provided.
3. Upload the synthesized design to your FPGA board.
4. Connect your VGA monitor and power up the board.
5. Start the game and enjoy!

## Credits

- This project was inspired by the [Basys3_VGA_Testbench](https://github.com/ColtonBeery/Basys3_VGA_Testbench) repository, which provided guidance for VGA graphics implementation.

## Additional Notes

- **Algorithm Performance:** The minimax algorithm with alpha-beta pruning ensures efficient move selection. However, due to resource limitations, the algorithm may not fully explore the game tree.
- **Optimization Opportunities:** Consider folding and retiming the circuit to optimize resource utilization and enhance gameplay experience on the Nexys 3 FPGA board.

#
_Documented by ChatGPT_
