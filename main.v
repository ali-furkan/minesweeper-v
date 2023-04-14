module main

import gg

fn main() {
	mut app := &App{gg: &gg.Context{}, board: new_board()}
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
		font_path: app.ui.theme.font
	)

	app.gg.run()
}
