module main

import os
import gx

// Theme
const theme = &Theme{
		bg_color: gx.rgb(32, 42, 54)
		board_color: gx.rgb(10, 14, 16)
		flag_color: gx.rgb(255, 0, 0)
		tile_close_color: gx.rgb(32, 42, 54)
		tile_open_color: gx.rgb(64, 81, 108)
		tile_colors: [
			gx.rgb(0, 0, 255),
			gx.rgb(0, 255, 0),
			gx.rgb(255, 0, 0),
			gx.rgb(31, 0, 127),
			gx.rgb(31, 127, 0),
			gx.rgb(127, 31, 0),
			gx.rgb(127, 31, 0),
		]
		text_color: gx.rgb(255, 255, 255)
		font: os.resource_abs_path("./assets/fonts/montserrat-regular.ttf")
	}

const (
	window_title          = 'V Minesweeper'
	default_window_width  = 544
	default_window_height = 560
)
