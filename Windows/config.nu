# config.nu
#
# Installed by:
# version = "0.111.0"
#
# This file is used to override default Nushell settings, define
# (or import) custom commands, or run any other startup tasks.
# See https://www.nushell.sh/book/configuration.html
#
# Nushell sets "sensible defaults" for most configuration settings,
# so your `config.nu` only needs to override these defaults if desired.
#
# You can open this file in your default editor using:
#     config nu
#
# You can also pretty-print and page through the documentation for configuration
# options using:
#     config nu --doc | nu-highlight | less -R

# Initialization
use ~/.config/starship.nu
use ~/.config/zoxide.nu

# Alias
alias ll = eza -l --icons --git
alias la = eza -la --icons --git
alias lt = eza --tree --level=2 --icons
alias cat = bat
alias vi = nvim
alias vim = nvim
alias gs = git status
alias gp = git push
alias gl = git pull
alias glog = git log --oneline --graph --decorate --all

# Functions
def ga [...args] { git add ...$args }
def gc [...args] { git commit -m ...$args }

def .. [] { cd ..}
def ... [] { cd ../.. }
def .... [] { cd ../../.. }

def prof [] { nvim $nu.config-path }
def reload [] { exec nu }

def sysinfo [] {
    print $"(ansi cyan)OS:(ansi reset)  (sys host | get long_os_version)"
    print $"(ansi cyan)CPU:(ansi reset) (sys cpu | first | get brand)"
    print $"(ansi cyan)RAM:(ansi reset) (sys mem | get total)"
}

# Key Binding
$env.config.keybindings = [
    # Ctrl+r - fzf History search
    {
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --replace (history | each { |it| $it.command} | reverse | uniq | str join (char nl) | fzf | str trim)"
        }
    }
    # Ctrl+t - fzf File search
    {
        name: fzf_file
        modifier: control
        keycode: char_t
        mode: [emacs, vi_normal, vi_insert]
        event: {
            send: executehostcommand
            cmd: "commandline edit --insert (fzf | str trim)"
        }
    }
]

# env
$env.config.shell_integration = {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false
    osc133: false
    osc633: true
    reset_application_mode: true
}

# Remove Welcome
$env.config.show_banner = false