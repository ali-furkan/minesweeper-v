module main

import rand
import time

const (
	cell_len  = 12 // Board row/column length
	num_mines = 12
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

fn new_board() &Board {
	mut board := &Board{}

	board.init_time = time.now()
	board.gen_map(cell_len, num_mines)

	return board
}

fn (mut board Board) gen_map(cells int, num_mines int) {
	board.mines = num_mines

	mut i := 0
	for i < num_mines {
		mine_x := rand.intn(cells)
		mine_y := rand.intn(cells)

		if board.cells[mine_y][mine_x] == -1 {
			continue
		}

		board.cells[mine_y][mine_x] = -1

		go board.set_mine_adjacent(mine_x, mine_y)
		i++
	}
}

fn (mut board Board) set_mine_adjacent(x int, y int) {
	// If there's a row above/below the mine, add one to adjacent cells that above/below the mine
	for i in 0 .. 3 {
		adjacent_x := x + (i - 1)
		if adjacent_x > board.cells.len || adjacent_x < 0 {
			continue
		}

		if y > 0 && board.cells[y - 1][adjacent_x] != -1 {
			// add above row
			board.cells[y - 1][adjacent_x]++
		}
		if board.cells.len - 1 - y > 0 && board.cells[y + 1][adjacent_x] != -1 {
			// add below row
			board.cells[y + 1][adjacent_x]++
		}
	}

	// If there're cells to right or left the mine
	if board.cells[y].len - x - 1 > 0 && board.cells[y][x + 1] != -1 {
		// right cell
		board.cells[y][x + 1]++
	}
	if x > 0 && board.cells[y][x - 1] != -1 {
		// left cell
		board.cells[y][x - 1]++
	}
}

fn (mut board Board) handle_open_cell(x int, y int) {
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

		if adjacent_x > board.cells.len || adjacent_x < 0 {
			continue
		}

		if y > 0 {
			go board.handle_open_cell(adjacent_x, y - 1)
		}

		if board.cells.len - 1 - y > 0 {
			go board.handle_open_cell(adjacent_x, y + 1)
		}
	}

	if board.cells[y].len - x - 1 > 0 {
		go board.handle_open_cell(x + 1, y)
	}

	if x > 0 {
		go board.handle_open_cell(x - 1, y)
	}
}

fn (mut board Board) check_win() bool {
	return board.flags.len == board.mines && board.cells.len * board.cells.len - board.checks == board.mines
}
