#!/usr/local/bin/ruby

require "curses"


# A curses based file viewer
class FileViewer

	# Create a new fileviewer, and view the file.
	def initialize(filename)
		@data_lines = []
		@screen = nil
		@top = nil
		init_curses
		load_file(filename)
		interact
	end

	# Perform the curses setup
	def init_curses
		@screen = Curses.init
		Curses.nl = false
		Curses.cbreak = true
		Curses.echo = false

		@screen.scroll = true
		@screen.keypad = true
	end

	# Load the file into memory, and put
	# the first part on the curses display.
	def load_file(filename)
		fp = open(filename, "r") do |fp|
			# slurp the file
			fp.each_line { |l| @data_lines.push(l.chop) }
		end
		@top = 0
		@data_lines[0..@screen.lines-1].each_with_index do |line, idx|
			@screen.print(idx, 0, line)
		end
		@screen.pos = 0, 0
		@screen.refresh
	rescue
		raise "cannot open file '#{filename}' for reading"
	end

	# Scroll the display up by one line
	def scroll_up
		if @top > 0
			@screen.scroll(-1)
			@top -= 1
			str = @data_lines[@top]
			if str
				@screen.pos = 0, 0
				@screen.print(str)
			end
			return true
		else
			return false
		end
	end

	# Scroll the display down by one line
	def scroll_down
		if @top + @screen.lines < @data_lines.length
			@screen.scroll(1)
			@top += 1
			str = @data_lines[@top + @screen.lines - 1]
			if str
				@screen.print(@screen.lines - 1, 0, str)
			end
			return true
		else
			return false
		end
	end

	# Allow the user to interact with the display.
	# This uses EMACS-like keybindings, and also
	# vi-like keybindings as well, except that left
	# and right move to the beginning and end of the
	# file, respectively.
	def interact
		while true
			result = true
			c = @screen.getc
			case c
			when Curses::Key::DOWN, Curses::Key::CTRL_N, ?j
				result = scroll_down
			when Curses::Key::UP, Curses::Key::CTRL_P, ?k
				result = scroll_up
			when Curses::Key::NPAGE, ?\s  # white space
				for i in 0..(@screen.lines - 2)
					if not scroll_down
						if( i == 0 )
							result = false
						end
						break
					end
				end
			when Curses::Key::PPAGE
				for i in 0..(@screen.lines - 2)
					if( ! scroll_up )
						if( i == 0 )
							result = false
						end
					break
				end
			end
			when Curses::Key::LEFT, Curses::Key::CTRL_T, ?h
				while scroll_up
				end
			when Curses::Key::RIGHT, Curses::Key::CTRL_B, ?l
				while scroll_down
				end
			when ?q
				break
			else
				@screen.print(0, 0, "[unknown key `#{Curses::Key.name(c)}'=#{c}] ")
			end
			if not result
				Curses.beep
			end
			@screen.pos = 0, 0
		end
		Curses.close
	end
end


# If we are being run as a main program...
if __FILE__ == $0
	if ARGV.size != 1
		STDERR.puts "usage: #{$0} file"
		exit
	end

	viewer = FileViewer.new(ARGV[0])
end
