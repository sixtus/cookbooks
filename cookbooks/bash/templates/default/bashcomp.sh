# bash completion

_bashcomp_debian() {
	bash=${BASH_VERSION%.*}; bmajor=${bash%.*}; bminor=${bash#*.}

	if [ -n "$PS1" ]; then
		if [ $bmajor -eq 2 -a $bminor '>' 04 ] || [ $bmajor -gt 2 ]; then
			if [ -r /etc/bash_completion ]; then
				. /etc/bash_completion
			fi
		fi
	fi

	unset bash bminor bmajor
}

_bashcomp_gentoo() {
	# ensure that wanted completions are loaded if available
	CHANGED=0
	for w in $(<${_BASHRC_DIR}/bashcomp-modules); do
		if [[ -e ${EPREFIX}/etc/bash_completion.d/${w} || -e ~/.bash_completion.d/${w} ]]; then
			continue
		fi

		if [[ -e ${EPREFIX}/usr/share/bash-completion/${w} ]]; then
			if hash eselect 2>/dev/null; then
				eselect bashcomp enable ${w}
				CHANGED=1
			fi
		fi
	done

	# ensure to reload bash if bash completion has changed
	if [[ ${CHANGED} -eq 1 ]]; then
		unset CHANGED
		exec ${SHELL}
	fi

	unset CHANGED

	# Check for interactive bash and that we haven't already been sourced.
	if [ -n "$BASH_VERSION" -a -n "$PS1" -a -z "$BASH_COMPLETION_COMPAT_DIR" ]; then

		# Check for recent enough version of bash.
		if [ ${BASH_VERSINFO[0]} -gt 4 ] || \
		   [ ${BASH_VERSINFO[0]} -eq 4 -a ${BASH_VERSINFO[1]} -ge 1 ]; then
			[ -r "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion" ] && \
				. "${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
			if shopt -q progcomp && [ -r /usr/share/bash-completion/bash_completion ]; then
				# Source completion code.
				. /usr/share/bash-completion/bash_completion
			fi
		fi

	fi
}

_bashcomp_macos() {
	if [[ -d ${EPREFIX} ]]; then
		_bashcomp_gentoo
	fi

	if [[ -d /usr/local/Cellar ]]; then
		source /usr/local/etc/profile.d/bash_completion.sh
	fi
}

if type -t _bashcomp_${_DISTNAME} &>/dev/null; then
	_bashcomp_${_DISTNAME}
fi

export COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}
export FIGNORE=".o:~"
