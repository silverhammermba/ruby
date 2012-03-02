#!/usr/local/bin/ruby
# rain for a curses test

require "curses"
include Curses

def ranf
<<<<<<< HEAD
	rand(32767).to_f / 32767
=======
  rand(32767).to_f / 32767
end

# main #
for i in %w[HUP INT QUIT TERM]
  if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
    trap(i) {|sig| onsig(sig) }
  end
>>>>>>> upstream/trunk
end

srand

init do |screen|
	nl = true
	echo = false
	curs_set 0

	r = screen.lines - 4
	c = screen.columns - 4
	ypos = Array.new(5) { (r * ranf).to_i + 2 }
	xpos = Array.new(5) { (c * ranf).to_i + 2 }

	i = 0
	while true
		y = (r * ranf).to_i + 2
		x = (c * ranf).to_i + 2

		screen.print(y, x, ".")

		screen.print(ypos[i], xpos[i], "o")

		i = (i - 1) % 5
		screen.print(ypos[i], xpos[i], "O")

		i = (i - 1) % 5
		screen.print(ypos[i] - 1, xpos[i],      "-")
		screen.print(ypos[i],     xpos[i] - 1, "|.|")
		screen.print(ypos[i] + 1, xpos[i],      "-")

		i = (i - 1) % 5
		screen.print(ypos[i] - 2, xpos[i],       "-")
		screen.print(ypos[i] - 1, xpos[i] - 1,  "/ \\")
		screen.print(ypos[i],     xpos[i] - 2, "| O |")
		screen.print(ypos[i] + 1, xpos[i] - 1, "\\ /")
		screen.print(ypos[i] + 2, xpos[i],       "-")

		i = (i - 1) % 5
		screen.print(ypos[i] - 2, xpos[i],       " ")
		screen.print(ypos[i] - 1, xpos[i] - 1,  "   ")
		screen.print(ypos[i],     xpos[i] - 2, "     ")
		screen.print(ypos[i] + 1, xpos[i] - 1,  "   ")
		screen.print(ypos[i] + 2, xpos[i],       " ")

		xpos[i] = x
		ypos[i] = y
		screen.refresh
		sleep(0.5)
	end
end
