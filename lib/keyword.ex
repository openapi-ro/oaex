defmodule OA.Keyword do
  @type key :: any
  @type value :: any

  @type t :: [{key, value}]
  @type t(value) :: [{key, value}]

  use OA.KeywordMapCommon
  @doc """
    Merges two keyword lists by their keys, using `List.myers_difference/2`.

    All entries' _values_ for which the keys are identified as `:eq`  are merged using `&merge_fun/3`.
    All other `{key,value}` pairs are inserted unmodified.

    The *relative order*  of the input lists' elements is preserved in the merged list.

    Note that this function accepts `t:any/0` as key, not just `t:atom/0` (as in `t:Keyword.t/0`)
  """
  #@opaque key::any
  @spec myers_merge(
    t,
    t ,
    (key, left_val::value, right_val::value -> merged :: value)
    ) :: [{any, any}]
  def myers_merge( kwd1, kwd2, merge_fun) when is_list(kwd1) and is_list(kwd2) do
    {result, [], []} =
    List.myers_difference(Enum.map(kwd1, &extract_key/1) , Enum.map(kwd2, &extract_key/1))
    |> Enum.reduce( {[], kwd1, kwd2},  fn
      {:ins, keys}, {res,kwd1, kwd2} ->
        {insert, kwd2} = Enum.split(kwd2, length(keys))
        {res++insert, kwd1, kwd2 }
      {:del, keys}, {res,kwd1, kwd2} ->
          {insert, kwd1} = Enum.split(kwd1, length(keys))
        {res++insert, kwd1, kwd2 }
      {:eq, keys}, {res,kwd1, kwd2}->
        l=length(keys)
        {merge1, kwd1} =
          Enum.split(kwd1, l)
        {merge2, kwd2} =
          Enum.split(kwd2, l)
        merged=
          Enum.zip(merge1, merge2)
          |>Enum.map(fn {{key1, val1},{key1, val2}} -> 
            {key1, merge_fun.(key1, val1, val2)}
          end)
        {res++merged, kwd1, kwd2}
    end)
    result
  end
  @doc """
    Same as `myers_merge/3` but for a list of key-value lists.

    The lists contained in the `list` argument are merged by repeatedly merging the first two elements of the list until the list contains a single list

    Returns the merged list or `nil` if `list` argument is `[]`
  """
  @spec myers_merge(
    [t],
    (key, val1::value, val2::value -> merged :: value)
    ) :: [{any, any}]|nil
  def myers_merge([], _merge_fun), do:  nil
  def myers_merge([list], _merge_fun), do:  list
  def myers_merge([left,right|other], merge_fun) when is_list(left) and is_list(right) do
    myers_merge([ myers_merge(left,right, merge_fun) |other], merge_fun)
  end

  def extract_key({key, _val}) do
    key
  end
end