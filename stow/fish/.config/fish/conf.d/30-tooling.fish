if status is-interactive
  if type -q direnv
    direnv hook fish | source
  end

  if type -q zoxide
    zoxide init fish | source
  end

  if type -q atuin
    atuin init fish --disable-up-arrow | source
  end

  if type -q gh
    gh completion -s fish | source
  end
end