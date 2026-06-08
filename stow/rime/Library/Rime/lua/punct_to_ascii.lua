-- 输入 #、$ 时上屏当前组合并切换英文，然后输出对应半角符号
local PUNCT_BY_KEYCODE = {
  [0x23] = "#",
  [0x24] = "$",
}

local PUNCT_BY_REPR = {
  numbersign = "#",
  dollar = "$",
}

local function punct_char(key)
  local char = PUNCT_BY_KEYCODE[key.keycode]
  if char then
    return char
  end

  local repr = key:repr()
  char = PUNCT_BY_REPR[repr]
  if char then
    return char
  end

  local bare = repr:match("Shift%+(%a+)$")
  if bare then
    return PUNCT_BY_REPR[bare]
  end

  return nil
end

local function punct_to_ascii(key, env)
  if key:release() then
    return 2
  end

  local punct = punct_char(key)
  if not punct then
    return 2
  end

  local engine = env.engine
  local context = engine.context

  if context:get_option("ascii_mode") then
    return 2
  end

  if context:is_composing() then
    context:commit()
  end

  context:set_option("ascii_mode", true)
  engine:commit_text(punct)

  return 1
end

return punct_to_ascii
