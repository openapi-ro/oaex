defmodule OA.NumberSpeller do
  def spell(num, options\\[]) do
    language = Keyword.get(options, :language, :ro)
    module = language |> to_string() |> Macro.camelize()
    module = Module.concat(["OA", "NumberSpeller", module])
    module.spell(num,options)
  end
  def spell_currency(num, options) do
    language = Keyword.get(options, :language, :ro)
    module = language |> to_string() |> Macro.camelize()
    module = Module.concat(["OA", "NumberSpeller", module])
    module.spell_currency(num,options)
  end
end
