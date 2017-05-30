defmodule OA.Enum do
  def permutations(enumerable) do
    enumerable
    |>OA.Stream.permutations()
    |>Enum.to_list
  end
end