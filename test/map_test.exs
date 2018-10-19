defmodule MapTest do
  import OA.Map
  use ExUnit.Case

  test "transform_paths" do
    source = %{"a" => %{"b" => 1}, "x" => %{"y" => 1}}
    transformation = %{"a.b" => "bla", "a.c" => {"foo", 42}, "x.y" => "i.j"}
    expected = %{"bla" => 1, "foo" => 42, "i" => %{"j" => 1}}
    assert transform_paths(source, transformation) == expected
  end

  test "put_in_path" do
    assert put_in_path(%{}, [:foo, "bar", :baz], 3) == %{foo: %{"bar" => %{baz: 3}}}
  end

  test "get_string_or_atom" do
    map = %{"foo" => 1, :bar => 5}
    assert get_string_or_atom(map, :foo) == 1
    assert get_string_or_atom(map, "bar") == 5
    assert get_string_or_atom(map, "zzz", 13) == 13
    assert get_string_or_atom(map, "not_found") == nil
  end

  test "stringify_keys" do
    map_with_atom_keys = %{foo: %{:bar => :baz, 3 => 3}}
    map_with_string_keys = %{"foo" => %{"bar" => :baz, 3 => 3}}
    map_with_mixed_keys = %{"foo" => %{:bar => :baz, 3 => 3}}

    res = [
      stringify_keys(map_with_atom_keys),
      stringify_keys(map_with_string_keys),
      stringify_keys(map_with_mixed_keys)
    ]
    assert res |> Enum.uniq === [map_with_atom_keys]
  end

  test "atomize_keys" do
    map_from_strings = %{"foo" => "bar"}
    map_from_atoms = %{foo: "foo"}
    assert atomize_keys(map_from_strings) == %{foo: "bar"}
    assert atomize_keys(map_from_atoms) == map_from_atoms
  end
end
