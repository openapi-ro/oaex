defmodule OA.Ecto.MigrationHelpers do
  @doc """
  This function creates drop statements when presented with a CREATE FUNCTION sql string
  ##EXAMPLE:
      iex(1)> Ecto.MigrationHelpers.drop_from_create("CREATE OR REPLACE FUNCTION openapi.combine( anyelement , anyelement) RETURNS anyelement AS  $$ SELECT $2 $$ LANGUAGE sql")
      "DROP FUNCTION IF EXISTS openapi.combine( anyelement , anyelement) "
  """
  def drop_from_create(func_def) do
    func_def
    |> String.replace(~r/RETURNS.*/s, "") # drops function body
    |> String.replace( ~r/CREATE\s+(OR\s+REPLACE)\s+FUNCTION/s , "DROP FUNCTION \\g{1}" ) #replace create with drop
    |> String.replace(~r/\s+OR\s+REPLACE/s , " IF EXISTS") # if a OR REPLACE existed then generate an IF EXISTS DROP
    |> String.replace(~r/.*DROP/s, "DROP")
    |> String.replace(~r/(DEFAULT|:=)[^,)]+/s, "") # Also remove default values in `field type DEFAULT default` and in `field type := default` notation
  end

  def drop_from_create_type(type_def) do
    ret =
      type_def
      |> String.replace( ~r/.*CREATE\s+TYPE\s+([^([:space:]]+).*/s , "DROP TYPE \\g{1}" )
    if ret == type_def do
      nil
    else
      ret
    end
  end
end