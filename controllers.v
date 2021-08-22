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
						x: int(t.pos_x)
						y: int(t.pos_y)
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
						x: int(t.pos_x)
						y: int(t.pos_y)
					}
					time: time.now()
				}
			}
			app.handle_touch()
		}
		.mouse_down {
			app.touch.start = Touch{
				pos: Pos{
					x: int(e.mouse_x)
					y: int(e.mouse_y)
				}
				time: time.now()
			}
		}
		.mouse_up {
			app.touch.end = Touch{
				pos: Pos{
					x: int(e.mouse_x)
					y: int(e.mouse_y)
				}
				time: time.now()
			}
			app.handle_touch()
		}
		else {}
	}
}

fn (mut app App) handle_restart() {
	match app.app_state {
		.over, .victory {
			app.new_game()
		}
		else {}
	}
}

fn (mut app App) handle_click_mode() {
	if app.app_state == AppState.play {
		match app.game_state {
			.flag { app.game_state = GameState.space }
			.space { app.game_state = GameState.flag }
		}
	}
}

fn (mut app App) handle_touch() {
	len_x := math.abs(app.touch.start.pos.x - app.touch.end.pos.x)
	len_y := math.abs(app.touch.start.pos.y - app.touch.end.pos.y)

	press_duration := (app.touch.end.time - app.touch.start.time) / time.millisecond

	if math.sqrt(len_x * len_x + len_y * len_y) <= app.ui.tile_size && press_duration < 750 {
		match app.app_state {
			.play {
				app.handle_touch_cell()
			}
			.over, .victory {
				app.handle_restart()
			}
		}
	}
}

fn (mut app App) handle_touch_cell() {
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
				match app.game_state {
					.flag {
						checks << Pos {
							x: x
							y: y
						}
					}
					.space {
						if app.board.cells[y][x] == -1 {
							app.end_game(AppState.over)
						} else {
							app.board.handle_open_cell(x, y)
						}
					}
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
