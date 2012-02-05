#!/usr/local/bin/ruby

require "curses"
include Curses

def show_message(message)
	width = message.length + 6
	win = Window.new(5, width, (stdscr.lines - 5) / 2, (stdscr.columns - width) / 2)
	win.box(?|, ?-)
	win.print(2, 3, message)
	win.refresh
	win.getc
	win.close
end

init do |screen|
	crmode = true
	screen.print((screen.lines - 5) / 2, (screen.columns - 10) / 2, "Hit any key")
	screen.refresh
	screen.getc
	show_message("Hello, World!")
	screen.refresh
end
