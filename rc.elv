# DO NOT EDIT THIS FILE DIRECTLY
# This is a file generated from a literate programing source file located at
# https://github.com/zzamboni/dot_elvish/blob/master/rc.org.
# You should make any changes there and regenerate it from Emacs org-mode using C-c C-v t

E:GOPATH = ~/Personal/devel/go/
paths = [
  ~/bin
  ~/Dropbox/Personal/devel/hammerspoon/spoon/bin
  ~/.gem/ruby/2.4.0/bin
  /opt/X11/bin
  /Library/TeX/texbin
  /usr/local/opt/node@6/bin
  /usr/local/bin
  /usr/local/sbin
  /usr/bin
  /bin
  /usr/sbin
  /sbin
  $E:GOPATH/bin
]

use dev/epm/epm

epm:install &silent-if-installed=$true `
  github.com/zzamboni/elvish-modules `
  github.com/zzamboni/elvish-completions `
  github.com/zzamboni/elvish-themes `
  github.com/xiaq/edit.elv

use re

use github.com/zzamboni/elvish-modules/prompt_hooks

use readline-binding

# Alt-backspace to delete word
edit:insert:binding[Alt-Backspace] = $edit:kill-small-word-left~
# Alt-d to delete the word under the cursor
edit:insert:binding[Alt-d] = { edit:move-dot-right-word; edit:kill-word-left }

use github.com/zzamboni/elvish-modules/nix
nix:multi-user-setup

use github.com/zzamboni/elvish-completions:git

use github.com/zzamboni/elvish-completions:vcsh

use github.com/zzamboni/elvish-themes/chain
edit:-prompts-max-wait = 0.01
chain:bold_prompt = $true
chain:setup

use github.com/zzamboni/elvish-modules/proxy
proxy:host = "http://proxy.corproot.net:8079"
proxy:setup_autoset

proxy:test = { and ?(test -f /etc/resolv.conf) ?(egrep -q '^(search|domain).*corproot.net' /etc/resolv.conf) }

use github.com/zzamboni/elvish-modules/long-running-notifications
long-running-notifications:setup

use narrow
narrow:bind-trigger-keys &location=Alt-l &lastcmd=""

use github.com/zzamboni/elvish-modules/bang-bang
bang-bang:bind-trigger-keys

use github.com/zzamboni/elvish-modules/dir
dir:setup
edit:insert:binding[Alt-b] = $dir:left-word-or-prev-dir~
edit:insert:binding[Alt-f] = $dir:right-word-or-next-dir~
edit:insert:binding[Alt-i] = $dir:history-chooser~
fn cd [@dir]{ dir:cd $@dir }
fn cdb [@dir]{ dir:cdb $@dir }

use github.com/zzamboni/elvish-modules/alias

fn set-title [title]{ print "\e]0;"$title"\e\\" }
prompt_hooks:add-before-readline {
  set-title "elvish "(tilde-abbr $pwd) > /dev/tty
}
prompt_hooks:add-after-readline [cmd]{
  set-title (re:split '\s' $cmd | take 1)" "(tilde-abbr $pwd)
}

private_loaded = ?(use private)

use github.com/zzamboni/elvish-modules/atlas

use github.com/xiaq/edit.elv/smart-matcher
edit:-matcher[''] = $smart-matcher:match~

E:LESS = "-i -R"
E:EDITOR = "vim"
E:LC_ALL = "en_US.UTF-8"

E:VAGRANT_INSTALLER_ENV = 1

fn dotify_string [str dotify_length]{
  if (or (== $dotify_length 0) (<= (count $str) $dotify_length)) {
    put $str
  } else {
    re:replace '(.{'$dotify_length'}).*' '$1…' $str
  }
}

fn pipesplit [l1 l2 l3]{
  pout = (pipe)
  perr = (pipe)
  run-parallel {
    $l1 > $pout 2> $perr
    pwclose $pout
    pwclose $perr
  } {
    $l2 < $pout
    prclose $pout
  } {
    $l3 < $perr
    prclose $perr
  }
}
