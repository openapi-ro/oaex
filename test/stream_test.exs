defmodule StreamTest do
  use ExUnit.Case
  test "3 elements permutation count" do
    perms=
      [1,2,3]
      |>OA.Stream.permutations()
      |> Enum.to_list
    assert length(perms) == 6
  end
  test "3 elements with one dublette permutation count" do
    perms=
      [1,2,2]
      |>OA.Stream.permutations()
      |> Enum.to_list
    assert length(perms) == 3
  end
  test "2 elements permutation count" do
    perms=
      [1,2]
      |>OA.Stream.permutations()
      |> Enum.to_list
    assert length(perms) == 2
  end
  test "2 elements with one dublette permutation count" do
    perms=
      [1,1]
      |>OA.Stream.permutations()
      |> Enum.to_list
    assert length(perms) == 1
  end

end