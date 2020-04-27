defmodule OA.NumberSpeller.Ro do
  def spell_currency(amount), do: spell_currency(amount, [])
  def spell_currency(amount, options) when is_integer(amount), do: spell_currency(amount*1.0, options)
  def spell_currency(amount, options) when is_float(amount) do
    currency_symbol = Keyword.get(options, :currency_symbol, "lei")
    cent_symbol_singular = Keyword.get(options, :cent_symbol_singular, "ban")
    cent_symbol = Keyword.get(options, :cent_symbol, "bani")
    bani =
    (amount*100)
    |> Float.round()
    |> Kernel.floor()
    ron = Integer.floor_div(bani, 100)
    bani = Integer.mod(bani, 100)
    if is_nil(ron) do
      require IEx
      IEx.pry
    end
    case bani do
      0-> d2t(ron) <>" #{currency_symbol}"
      1 -> d2t(ron) <>" #{currency_symbol} " <> d2t(bani) <> " #{cent_symbol_singular}"
      bani when bani < 20 -> d2t(ron) <>" #{currency_symbol} și " <> d2t(bani) <> " #{cent_symbol}"
      bani -> d2t(ron) <>" #{currency_symbol} și " <> d2t(bani) <> " de #{cent_symbol}"

    end
  end
  def spell(num), do: spell(num, [])
  def spell(num, options) when is_integer(num) do
    split = Keyword.get(options,:split, " ")
    d2t(num)
  end
  def spell(num, options) when is_float(num) do
    split = Keyword.get(options, :split, " ")
    [int, after_comma] = "#{num}"|> String.split(".")
    int =
      String.to_integer(int)
    after_comma =
      after_comma
      |> String.slice(0..5)
    after_comma_prec = String.length(after_comma)
    after_comma = String.to_integer(after_comma)
    if after_comma == 0 do
      d2t(int)
    else
      d2t(int) <> " și " <>   d2t(after_comma) <> comma_fraction(after_comma_prec)
    end
  end
  def comma_fraction(1), do: " de zecimi"
  def comma_fraction(2), do: " de sutimi"
  def comma_fraction(3), do: " de miimi"
  def comma_fraction(4), do: " de zeci de miimi"
  def comma_fraction(5), do: " de sute de miimi"
  @digits %{
    1=> "unu",
    2=> "doi",
    3=> "trei",
    4=> "patru",
    5=> "cinci",
    6=> "șase",
    7=> "șapte",
    8=> "opt",
    9=> "nouă",
    10=>"zece",
    11=>"unsprezece",
    12=>"douăsprezece",
    13=> "treisprezece",
    14=> "paișprezece",
    15=> "cincisprezece",
    16=> "șaisprezece",
    17=> "șaptesprezece",
    18=> "optsprezece",
    19=> "nouăsprezece"
  }
  @tens %{
    2=> "douăzeci",
    6=> "șaizeci"
  }
  @hundreds %{
    1=> "o sută",
    2=> "două sute"
  }
  @thousends %{
    1 => "o mie",
    2 => "două mii"
  }
  @millions %{
    1 => "un milion",
    2 => "două milioane"
  }
  @billions %{
    1 => "un miliard",
    2 => "două miliarde"
  }
  @trillions %{
    1 => "un biliard",
    2 => "două biliarde"
  }
  def split_mod(num, mod) do
    {
      Integer.floor_div(num, mod),
      Integer.mod(num,mod)
    }
  end
  def d2t(0), do: "zero"
  def d2t( num) when num < 20,  do: @digits[num]
  def d2t( num) when num < 100 do
    case split_mod(num, 10) do
      {tens, 0} -> Map.get_lazy( @tens , tens, fn -> d2t(tens) <>"zeci" end)
      {tens, unary} -> Map.get_lazy( @tens , tens, fn -> d2t(tens) <>"zeci" end) <> " și " <> d2t(unary)
    end
  end
  def d2t(num) when num < 1_000 do
    case split_mod(num, 100) do
      {hundreds, 0} -> Map.get_lazy( @hundreds , hundreds, fn -> d2t(hundreds) <>" sute" end)
      {hundreds, below} -> Map.get_lazy( @hundreds , hundreds, fn -> d2t(hundreds) <>" sute" end) <> " " <> d2t(below)
    end
  end
  def qualifier(num, qualifier) when num < 20,  do: " #{qualifier}"
  def qualifier(num, qualifier) ,  do: " de #{qualifier}"
  def d2t(num) when num < 1_000_000 do
    case split_mod(num, 1000) do
      {thousends, 0} -> Map.get_lazy( @thousends , thousends, fn ->
          d2t(thousends) <> qualifier(thousends, "mii")
        end)
      {thousends, below} -> Map.get_lazy( @thousends , thousends, fn ->
        d2t(thousends) <> qualifier(thousends, "mii")
      end) <> " " <> d2t(below)
    end
  end
  def d2t(num) when num < 1_000_000_000 do
    case split_mod(num, 1_000_000) do
      {millions, 0} -> Map.get_lazy( @millions , millions, fn ->
          d2t(millions) <> qualifier(millions, "milioane")
        end)
      {millions, below} -> Map.get_lazy( @millions , millions, fn ->
        d2t(millions) <> qualifier(millions, "milioane")
      end) <> " " <> d2t(below)
    end
  end
  def d2t(num) when num < 1_000_000_000_000 do
    case split_mod(num, 1_000_000_000) do
      {billions, 0} -> Map.get_lazy( @billions , billions, fn ->
          d2t(billions) <> qualifier(billions, "miliarde")
        end)
      {billions, below} -> Map.get_lazy( @trillions , billions, fn ->
        d2t(billions) <> qualifier(billions, "miliarde")
      end) <> " " <> d2t(below)
    end
  end
  def d2t(num) when num < 1_000_000_000_000_000 do
    case split_mod(num, 1_000_000_000_000) do
      {trillions, 0} -> Map.get_lazy( @trillions , trillions, fn ->
          d2t(trillions) <> qualifier(trillions, "biliarde")
        end)
      {trillions, below} -> Map.get_lazy( @trillions , trillions, fn ->
        d2t(trillions) <> qualifier(trillions, "biliarde")
      end) <> " " <> d2t(below)
    end
  end
  def d2t(num) when num >= 1_000_000_000_000_000 do
    Stream.unfold(num, fn
      0 -> nil
      num -> {thousend_trillions, below} =split_mod(num, 1_000_000_000_000_000)
        {d2t(below), thousend_trillions}
    end)
    |> Enum.revese()
    |> Enum.join(" de ")
  end
end
