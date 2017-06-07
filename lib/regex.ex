
defmodule OA.Regex.Extender do
   defmacro extend(func_specs) do
    func_specs
    |> Enum.sort_by( &(elem(&1,0)))
    |> Enum.uniq_by(&elem(&1,0))
    |> Enum.map(fn {func, arity} ->
        args=
          1..arity
          |> Enum.map(&({String.to_atom("arg#{&1}"),[],Elixir}))
        quote do defdelegate unquote(func)(unquote_splicing(args)) ,  to: Regex end
      end)
   end
end
defmodule OA.Regex do
  @doc """
    Module shimming the `Elixir.Regex` module, but adding a return: :string_index option
    to `named_captures/2-3`, `run/2-3`, `scan/2-3`

    This option converts the byte limits to string character limits
  """
  require OA.Regex.Extender
  OA.Regex.Extender.extend([
    #__struct__: 0,
    #__struct__: 1,
    compile: 1,
    compile: 2,
    compile!: 1,
    compile!: 2,
    escape: 1,
    match?: 2,
    #named_captures: 2,
    #named_captures: 3,
    names: 1,
    opts: 1,
    re_pattern: 1,
    regex?: 1,
    replace: 3,
    replace: 4,
    run: 2,
    run: 3,
    scan: 2,
    scan: 3,
    source: 1,
    split: 2,
    split: 3,
    unescape_map: 1
    ] )
  def named_captures(regex, string, options \\ []), do: wrap(:named_captures, regex,string, options)
  def run(regex, string, options \\ []), do: wrap(:run, regex,string, options)
  def scan(regex, string, options \\ []), do: wrap(:scan, regex,string, options)

  def wrap(func_atom, regex, string, options) do
    {do_convert, options}=
      if options[:return]==:string_index do
        {true,Keyword.put(options,:return, :index)}
      else
        {false,options}
      end
    ret= apply( Elixir.Regex, func_atom, [regex, string, options] )
    if do_convert do
      convert_to_string_indexes(string, ret)
    else
      ret
    end
  end
  def convert_to_string_indexes(_str, []), do: []
  def convert_to_string_indexes(_str, nil), do: nil
  def convert_to_string_indexes(str,[head|rest]) do
    [convert_to_string_indexes(str,head) | convert_to_string_indexes(str,rest)]
  end
  def convert_to_string_indexes(str, {from, len}) when is_integer(from) and is_integer(len) do
    grapheme_match_indexes(str,{from,len})
  end
  def convert_to_string_indexes(str,%{}=named_map) do
    named_map
    |> Enum.reduce( named_map , fn
        {name, val} , acc ->
          Map.put(acc,  name, convert_to_string_indexes(str,val))
    end)
  end
  defp grapheme_match_indexes(str,{from, len}) when from >=0 and len >=0  do
    <<pre::binary-size(from), match::binary-size(len), _::binary>>=str
          {String.length(pre),
          String.length(match)}
  end
end