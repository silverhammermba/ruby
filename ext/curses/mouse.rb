#!/usr/local/bin/ruby

require "curses"
include Curses

def show_message(*msgs)
	message = msgs.join
	width = message.length + 6
	win = Window.new(5, width, (stdscr.lines - 5) / 2, (stdscr.columns - width) / 2)
	win.keypad = true
	win.attron(color_pair(COLOR_RED)) { win.box(?|, ?-, ?+) }
	win.print(2, 3, message)
	win.refresh
	win.getc
	win.close
end

init do |screen|
	start_color
	init_pair(COLOR_BLUE,COLOR_BLUE,COLOR_WHITE)
	init_pair(COLOR_RED,COLOR_RED,COLOR_WHITE)
	crmode = true
	echo = false
	screen.keypad = true

	begin
		Mouse.mask(Mouse::BUTTON1_CLICKED|Mouse::BUTTON2_CLICKED|Mouse::BUTTON3_CLICKED|Mouse::BUTTON4_CLICKED)
		screen.pos = (screen.lines - 5) / 2, (screen.columns - 10) / 2
		screen.attron(color_pair(COLOR_BLUE) | A_BOLD) { screen.print("click") }
		screen.refresh
		while true
			c = screen.getc
			case c
				when Key::MOUSE
				m = Mouse.get
				if( m )
					show_message("getch = #{c.inspect}, ",
					"mouse event = #{'0x%x' % m.bstate}, ",
					"axis = (#{m.x},#{m.y},#{m.z})")
				end
				#break
			end
		end
		screen.refresh
	ensure
		close
	end
end
