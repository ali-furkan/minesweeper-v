module main

import gg
import time
import math

struct TouchInfo {
mut:
	start Touch
	end   Touch
}

struct Touch {
mut:
	pos  Pos
	time time.Time
}

struct Pos {
mut:
	x f64
	y f64
}

fn on_event(e &gg.Event, mut app App) {
	match e.typ {
		.resized, .restored, .resumed {
			app.resize()
		}
		.key_up {
			match e.key_code {
				.r {
					app.handle_restart()
				}
				.q {
					app.handle_click_mode()
				}
				else {}
			}
		}
		.touches_began {
			if e.num_touches > 0 {
				t := e.touches[0]
				app.touch.start = Touch{
					pos: Pos{
						x: int(t.pos_x / app.gg.scale)
						y: int(t.pos_y / app.gg.scale)
					}
					time: time.now()
				}
			}
		}
		.touches_ended {
			if e.num_touches > 0 {
				t := e.touches[0]
				app.touch.end = Touch{
					pos: Pos{
						x: int(t.pos_x / app.gg.scale)
						y: int(t.pos_y / app.gg.scale)
					}
					time: time.now()
				}
			}
			app.handle_touch(e)
		}
		.mouse_down {
			app.touch.start = Touch{
				pos: Pos{
					x: int(e.mouse_x / app.gg.scale)
					y: int(e.mouse_y / app.gg.scale)
				}
				time: time.now()
			}
		}
		.mouse_up {
			app.touch.end = Touch{
				pos: Pos{
					x: int(e.mouse_x / app.gg.scale)
					y: int(e.mouse_y / app.gg.scale)
				}
				time: time.now()
			}
			app.handle_touch(e)
		}
		else {}
	}
}

fn (mut app App) handle_restart() {
	app.new_game()
}

fn (mut app App) handle_click_mode() {
	if app.app_state == AppState.play {
		match app.game_state {
			.flag { app.game_state = GameState.space }
			.space { app.game_state = GameState.flag }
		}
	}
}

fn (mut app App) handle_touch(e &gg.Event) {
	len_x := math.abs(app.touch.start.pos.x - app.touch.end.pos.x)
	len_y := math.abs(app.touch.start.pos.y - app.touch.end.pos.y)

	press_duration := (app.touch.end.time - app.touch.start.time) / time.millisecond

	if math.sqrt(len_x * len_x + len_y * len_y) <= app.ui.tile_size && press_duration < 750 {
		match app.app_state {
			.play {
				app.handle_touch_cell(e)
			}
			.over, .victory {
				app.handle_restart()
			}
		}
	}
}

fn (mut app App) handle_touch_cell(e &gg.Event) {
	xstart := app.ui.x_padding + app.ui.border_size
	ystart := app.ui.y_padding + app.ui.border_size

	for y, row in app.board.cells {
		for x, _ in row {
			if app.board.cells_mask[y][x] {
				continue
			}

			tile_x_start := xstart + app.ui.tile_size / 10 + x * app.ui.tile_size
			tile_y_start := ystart + app.ui.tile_size / 10 + y * app.ui.tile_size
			tile_size := app.ui.tile_size * 4 / 5

			cell_start_point := Pos{
				x: tile_x_start
				y: tile_y_start
			}

			if app.is_pressed_box(app.touch.start.pos, cell_start_point, tile_size, tile_size) {
				// Flag Mode
				if app.game_state == .flag || e.mouse_button == .right {
					for i, flag in app.board.flags {
						if flag.x == x && flag.y == y {
							app.board.flags.delete(i)
							return
						}
					}
					if app.board.flags.len == app.board.mines {
						return
					}
					app.board.flags << Pos{x,y}
				}
				// Space Mode
				if app.game_state == .space && e.mouse_button == .left {
					if app.board.flags.any(it.x == x && it.y == y) {
						return
					}

					if app.board.cells[y][x] == -1 {
						app.end_game(AppState.over)
						return
					}
					app.board.handle_open_cell(x, y)
				}

				if app.board.check_win() {
					app.end_game(AppState.victory)
				}

				break
			}
		}
	}
}

fn (mut app App) is_pressed_box(touch_point Pos, cell_start_point Pos, cell_x_size f64, cell_y_size f64) bool {
	return
		app.is_between_point(touch_point.x, cell_start_point.x, cell_start_point.x + cell_x_size)
		&& app.is_between_point(touch_point.y, cell_start_point.y, cell_start_point.y + cell_y_size)
}

fn (mut app App) is_between_point(x f64, start_x f64, end_x f64) bool {
	return start_x < x && end_x > x
}
