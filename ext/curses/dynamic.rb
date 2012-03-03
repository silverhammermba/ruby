#!/usr/bin/env ruby

require 'curses'

class Flex < Curses::Window
	# this class makes it easy to create Windows that automatically
	# move/resize themselves according to user-defined rules
	
	def initialize *init, &blk
		@init = init
		@size = blk
		super *@size[*@init]
	end

	def resize
		# automatically resize the window using @init or args, if
		# supplied
		ln, cl, tp, lf = @size[*@init]
		super ln, cl
		move tp, lf
		draw
	end

	def draw
		# should be overridden with define_draw
		clear
		refresh
	end

	def define_draw &blk
		# shortcut for overriding the draw method
		define_singleton_method :draw, blk
	end
end

Curses.init do

	# configure Curses
	Curses.curs_set 0
	Curses.echo = false

	# variables for storing program state
	file_list = []
	dir = Dir.new('.')

	# now we create an array of Flex Windows.
	windows = []

	# each is created with a block that returns the lines,
	# columns, top, left of the window
	windows << (left = Flex.new do
		# we need to use Curses.stdscr here because the stdscr object is
		# recreated whenever the terminal is resized
		[Curses.stdscr.lines - 1, Curses.stdscr.columns / 2, 0, 0]
	end)

	# each then defines a draw method which is called whenever
	# the window is resized
	left.define_draw do
		# note how this uses a closure to give the Flex object
		# access to file_list
		clear
		while file_list.length < lines and file = dir.read
			file_list << file
		end
		pos = 0, 0
		file_list[0...lines].each { |file| puts file[0...columns] }
		refresh
	end

	# a 1 column window for dividing the left and right halves
	windows << (divider = Flex.new(left) do
		# and this closure gives the divider Flex access to the left, so that it
		# can position itself properly
		[Curses.stdscr.lines - 1, 1, 0, left.columns]
	end)

	divider.define_draw do
		attron(Curses::A_REVERSE) do
			print 0, 0, ' ' * lines
		end
		refresh
	end

	windows << (right = Flex.new(left, divider) do
		[Curses.stdscr.lines - 1, Curses.stdscr.columns - left.columns - divider.columns,
			0, left.columns + divider.columns]
	end)

	right.define_draw do
		clear
		print 0, 0, "The right window."
		refresh
	end

	windows << (bottom = Flex.new(left) do
		[1, Curses.stdscr.columns, left.lines, 0]
	end)

	bottom.define_draw do
		clear
		attron(Curses::A_REVERSE) do
			print 0, 0, " " * columns
			print 0, 0, "Resize your terminal to see the magic!"
		end
		refresh
	end

	# draw the windows initially
	windows.each { |win| win.draw }

	while true
		case ch = left.getc
		when ?q
			Curses.close
			exit
		when Curses::Key::RESIZE
			windows.each { |win| win.resize }
		end
	end
end
