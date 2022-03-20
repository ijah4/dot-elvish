# DO NOT EDIT THIS FILE DIRECTLY
# This is a file generated from a literate programing source file located at
# https://gitlab.com/zzamboni/dot-elvish/-/blob/master/rc.org
# You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

use re

use readline-binding

use path

use str
use math

# Where all the Go stuff is
if (path:is-dir ~/Dropbox/Personal/devel/go) {
  set E:GOPATH = ~/Dropbox/Personal/devel/go
} else {
  set E:GOPATH = ~/go
}
# Optional paths, add only those that exist
var optpaths = [
  ~/.emacs.d/bin
  /usr/local/opt/coreutils/libexec/gnubin
  /usr/local/opt/texinfo/bin
  /usr/local/opt/python/libexec/bin
  /usr/local/go/bin
]
var optpaths-filtered = [(each {|p|
    if (path:is-dir $p) { put $p }
} $optpaths)]

set paths = [
  ~/bin
  $E:GOPATH/bin
  $@optpaths-filtered
  /usr/local/bin
  /usr/local/sbin
  /usr/sbin
  /sbin
  /usr/bin
  /bin
]

set E:GONOPROXY = "*"

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

use github.com/zzamboni/elvish-modules/proxy
set proxy:host = "http://aproxy.corproot.net:8080"

set proxy:test = {
  and ?(test -f /etc/resolv.conf) ^
  ?(egrep -q '^(search|domain).*(corproot.net|swissptt.ch)' /etc/resolv.conf)
}

proxy:autoset

set edit:insert:binding[Alt-Backspace] = $edit:kill-small-word-left~

set edit:insert:binding[Alt-d] = $edit:kill-small-word-right~

set edit:insert:binding[Alt-m] = $edit:-instant:start~

set edit:max-height = 20

use github.com/zzamboni/elvish-modules/1pass

use github.com/zzamboni/elvish-modules/lazy-vars

lazy-vars:add-var HOMEBREW_GITHUB_API_TOKEN { 1pass:get-password "github api token for homebrew" }
lazy-vars:add-alias brew [ HOMEBREW_GITHUB_API_TOKEN ]

set E:USER_750WORDS = diego@zzamboni.org
lazy-vars:add-var PASS_750WORDS { 1pass:get-password "750words.com" }
lazy-vars:add-alias 750words-client.py [ PASS_750WORDS ]

use github.com/zzamboni/elvish-modules/alias

fn have-external { |prog|
  put ?(which $prog >/dev/null 2>&1)
}
fn only-when-external { |prog lambda|
  if (have-external $prog) { $lambda }
}

only-when-external dfc {
  alias:new dfc e:dfc -p -/dev/disk1s4,devfs,map,com.apple.TimeMachine
}
only-when-external vagrant {
  alias:new v vagrant
}
only-when-external hub {
  alias:new git hub
}

only-when-external bat {
  alias:new cat bat
  alias:new more bat --paging always
  set E:MANPAGER = "sh -c 'col -bx | bat -l man -p'"
}

fn manpdf {|@cmds|
  each {|c|
    man -t $c | open -f -a /System/Applications/Preview.app
  } $cmds
}

use github.com/xiaq/edit.elv/smart-matcher
smart-matcher:apply

use github.com/zzamboni/elvish-completions/cd
use github.com/zzamboni/elvish-completions/ssh
use github.com/zzamboni/elvish-completions/builtins

use github.com/zzamboni/elvish-completions/git git-completions
only-when-external hub { set git-completions:git-command = hub }
git-completions:init

use github.com/zzamboni/elvish-completions/comp

#   eval (starship init elvish | sed 's/except/catch/')
# Temporary fix for use of except in the output of the Starship init code
eval (/usr/local/bin/starship init elvish --print-full-init | sed 's/except/catch/' | slurp)

set edit:prompt-stale-transform = {|x| styled $x "bright-black" }

set edit:-prompt-eagerness = 10

use github.com/zzamboni/elvish-modules/iterm2
iterm2:init
set edit:insert:binding[Ctrl-L] = $iterm2:clear-screen~

use github.com/zzamboni/elvish-modules/long-running-notifications

use github.com/zzamboni/elvish-modules/bang-bang

use github.com/zzamboni/elvish-modules/dir
alias:new cd &use=[github.com/zzamboni/elvish-modules/dir] dir:cd
alias:new cdb &use=[github.com/zzamboni/elvish-modules/dir] dir:cdb

set edit:insert:binding[Alt-i] = $dir:history-chooser~

set edit:insert:binding[Alt-b] = $dir:left-small-word-or-prev-dir~
set edit:insert:binding[Alt-f] = $dir:right-small-word-or-next-dir~

set edit:insert:binding[Ctrl-R] = {
  edit:histlist:start
  edit:histlist:toggle-case-sensitivity
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

use github.com/zzamboni/elvish-modules/leanpub
set leanpub:api-key-fn = { 1pass:get-item leanpub &fields=["API key"] }

use github.com/zzamboni/elvish-modules/tinytex

set E:LESS = "-i -R"

set E:EDITOR = "vim"

set E:LC_ALL = "en_US.UTF-8"

set E:PKG_CONFIG_PATH = "/usr/local/opt/icu4c/lib/pkgconfig"

use github.com/zzamboni/elvish-modules/git-summary gs

set gs:stop-gitstatusd-after-use = $true

var git-summary-repos-to-exclude = ['.emacs.d*' .cargo Library/Caches Dropbox/Personal/devel/go/src]
var git-summary-fd-exclude-opts = [(each {|d| put -E $d } $git-summary-repos-to-exclude)]
set gs:find-all-user-repos-fn = {
  fd -H -I -t d $@git-summary-fd-exclude-opts '^.git$' ~ | each $path:dir~
}

use github.com/zzamboni/elvish-modules/util

use github.com/muesli/elvish-libs/git

use github.com/iwoloschin/elvish-packages/update
set update:curl-timeout = 3
update:check-commit &verbose

use github.com/zzamboni/elvish-modules/util-edit
util-edit:electric-delimiters

use github.com/zzamboni/elvish-modules/spinners
use github.com/zzamboni/elvish-modules/tty
