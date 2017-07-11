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
end