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
  @doc """
  creates a composite foreign key (with multiple keys).
  """
  def foreign_key(from_table, [_field1|_1]=from_fields, to_table, [_field2|_2]=to_fields, options ) do
    [from_table, to_table] =
      [from_table, to_table]
      |> Enum.map(&to_string/1)
    from_prefix =
      case Keyword.get(options, :from_prefix) do
        nil-> Keyword.get(options,:prefix,"")
        ""->""
        prefix-> "#{prefix}."
      end
      |> to_string()
    to_prefix =
      case Keyword.get(options, :to_prefix) do
        nil-> Keyword.get(options,:prefix,"")
        ""->""
        prefix-> "#{prefix}."
      end
      |> to_string()
    [from_prefix, to_prefix]=
      [from_prefix, to_prefix]
      |> Enum.map(&(&1 <> ".") )
    from_fields =
        from_fields
        |>Enum.map( &to_string/1)
        |>Enum.join(", ")
    to_fields =
      to_fields
      |>Enum.map( &to_string/1)
      |>Enum.join(", ")
    fk_name = String.replace(from_prefix,".","_") <>
      String.replace(from_fields, "," , "_") <> "_fk"
    fk_name = String.replace(fk_name, " ", "")
    Ecto.Migration.execute """
    ALTER TABLE #{from_prefix}#{from_table}
    ADD CONSTRAINT #{fk_name} FOREIGN KEY (#{from_fields})
    REFERENCES #{to_prefix}#{to_table} (#{to_fields});
    """,
    "ALTER TABLE #{from_prefix}#{from_table} DROP CONSTRAINT #{fk_name}"
  end
end
