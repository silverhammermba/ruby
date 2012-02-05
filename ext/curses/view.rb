#!/usr/local/bin/ruby

require "curses"
include Curses

if ARGV.size != 1
	STDERR.puts "usage: #{$0} file"
	exit
end

fp = open(ARGV[0], "r")

init do |screen|
	screen.keypad = true
	nl = false
	cbreak = true
	echo = false

	# slurp the file
	data_lines = []
	fp.each_line { |l| data_lines.push(l) }
	fp.close


	lptr = 0
	while true
		i = 0
		while i < screen.lines
			screen.print(i, 0, data_lines[lptr + i])
			i += 1
		end
		screen.refresh

		explicit = false
		n = 0
		while true
			c = screen.getc
			if c =~ /[0-9]/
				n = 10 * n + c.to_i
			else
				break
			end
		end

		n = 1 if not explicit and n == 0

		case c
		when Key::DOWN
			i = 0
		while i < n
			if lptr + screen.lines < data_lines.size
				lptr += 1
			else
				break
			end
			i += 1
		end

		when Key::UP
			i = 0
		while i < n
			if lptr > 0
				lptr -= 1
			else
				break
			end
			i += 1
		end

		when "q"
			break
		end
	end
end
