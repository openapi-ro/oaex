defmodule OA.Keyword do
  @type key :: any
  @type value :: any

  @type t :: [{key, value}]
  @type t(value) :: [{key, value}]

  use OA.KeywordMapCommon
  @doc """
    Merges two keyword lists by their keys, using `List.myers_difference/2`.

    All entries for which the keys are identified as `:eq`  are merged using `&merge_fun/3`.

    Note that this function accepts `t:any` as key, instead of `Keyword.t` which allows only `atom`
  """
  #@opaque key::any
  @spec myers_merge(
    t,
    t ,
    (key, val1::value, val2::value -> merged :: value)
    ) :: [{any, any}]
  def myers_merge( kwd1, kwd2, merge_fun) do
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
  def extract_key({key, _val}) do
    key
  end
end