defmodule OA.Ecto.Schema do
  @doc """
  Returns a map containk the defined schema fields [key] and their types [value]
  """
  def types(schema_module) do
    schema_module.__schema__(:fields)
    |> Enum.map(fn field ->
      {field, schema_module.__schema__(:type, field)}
    end)
    |> Map.new()
  end
end
