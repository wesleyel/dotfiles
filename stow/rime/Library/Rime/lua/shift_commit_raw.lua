-- Shift 单独按下并松开时，上屏当前原始输入（双拼码 / 英文），不切换 ascii_mode。
-- 配合 default.yaml 中 ascii_composer.switch_key.Shift_*: noop 使用。

local SHIFT_L = 0xffe1
local SHIFT_R = 0xffe2

local function shift_side(key)
  local kc = key.keycode
  if kc == SHIFT_L then
    return "Shift_L"
  end
  if kc == SHIFT_R then
    return "Shift_R"
  end
  return nil
end

local function processor(key, env)
  local state = env.shift_commit_raw
  if not state then
    state = { armed = false }
    env.shift_commit_raw = state
  end

  local side = shift_side(key)
  if not side then
    state.armed = false
    return 2
  end

  local engine = env.engine
  local context = engine.context

  if not key:release() then
    state.armed = true
    state.which = side
    return 2
  end

  if not state.armed or state.which ~= side then
    return 2
  end
  state.armed = false

  if not context:is_composing() then
    return 2
  end

  local raw = context.input
  if raw == nil or raw == "" then
    return 2
  end

  engine:commit_text(raw)
  context:clear()
  return 1
end

return processor
