use github.com/muesli/elvish-libs/git
use str

glyph = [
	&git-branch= ""
	&git-ahead= "⬆"
	&git-behind= "⬇"
	&git-staged= "+"
	&git-dirty= "!"
	&git-untracked= "?"
	&git-deleted= "✘"
	&git-moved= "»"
	&sudo= "⚡"
	&chain= ""
]

colors = [
	&blue="#3daee9"
	&green="#469922"
	&grey="#393c3f"
]

edit:prompt = {
	fn raw-prompt-segment [fg-color bg-color @texts]{
		styled-segment (joins ' ' $texts) &fg-color=$fg-color &bg-color=$bg-color
	}
	fn prompt-segment [fg-color bg-color @texts]{
		styled-segment " "(joins ' ' $texts)" " &fg-color=$fg-color &bg-color=$bg-color
	}
	fn arrow [from-bg to-bg]{
		if (not-eq $to-bg "") {
			styled-segment $glyph[chain] &fg-color=$from-bg &bg-color=$to-bg
		} else {
			styled-segment $glyph[chain] &fg-color=$from-bg
		}
	}
	fn segment-directory []{
		display-pwd = [(str:split "/" (tilde-abbr $pwd))]
		prefix = ""
		if (> (count $display-pwd) 4) {
			prefix = "…/"
			display-pwd = $display-pwd[(- (count $display-pwd) 4):]
		}
		segment = [
			&content=$prefix(str:join "/" $display-pwd)
			&bg=$colors[blue]
			&fg="white"
		]
		put $segment
	}
	fn segment-git []{
		git-segments = []
		status = (git:status &counts=$true)
		if $status[is-git-repo] {
			git-segments = [$@git-segments $glyph[git-branch]" "$status[branch-name]]
			#
			# untracked files
			#
			if (> $status[untracked-count] 0) {
				git-segments = [$@git-segments $glyph[git-untracked]" "$status[untracked-count]]
			}
			#
			# deleted files
			#
			deleted-count = (+ $status[staged-deleted-count] $status[local-deleted-count])
			if (> $deleted-count 0) {
				git-segments = [$@git-segments $glyph[git-deleted]" "$deleted-count]
			}
			#
			# moved files
			#
			if (> $status[renamed-count] 0) {
				git-segments = [$@git-segments $glyph[git-moved]" "$status[renamed-count]]
			}
			#
			# staged modified/added files
			#
			mod-count = (+ $status[staged-modified-count] $status[staged-added-count])
			if (> $mod-count 0) {
				git-segments = [$@git-segments $glyph[git-staged]" "$mod-count]
			}
			#
			# ahead
			#
			if (> $status[rev-ahead] 0) {
				git-segments = [$@git-segments $glyph[git-ahead]" "$status[rev-ahead]]
			}
			#
			# behind
			#
			if (> $status[rev-behind] 0) {
				git-segments = [$@git-segments $glyph[git-behind]" "$status[rev-behind]]
			}
		}
		segment = [
			&content=(str:join " " $git-segments)
			&fg="white"
			&bg=$colors[green]
		]
		put $segment
	}
	segments = [(segment-directory) (segment-git)]
	non-blank-segments = []
	for segment $segments {
		if (not-eq $segment[content] "") {
			non-blank-segments = [$@non-blank-segments $segment]
		}
	}
	# first line
	raw-prompt-segment "white" $colors[grey] "╭"
	arrow $colors[grey] $non-blank-segments[0][bg]
	idx = (+ 0 0)
	for segment $non-blank-segments {
		prompt-segment $segment[fg] $segment[bg] $segment[content]
		if (eq $idx (- (count $non-blank-segments) 1)) {
			arrow $segment[bg] ""
		} else {
			arrow $segment[bg] $non-blank-segments[(+ $idx 1)][bg]
		}
		idx = (+ $idx 1)
	}
	# second line
	put "\n"
	raw-prompt-segment "white" "#393c3f" "╰"
	arrow "#393c3f" ""
	put " "
}

fn install-perm-prompt {
	echo "use github.com/pontaoski/melehte/hampë" >> ~/.elvish/rc.elv
}