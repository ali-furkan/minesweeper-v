module main

import os
import gg

fn main() {
	mut app := &App{}
	mut font_path := os.resource_abs_path(os.join_path('../', 'RobotoMono-Medium.ttf'))

	app.gg = gg.new_context(
		bg_color: app.ui.theme.bg_color
		width: default_window_width
		height: default_window_height
		sample_count: 1
		create_window: true
		window_title: window_title
		frame_fn: frame
		event_fn: on_event
		init_fn: init
		user_data: app
		font_path: font_path
	)

	app.gg.run()
}
