module main

import os
import gg

// Default theme
const default_theme = &Theme{
	bg_color:                 gg.rgb(32, 42, 54)
	board_color:              gg.rgb(10, 14, 16)
	tile_close_color:         gg.rgb(32, 42, 54)
	tile_open_color:          gg.rgb(64, 81, 108)
	tile_gameover_mine_color: gg.rgb(128, 16, 16)
	tile_colors:              [
		gg.rgb(0, 0, 255),
		gg.rgb(0, 255, 0),
		gg.rgb(255, 0, 0),
		gg.rgb(31, 0, 127),
		gg.rgb(31, 127, 0),
		gg.rgb(127, 31, 0),
		gg.rgb(127, 31, 0),
	]
	text_color:               gg.rgb(255, 255, 255)
	font:                     os.resource_abs_path('./assets/fonts/TitilliumWeb-Black.ttf')
	mine_img:                 os.resource_abs_path('./assets/bomb.png')
	flag_img:                 os.resource_abs_path('./assets/flag.png')
}

const window_title = 'V Minesweeper'
const default_window_width = 544
const default_window_height = 560
