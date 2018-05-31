defmodule ApplicationTest do
  use ExUnit.Case

  test "get_env: normal values without substritutions" do
    assert OA.Application.get_env(:oaex, :test) == :test

  end
  test "get real value from system" do
    assert OA.Application.get_env(:oaex, :cwd) == System.cwd()
  end
  test "get unser and defaulted value" do
    assert OA.Application.get_env(:oaex, :val_with_active_default) == :default
  end
  test "get_all_env" do
    assert OA.Application.get_all_env(:oaex) == %{
      cwd: System.cwd(),
      included_applications: [],
      test: :test,
      val_with_active_default: :default}
  end
end