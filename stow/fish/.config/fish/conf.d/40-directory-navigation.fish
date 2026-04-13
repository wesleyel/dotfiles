function __dotfiles_cd_parent
  set -l parent (path dirname -- $PWD)

  if test "$PWD" = "$parent"
    return
  end

  cd "$parent"
  commandline -f repaint
end

function __dotfiles_cd_child
  set -l children (find -H . -mindepth 1 -maxdepth 1 -type d -print | string replace -r '^\./' '' | sort)

  if test (count $children) -eq 0
    return
  end

  set -l child

  if test (count $children) -eq 1
    set child $children[1]
  else
    if not type -q fzf
      return
    end

    set child (printf '%s\n' $children | fzf --height=40% --reverse --prompt='child dir > ')
    or return
  end

  cd "$child"
  commandline -f repaint
end

if status is-interactive
  set -l shift_up (printf '\e[1;2A')
  set -l shift_down (printf '\e[1;2B')

  for mode in default insert visual
    bind -M $mode $shift_up __dotfiles_cd_parent
    bind -M $mode $shift_down __dotfiles_cd_child
  end
end