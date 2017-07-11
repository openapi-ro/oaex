defmodule KeywordTest do
  use ExUnit.Case
  test "myers_merge" do
    left = [
      a: [:l1],
      b: [:l1,:l2,:l3],
      c: [:l5,:l6,:l7],
    ]
    right = [
      d: [:r1],
      b: [:r1,:r2,:r3],
      c: [:r5,:r6,:r7],
    ]
    result = OA.Keyword.myers_merge left, right, fn key, left_val, right_val -> 
      left_val++right_val
    end
    assert [
      a: [:l1],
      d: [:r1],
      b: [:l1, :l2, :l3, :r1, :r2, :r3],
      c: [:l5, :l6, :l7, :r5, :r6, :r7]
      ]==result
    result = OA.Keyword.myers_merge left, right, fn key, left_val, right_val -> 
      right_val++ left_val
    end
    assert [
      a: [:l1],
      d: [:r1],
      b: [:r1, :r2, :r3, :l1, :l2, :l3],
      c: [:r5, :r6, :r7, :l5, :l6, :l7]
      ]==result
  end
  test "myers_merge more than 2 lists" do
    lists =
      0..4
      |> Enum.map( fn list_idx -> 
        ret=
          0..list_idx
          |> Enum.with_index(97)
          |>Enum.map(fn {idx, char_code}-> 
            list_val=
              0..idx
              |> Enum.map(fn val_idx -> String.to_atom(to_string([97+list_idx, 48+val_idx])) end)
            list_atom=
              [97+idx]
              |> to_string()
              |>String.to_atom()
            {list_atom,list_val}
          end )
      end)
    merged = OA.Keyword.myers_merge lists, fn key, left_val, right_val -> 
       left_val ++ right_val
    end
    assert [
      a: [:a0, :b0, :c0, :d0, :e0],
      b: [:b0, :b1, :c0, :c1, :d0, :d1, :e0, :e1],
      c: [:c0, :c1, :c2, :d0, :d1, :d2, :e0, :e1, :e2],
      d: [:d0, :d1, :d2, :d3, :e0, :e1, :e2, :e3],
      e: [:e0, :e1, :e2, :e3, :e4]
      ] == merged
  end
end