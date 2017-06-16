defmodule OA.KeywordMapCommon do
  defmacro __using__(_args) do
    quote do
      @doc """
        Merges two keyword lists or Maps into one. This is a version of Keywords.merge which calls
        `func(k,:missing,val2}` and `func(k, val1, :missing)` for elements with no conflict to resolve

        All distinct keys, excluding all but the first of duplicated keys, given in any of `keywords1` or `keywords2` will be merged
        according to func
        There are no guarantees about the order of keys in the returned keyword.

        This Function can merge `Keyword` lists and `Map`s.
        ## Examples
            iex> Keyword.merge([a: 1, b: 2], [a: 3, d: 4], fn _k, v1, v2 ->
            ...>   v1 + v2
            ...> end)
            [b: 2, a: 4, d: 4]
            iex> Keyword.merge([a: 1, b: 2], [a: 3, d: 4, a: 5], fn :a, v1, v2 ->
            ...>  v1 + v2
            ...> end)
            [b: 2, a: 4, d: 4]
            iex> Keyword.merge([a: 1, b: 2, a: 3], [a: 3, d: 4, a: 5], fn :a, v1, v2 ->
            ...>  v1 + v2
            ...> end)
            [b: 2, a: 4, d: 4]

        NB: the doc has been first plagiarized from `Elixir.Map.merge/3` and than bastarded into the present form.
        """

      @spec merge_all(t, t, (key, value, value -> value)) :: t
      def merge_all(kw1, kw2, func) do
        module1=
        case kw1 do
          %{}-> Map
          kw1 when is_list(kw1) -> Keyword
        end
        module2=
        case kw2 do
          %{}-> Map
          kw2 when is_list(kw2) -> Keyword
        end
        kw1_k =
          kw1
          |>module1.keys()
          |>MapSet.new()
        kw2_k =
          kw2
          |>module2.keys()
          |>MapSet.new()
        ret =
          kw1_k
          |> MapSet.intersection(kw2_k)
          |> Enum.map(fn k -> {k, func.(k, kw1[k], kw2[k])} end)
        ret = ret ++
          (
          kw2_k
          |> MapSet.difference(kw1_k)
          |> Enum.map(fn k -> {k, func.(k, :missing, kw2[k])} end)
          )
        ret = ret ++
          (
          kw1_k
          |> MapSet.difference(kw2_k)
          |> Enum.map(fn k -> {k, func.(k, kw1[k], :missing)} end)
          )
      end
    end
  end
end