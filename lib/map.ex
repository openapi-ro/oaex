defmodule OA.Map do
  @type key :: any
  @type value :: any
  @type t :: %{key => value}
  use OA.KeywordMapCommon

  @doc """
  Apply the given tranformation to a nested map with string keys.
  The transformation is a map from dot-separated nested keys in the source
  to either a dot separated nested keys in the destination, or a tuple of
  the same plus a fallback value to be used if the map doesn't have a value for that key.

  Example:
      iex> map = %{"a" => %{"b" => 1}, "x" => %{"y" => 1}}
      iex> trans_map = %{"a.b" => "bla", "a.c" => {"foo", 42}, "x.y" => "i.j"}
      iex> OA.Map.transform_paths(map, trans_map)
      %{"bla" => 1, "foo" => 42, "i" => %{"j" => 1}}
  """
  def transform_paths(source = %{}, trans_map = %{}) do
    Enum.reduce trans_map, %{}, fn {k, v}, acc ->
      path = case v do
        {v, _} -> v |> String.split(".")
        v -> v |> String.split(".")
      end
      val = case v do
        {_, fallback} -> get_in(source, k |> String.split(".")) || fallback
        _ -> get_in(source, k |> String.split("."))
      end
      put_in_path(acc, path, val)
    end
  end

  @doc """
  Similar to `Kernel.put_in/3`, but [autovivificious](https://en.wikipedia.org/wiki/Autovivification)
  Example:
      iex> OA.Map.put_in_path(%{}, [:foo, "bar", :baz], 3)
      %{foo: %{"bar" => %{baz: 3}}}
  """
  def put_in_path(map = %{}, path, val, options \\ []) do
    force_list= Keyword.get(options, :force_list, false)
    state = {map, []}
    Enum.reduce(path, state, fn x, {acc, cursor} ->
      cursor = [ x | cursor ]
      final = length(cursor) == length(path)
      newval = case get_in(acc, Enum.reverse(cursor)) do
        h when is_list(h) -> [ val | h ]
        nil ->
          if final do
            if force_list, do: [val], else: val
          else
            %{}
          end
        h = %{} -> if final, do: [val, h], else: h
        h -> if final, do: [ val, h ], else: [h]
      end
      { put_in(acc, Enum.reverse(cursor), newval), cursor }
    end)
    |> fn x -> elem(x, 0) end.()
  end

  @doc """
  Like `Map.get/3` but works both interchangeably with both string and atom keys.
  """
  def get_string_or_atom(map, key, default \\ nil)
  def get_string_or_atom(%{} = map, key, default) when is_atom(key) do
    Map.get(map, key, Map.get(map, key |> to_string)) || default
  end
  def get_string_or_atom(%{} = map, key, default) when is_bitstring(key) do
    Map.get(map, key, Map.get(map, key |> OA.String.ensure_atom)) || default
  end

  @doc """
  Transform a map with string keys to a map with atom keys.
  """
  def atomize_keys(nil), do: nil
  def atomize_keys(struct = %{__struct__: _}), do: struct
  def atomize_keys(map = %{}) do
    for {k, v} <- map, into: %{}, do: {OA.String.ensure_atom(k), atomize_keys(v)}
  end
  def atomize_keys([head | rest]) do
    [atomize_keys(head) | atomize_keys(rest)]
  end
  def atomize_keys(not_map), do: not_map

  defdelegate ensure_atom_keys(map), to: __MODULE__, as: :atomize_keys
end