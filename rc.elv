use path
use builtin
use readline-binding
use str
use math
use re

# Optional paths, add only those that exist
var optpaths = [
  ~/.emacs.d/bin
  #Unix
  /bin
  /sbin
  /usr/bin
  /usr/sbin
  /usr/local/bin
  /usr/local/sbin
  #windows
  "C:/Program Files (x86)/Common Files/Oracle/Java/javapath"
  c:/ProgramData/scoop/shims
  c:/ProgramData/scoop/apps/vscode/current
  c:\emacs\bin
  c:/windows/system32
  c:/windows
  c:/windows/System32/Wbem
  c:/windows/System32/WindowsPowerShell/v1.0
  c:/windows/System32/OpenSSH
  c:/Program Files/dotnet
  c:/msys64/mingw64/bin
  c:/Users/w/scoop/shims
]
var optpaths-filtered = [(each {|p|
      if (path:is-dir &follow-symlink $p) { put $p }
} $optpaths)]

set paths = [
  $@optpaths-filtered
]

each {|p|
  if (not (path:is-dir &follow-symlink $p)) {
    echo (styled "Warning: directory "$p" in $paths no longer exists." red)
  }
} $paths

use epm
epm:install &silent-if-installed         ^
github.com/zzamboni/elvish-modules     ^
github.com/zzamboni/elvish-completions ^
github.com/zzamboni/elvish-themes      ^
github.com/xiaq/edit.elv               ^
github.com/muesli/elvish-libs          ^
github.com/iwoloschin/elvish-packages

set edit:insert:binding[Alt-Backspace] = $edit:kill-small-word-left~

set edit:insert:binding[Alt-d] = $edit:kill-small-word-right~

set edit:insert:binding[Alt-m] = $edit:-instant:start~

set edit:max-height = 20

fn have-external { |prog|
  put ?(which $prog >/dev/null 2>&1)
}
fn only-when-external { |prog lambda|
  if (have-external $prog) { $lambda }
}

use github.com/zzamboni/elvish-modules/alias

only-when-external hub { alias:new git hub }

only-when-external bat {
  alias:new cat bat
  alias:new more bat --paging always
  set E:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
}

use github.com/xiaq/edit.elv/smart-matcher
smart-matcher:apply

# Enable the universal command completer if available.
# See https://github.com/rsteube/carapace-bin
if (has-external carapace) { eval (carapace _carapace | slurp) }

use github.com/zzamboni/elvish-completions/ssh

#   eval (starship init elvish | sed 's/except/catch/')
# Temporary fix for use of except in the output of the Starship init code
eval (starship init elvish --print-full-init | slurp)

set edit:prompt-stale-transform = {|x| styled $x "bright-black" }

set edit:-prompt-eagerness = 10

if (has-external zoxide) {
  eval (zoxide init elvish | slurp)
  fn __zoxide_zi {|@rest|
      var path
      try {
          fn item {|x| put [&to-show=$x &to-accept=$x &to-filter=$x] }
          set path = [(zoxide query -l $@rest | each $item~)]
      } catch e {
      } else {
          edit:listing:start-custom $path &accept=$builtin:cd~
      }
  }
  edit:add-var zi~ $__zoxide_zi~
}

#use github.com/zzamboni/elvish-modules/long-running-notifications

use github.com/zzamboni/elvish-modules/bang-bang

set edit:insert:binding[Ctrl-R] = {
  edit:histlist:start
  #edit:histlist:toggle-case-sensitivity
}

only-when-external exa {
  var exa-ls~ = { |@_args|
    use github.com/zzamboni/elvish-modules/util
    e:exa --color-scale --git --group-directories-first (each {|o|
        util:cond [
          { eq $o "-lrt" }  "-lsnew"
          { eq $o "-lrta" } "-alsnew"
          :else             $o
        ]
    } $_args)
  }
  edit:add-var ls~ $exa-ls~
}

use github.com/zzamboni/elvish-modules/terminal-title

var private-loaded = ?(use private)

use github.com/zzamboni/elvish-modules/atlas

use github.com/zzamboni/elvish-modules/opsgenie

use github.com/zzamboni/elvish-modules/tinytex

only-when-external pyenv {
  set paths = [ ~/.pyenv/shims $@paths ]
  set-env PYENV_SHELL elvish
}

set E:LESS = "-i -R"

set E:EDITOR = "vim"

set E:LC_ALL = "en_US.UTF-8"

# use github.com/zzamboni/elvish-modules/git-summary gs

# set gs:stop-gitstatusd-after-use = $true

# var git-summary-repos-to-exclude = ['.emacs.d*' .cargo Library/Caches Dropbox/Personal/devel/go/src]
# var git-summary-fd-exclude-opts = [(each {|d| put -E $d } $git-summary-repos-to-exclude)]
# set gs:find-all-user-repos-fn = {
#   fd -H -I -t d $@git-summary-fd-exclude-opts '^.git$' ~ | each $path:dir~
# }

use github.com/zzamboni/elvish-modules/util

use github.com/muesli/elvish-libs/git

# use github.com/iwoloschin/elvish-packages/update
# set update:curl-timeout = 3
# update:check-commit &verbose

use github.com/zzamboni/elvish-modules/util-edit
util-edit:electric-delimiters

use github.com/zzamboni/elvish-modules/spinners
use github.com/zzamboni/elvish-modules/tty