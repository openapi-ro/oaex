defmodule OA.List do
  @doc """
    Same as List.delete, but using a predicate

    `#{__MODULE__}.delete_by(list, fun)` stops at the position where `fun.(list_element)` returns truthy and returns
    the `list` without that element.
  """
  @spec delete_by(list, fun) :: list
  def delete_by(list, fun)
  def delete_by([item | list], fun) do
    if fun.(item) do
      list
    else
      [item| delete_by(list, fun)]
    end
  end
  def delete_by([], _item), do: []

end