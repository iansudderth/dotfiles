export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

#oh-my-zsh config
HYPHEN_INSENSITIVE="true"
zstyle ':omz:update' mode auto      # update automatically without asking
ENABLE_CORRECTION="true"
plugins=(
	git
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

#######################################
# ENV
#######################################

export TERM=xterm-256color
export EDITOR="nvim"

export FZF_DEFAULT_OPTS='--preview="bat --color=always {}"'

. "$HOME/.atuin/bin/env"

export PATH="$PATH:$HOME/.deno/bin/"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

export CLIPBOARD_THEME=ansi

#######################################
# ALIASES
#######################################

# quick edit for configs
alias zshconfig="nvim ~/.zshrc"
alias ohmyzsh="nvim ~/.oh-my-zsh/"
alias reload-shell="source $HOME/.zshrc"

# use bat for cat
alias cat="bat --color=always"

# use eza for ls & la
alias ls="eza --color=always --long --git --icons=always --no-time --no-user --no-permissions"

# use zoxide for cd
alias cd="z"

# find files with yazi
alias ff="yazi"

# use difft for diff
alias diff="difft"

# lazy crew
alias lzd="lazydocker"
alias lzg="lazygit"
alias lzk="k9s"

# please run last command with sudo
alias please="sudo !!"

#######################################
# Funcs
#######################################


# Use fd and fzf to get the args to a command.
# Works only with zsh
# Examples:
# f mv # To move files. You can write the destination after selecting the files.
# f 'echo Selected:'
# f 'echo Selected music:' --extension mp3
# fm rm # To rm files in current directory
f() {
    sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf)}" )
    test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
}

# Like f, but not recursive.
fm() f "$@" --max-depth 1

# Deps
alias fz="fzf-noempty --bind 'tab:toggle,shift-tab:toggle+beginning-of-line+kill-line,ctrl-j:toggle+beginning-of-line+kill-line,ctrl-t:top' --color=light -1 -m"
fzf-noempty () {
	local in="$(</dev/stdin)"
	test -z "$in" && (
		exit 130
	) || {
		ec "$in" | fzf "$@"
	}
}
ec () {
	if [[ -n $ZSH_VERSION ]]
	then
		print -r -- "$@"
	else
		echo -E -- "$@"
	fi
}

# use to fuzzy find applications and functions
fa() {
	_app=$( compgen -c | fzf --preview="" )
	print -z "$_app "
}

#######################################
# Config
#######################################

# fzf integration
source <(fzf --zsh)

# thefuck setup
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# zoxide to remember dirs
eval "$(zoxide init zsh)"

# starship for pretty prompts
eval "$(starship init zsh)"

# atuin for command history
eval "$(atuin init zsh)"

# setup pyenv
eval "$(pyenv init - zsh)"
