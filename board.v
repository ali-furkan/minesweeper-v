module main

import rand
import time

const (
	cell_len  = 12 // Row and Column length of the board
	num_mines = 12 // Number of mines on the board
)

struct Board {
mut:
	cells      [cell_len][cell_len]int
	cells_mask [cell_len][cell_len]bool
	flags      []Pos
	checks     int
	mines      int
	end_time   time.Time
	init_time  time.Time
}

// Create a new board
fn new_board() &Board {
	mut board := &Board{}

	board.init_time = time.now()
	board.gen_map(cell_len, num_mines)

	return board
}

// Generate mine on map of the board
fn (mut board Board) gen_map(cells int, num_mines int) {
	board.mines = num_mines

	mut i := 0
	for i < num_mines {
		mine_x := rand.intn(cells - 1) or { 0 }
		mine_y := rand.intn(cells - 1) or { 0 }

		if board.cells[mine_y][mine_x] == -1 {
			continue
		}

		board.cells[mine_y][mine_x] = -1

		spawn board.set_mine_adjacent(mine_x, mine_y)
		i++
	}
}

// Set adjacent cells of the mine
fn (mut board Board) set_mine_adjacent(x int, y int) {
	// Increase one to adjacent cells where are located in the top or bottom row of the mine
	for i in 0 .. 3 {
		adjacent_x := x + (i - 1)
		// If cell is out of the board, skip it
		if adjacent_x > board.cells.len - 1 || adjacent_x < 0 {
			continue
		}

		if y > 0 && board.cells[y - 1][adjacent_x] != -1 {
			// add to up row
			board.cells[y - 1][adjacent_x]++
		}
		if board.cells.len - 1 - y > 0 && board.cells[y + 1][adjacent_x] != -1 {
			// add to down row
			board.cells[y + 1][adjacent_x]++
		}
	}

	// Increase one to adjacent cells where are located in the left or right of the mine

	// Right cells
	if board.cells[y].len - x - 1 > 0 && board.cells[y][x + 1] != -1 {
		board.cells[y][x + 1]++
	}
	// Left cells
	if x > 0 && board.cells[y][x - 1] != -1 {
		board.cells[y][x - 1]++
	}
}

// handle_open_cell opens the cell and if it is empty, opens adjacent cells
fn (mut board Board) handle_open_cell(x int, y int) {
	// If cell is opened, skip it
	if board.cells_mask[y][x] {
		return
	}
	board.cells_mask[y][x] = true
	board.checks++

	if board.cells[y][x] != 0 {
		return
	}

	for i in 0 .. 3 {
		adjacent_x := x + i - 1

		if adjacent_x > board.cells.len - 1 || adjacent_x < 0 {
			continue
		}

		if y > 0 {
			board.handle_open_cell(adjacent_x, y - 1)
		}

		if board.cells.len - 1 - y > 0 {
			board.handle_open_cell(adjacent_x, y + 1)
		}
	}

	if board.cells[y].len - x - 1 > 0 {
		board.handle_open_cell(x + 1, y)
	}

	if x > 0 {
		board.handle_open_cell(x - 1, y)
	}
}

fn (mut board Board) check_win() bool {
	return board.flags.len == board.mines
		&& board.cells.len * board.cells.len - board.checks == board.mines
}
