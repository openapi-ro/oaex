defmodule RegexTest do
  use ExUnit.Case
  test "testing some ordinary regex functions" do
    assert OA.Regex.regex?(~r/foo/)
    assert OA.Regex.regex?(0)==false
    assert OA.Regex.match?(~r/foo/, "foo")
    assert OA.Regex.match?(~r/foo/, "bar")==false
  end
  test "Index transposal/scan" do
    str = "ăîțâ"

    assert [["â"]] ==OA.Regex.scan(~r/â/u,str)
    assert [[{3,1}]] == OA.Regex.scan(~r/â/u,str, return: :string_index)
    [[{byte_from, _byte_len}]] = OA.Regex.scan(~r/â/u,str, return: :index)
    assert byte_from > 3

  end
  test "Index transposal/run" do
    str = "ăîțâ"

    assert ["â"] ==OA.Regex.run(~r/â/u,str)
    assert [{3,1}] == OA.Regex.run(~r/â/u,str, return: :string_index)
    [{byte_from, _byte_len}] = OA.Regex.run(~r/â/u,str, return: :index)
    assert byte_from > 3

  end
  test "Index transposal/name_captures" do
    str = "ăîțâ"

    assert %{"idina" =>"â"} ==OA.Regex.named_captures(~r/(?<idina>â)/u,str)
    assert %{"idina" =>{3,1}} == OA.Regex.named_captures(~r/(?<idina>â)/u,str, return: :string_index)
    %{"idina" => {byte_from, byte_len}} = OA.Regex.named_captures(~r/(?<idina>â)/u,str, return: :index)
    assert byte_from > 3 and is_integer(byte_from) and is_integer(byte_len)

  end
end