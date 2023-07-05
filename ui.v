module main

import gx
import gg

struct UI {
mut:
	header_size   int
	tile_size     int
	board_size    int
	border_size   int
	padding_size  int
	font_size     int
	window_width  int
	window_height int
	x_padding     int
	y_padding     int
	mine_img      gg.Image
	flag_img      gg.Image
	theme         &Theme = default_theme
}

struct Theme {
	bg_color         gx.Color
	board_color      gx.Color
	tile_open_color  gx.Color
	tile_gameover_mine_color gx.Color
	tile_close_color gx.Color
	tile_colors      []gx.Color
	text_color       gx.Color
	flag_color       gx.Color
	font             string
	mine_img         string
	flag_img         string
}

enum TextFormat {
	header
	tile
	title
}

fn (mut ui UI) init_img(app_gg &gg.Context) ! {
	ui.mine_img = app_gg.create_image(ui.theme.mine_img)!
	ui.flag_img = app_gg.create_image(ui.theme.flag_img)!
}

fn (ui UI) get_text_format(f string, val int) gx.TextCfg {
	return match f {
		'header' {
			gx.TextCfg{
				color: ui.theme.text_color
				align: .left
				size: ui.font_size * 2
			}
		}
		'tile' {
			gx.TextCfg{
				color: ui.get_tile_color(val)
				align: .center
				size: ui.tile_size * 2 / 3
			}
		}
		'title' {
			gx.TextCfg{
				color: ui.theme.text_color
				align: .center
				size: ui.font_size * 2
			}
		}
		else {
			gx.TextCfg{
				color: ui.theme.text_color
				align: .left
				size: ui.font_size * 4
			}
		}
	}
}

fn (ui UI) get_tile_color(val int) gx.Color {
	return match val {
		-2 { ui.theme.flag_color }
		-1 { ui.theme.text_color }
		0 { ui.theme.bg_color }
		else { ui.theme.tile_colors[val] }
	}
}

fn (ui UI) get_tile_text(val int) string {
	return match val {
		-2 { 'f' }
		-1 { 'X' }
		0 { '' }
		else { '${val}' }
	}
}
