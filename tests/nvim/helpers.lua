local utils = {}

---Creates multiple stubs, clearing them after each `it` block. Returns a function for reverting all stubs
---@param stubs { [table]: string | number | string[] | number[] } List of tables with their keys to stub
---@return function
function utils.stubs(stubs)
  local stub = require("luassert.stub")

  -- Create stubs
  for module, keys in pairs(stubs) do
    if type(keys) == "string" or type(keys) == "number" then
      stub.new(module, keys)
    else
      for _, key in ipairs(keys) do
        stub.new(module, key)
      end
    end
  end

  -- Clear stubs
  after_each(function()
    for module, keys in pairs(stubs) do
      if type(keys) == "string" or type(keys) == "number" then
        module[keys]:clear()
      else
        for _, key in ipairs(keys) do
          module[key]:clear()
        end
      end
    end
  end)

  -- A function for reverting stubs
  return function()
    for module, keys in pairs(stubs) do
      if type(keys) == "string" or type(keys) == "number" then
        module[keys]:revert()
      else
        for _, key in ipairs(keys) do
          module[key]:revert()
        end
      end
    end
  end
end

return utils
