module main

import gg
import gx
import time
import math

enum AppState {
	play
	over
	victory
}

enum GameState {
	flag
	space
}

struct App {
mut:
	gg         &gg.Context
	ui         UI
	app_state  AppState  = .play
	game_state GameState = .space
	board      &Board
	touch      TouchInfo
}

fn new_app() &App {
	mut app := &App{
		board: &Board{}
		gg: &gg.Context{}
	}

	app.gg = gg.new_context(
		width: default_window_width
		height: default_window_height
		sample_count: 1
		create_window: true
		window_title: window_title
		frame_fn: frame
		event_fn: on_event
		init_fn: init
		user_data: app
		bg_color: app.ui.theme.bg_color
		font_path: app.ui.theme.font
	)

	return app
}

fn init(mut app App) {
	app.new_game()
	app.resize()
}

fn frame(mut app App) {
	app.gg.begin()
	app.draw()
	app.gg.end()
}

fn (mut app App) new_game() {
	app.board = new_board()
	app.ui.init_img(mut app.gg) or { panic(err) }

	app.app_state = .play
	app.game_state = .space
}

fn (mut app App) end_game(state AppState) {
	app.app_state = state

	if app.app_state == .over {
		app.board.open_all_tiles()
	}

	app.board.end_time = time.now()
}

fn (mut app App) draw() {
	app.draw_header()
	app.draw_tiles()
	match app.app_state {
		.over {
			app.draw_end_page('Game Over', 'Press `r` to restart')
		}
		.victory {
			app.draw_end_page('Congrat!', 'Press `r` to restart')
		}
		else {}
	}
}

fn (mut app App) draw_header() {
	text_cfg := app.ui.get_text_format('header', 0)
	header_y_pos := app.ui.y_padding - app.ui.header_size / 2

	now := if app.app_state != .play { app.board.end_time } else { time.now() }
	duration := time.Duration(now - app.board.init_time)
	mode_name := if app.game_state == GameState.flag { 'flag' } else { 'space' }

	// Timer
	app.gg.draw_text(app.ui.x_padding + app.ui.border_size, header_y_pos, 'Time: ${duration.str()} ',
		text_cfg)
	// Click Mode
	app.gg.draw_text(app.ui.x_padding + app.ui.board_size * 2 / 5, header_y_pos, 'Mode: ${mode_name}',
		text_cfg)
	// Points
	app.gg.draw_text(app.ui.x_padding + app.ui.board_size * 4 / 5, header_y_pos, 'Mines: ${app.board.flags.len}/${app.board.mines}',
		text_cfg)
}

fn (mut app App) draw_end_page(title string, description string) {
	padding_y := (app.ui.window_height - app.ui.font_size * 12) / 2
	padding_x := app.ui.window_width / 2

	app.gg.draw_text(padding_x, padding_y, title, app.ui.get_text_format('title', 0))
	app.gg.draw_text(padding_x, padding_y + app.ui.font_size * 4, description, app.ui.get_text_format('title',
		0))
}

// TODO: improve performance
fn (mut app App) draw_tiles() {
	bsize := app.ui.board_size + app.ui.border_size
	xstart := app.ui.x_padding + app.ui.border_size
	ystart := app.ui.y_padding + app.ui.border_size

	tile_size := app.ui.tile_size
	border_size := tile_size / 5

	// Draw Board
	app.gg.draw_rounded_rect_filled(xstart - tile_size / 2, ystart - tile_size / 2, bsize,
		bsize, bsize / 24, app.ui.theme.board_color)

	// Draw Tiles
	for y, row in app.board.cells {
		for x, cell in row {
			// Arguments values
			has_flag := app.board.flags.any(it.x == x && it.y == y)
			tile_point := if has_flag { -2 } else { cell }
			tile_text := app.ui.get_tile_text(tile_point)
			is_visible := app.board.cells_mask[y][x]
			color := if is_visible {
				if app.app_state == .over && tile_point == -1 {
					app.ui.theme.tile_gameover_mine_color
				} else {
					app.ui.theme.tile_open_color
				}
			} else {
				app.ui.theme.tile_close_color
			}

			// Rendered values
			tile_x_start := xstart + tile_size / 10 + x * tile_size
			tile_y_start := ystart + tile_size / 10 + y * tile_size
			t_size := tile_size - border_size

			app.gg.draw_rounded_rect_filled(tile_x_start, tile_y_start, t_size, t_size,
				tile_size / 8, color)

			if is_visible || has_flag {
				if tile_point < 0 {
					tile_img_x_start := tile_x_start + tile_size * 1 / 5
					tile_img_y_start := tile_y_start + tile_size * 1 / 5
					if tile_point == -2 {
						app.gg.draw_image(tile_img_x_start, tile_img_y_start, tile_size * 2 / 5,
							tile_size * 2 / 5, app.ui.flag_img)
					}
					if tile_point == -1 {
						app.gg.draw_image(tile_img_x_start, tile_img_y_start, tile_size * 2 / 5,
							tile_size * 2 / 5, app.ui.mine_img)
					}
				} else {
					tile_text_x_start := tile_x_start + tile_size * 2 / 5
					tile_text_y_start := tile_y_start + tile_size / 8
					tile_text_format := app.ui.get_text_format('tile', tile_point)
					app.gg.draw_text(tile_text_x_start, tile_text_y_start, tile_text,
						tile_text_format)
				}
			}
		}
	}

	if app.app_state != .play {
		app.gg.draw_square_filled(0, 0, f32(math.max(app.ui.window_width, app.ui.window_height)),
			gx.rgba(32, 42, 54, 96))
	}
}

fn (app App) snap_cell_points() [][][2]Pos {
	mut vb_cells := [][][2]Pos{}

	for y, row in app.board.cells {
		for x in row {
			start_x := app.ui.x_padding + app.ui.border_size + x * 11 * app.ui.tile_size / 10
			start_y := app.ui.y_padding + app.ui.border_size + y * 11 * app.ui.tile_size / 10

			vb_cells[y][x][0] = Pos{
				x: start_x
				y: start_y
			}

			vb_cells[y][x][1] = Pos{
				x: start_x + app.ui.tile_size
				y: start_y + app.ui.tile_size
			}
		}
	}

	return vb_cells
}

fn (mut app App) resize() {
	window_size := gg.window_size()
	w := window_size.width
	h := window_size.height
	min_edge := f32(math.min(w, h))

	app.ui.window_width = w
	app.ui.window_height = h
	app.ui.padding_size = int(min_edge / 36)
	app.ui.border_size = app.ui.padding_size * 2
	app.ui.font_size = app.ui.padding_size * 2 / 3

	app.ui.header_size = int(min_edge - app.ui.padding_size * 32)
	app.ui.board_size = int(min_edge - app.ui.padding_size * 2 * 4)
	app.ui.tile_size = app.ui.board_size / app.board.cells.len

	if w > h {
		app.ui.y_padding = app.ui.header_size
		app.ui.x_padding = (app.ui.window_width - app.ui.board_size - app.ui.border_size * 2) / 2
	} else {
		app.ui.y_padding = (app.ui.window_height + app.ui.header_size - app.ui.board_size - app.ui.border_size * 2) / 2
		app.ui.x_padding = (app.ui.window_width - app.ui.board_size - app.ui.border_size * 2) / 2
	}
}
