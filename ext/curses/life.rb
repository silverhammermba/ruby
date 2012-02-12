#!/usr/local/bin/ruby
# Conway's game of life

require 'curses'

class CircArray < Array
	def [] i
		super(i % length)
	end
end

srand

Curses.init do |screen|
	Curses.echo = false
	Curses.start_color
	Curses.curs_set 0
	
	(0...8).each { |i| Curses.init_pair(i, i, i) }

	screen.keypad = true
	screen.timeout = 0

	def genesis
		return CircArray.new(Curses.stdscr.lines) do
		CircArray.new(Curses.stdscr.columns) { rand(2) * 7 }
		end
	end

	diff = genesis

	while (ch = screen.getc) != Curses::Key::F1
		diff = genesis if ch == Curses::Key::F2
		grid = CircArray.new(screen.lines) { |y| diff[y].dup }
		grid.each_with_index do |row, y|
			row.each_with_index do |cell, x|
				n = (grid[y - 1][x - 1] == 7 ? 1 : 0) +
					(grid[y - 1][x    ] == 7 ? 1 : 0) +
					(grid[y - 1][x + 1] == 7 ? 1 : 0) +
					(grid[y    ][x - 1] == 7 ? 1 : 0) +
					(grid[y    ][x + 1] == 7 ? 1 : 0) +
					(grid[y + 1][x - 1] == 7 ? 1 : 0) +
					(grid[y + 1][x    ] == 7 ? 1 : 0) +
					(grid[y + 1][x + 1] == 7 ? 1 : 0)

				diff[y][x] = cell
				if cell != 7
					if n == 3
						diff[y][x] = 7
					else
						diff[y][x] = (cell == 0 ? 0 : cell - 1)
					end
				elsif cell == 7 and not (2..3) === n
					diff[y][x] = cell - 1
				end

				screen.attron(Curses.color_pair(diff[y][x])) do
					screen.print(y, x, ' ')
				end
			end
		end

		screen.refresh
	end
end

