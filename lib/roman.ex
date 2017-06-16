defmodule Roman do

  @roman_numerals [
    { 1000, "M"  },
    { 900 , "CM" },
    { 500 , "D"  },
    { 400 , "CD" },
    { 100 , "C"  },
    { 90  , "XC" },
    { 50  , "L"  },
    { 40  , "XL" },
    { 10  , "X"  },
    { 9   , "IX" },
    { 5   , "V"  },
    { 4   , "IV" },
    { 1   , "I"  },
  ]

  @doc """
  Convert the number to a roman number.
  taken from https://github.com/alxndr/exercism/tree/master/elixir/roman-numerals
  """
  @spec numerals(pos_integer) :: String.t
  def numerals(number) do
    numerals number, ""
  end

  @spec numerals(pos_integer, String.t) :: String.t
  defp numerals(0, string), do: string
  defp numerals(number, string) do
    {roman_number, roman_letter} =
      Enum.find(@roman_numerals, fn ({roman_n, _}) -> number >= roman_n end)
    numerals number - roman_number, "#{string}#{roman_letter}"
  end
  @doc """
    decodes a roman numeral string [or a charlist] to integer
    taken from http://rosettacode.org/wiki/Roman_numerals/Decode#Elixir
  """
  def decode(str) when is_bitstring(str) do 
    String.to_char_list(str)
    |> decode()
  end
  def decode([]), do: 0 
  def decode([x]), do: to_value(x)
  def decode([h1, h2 | rest]) do
    case {to_value(h1), to_value(h2)} do
      {v1, v2} when v1 < v2 -> v2 - v1 + decode(rest)
      {v1, v1} -> v1 + v1 + decode(rest)
      {v1, _} -> v1 + decode([h2 | rest])
    end
  end
  defp to_value(?M), do: 1000
  defp to_value(?D), do:  500
  defp to_value(?C), do:  100
  defp to_value(?L), do:   50
  defp to_value(?X), do:   10
  defp to_value(?V), do:    5
  defp to_value(?I), do:    1
end