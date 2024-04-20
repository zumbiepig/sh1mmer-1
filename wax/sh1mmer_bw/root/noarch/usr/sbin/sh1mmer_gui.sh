function setup() {
	stty -echo # turn off showing of input
	printf "\033[?25l" # turn off cursor so that it doesn't make holes in the image
	printf "\033[2J\033[H" # clear screen
	sleep 0.1
}

function cleanup() {
	printf "\033[2J\033[H" # clear screen
	printf "\033[?25h" # turn on cursor
	stty echo
}

function movecursor_generic() {
	printf "\033[$((3+$1));6H" # move cursor to correct place for sh1mmer menu
}

function movecursor_Credits() {
	printf "\033[$((10+$1));6H" # move cursor to correct place for sh1mmer menu
}

function showbg() {
	printf "\033]image:file=/usr/share/sh1mmer-assets/$1;scale=1\a" # display image
}

function cleargui() {
	printf "\033]box:color=0x00FFFFFF;size=530,200;offset=-250,-125\a"
}

function test() {
	setup
	showbg "Credits.png"
	movecursor_Credits 0
	echo -n "Test"
	sleep 1
	cleanup
}

