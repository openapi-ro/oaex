defmodule OA.Keyword do
  @type key :: atom
  @type value :: any

  @type t :: [{key, value}]
  @type t(value) :: [{key, value}]

  use OA.KeywordMapCommon


end