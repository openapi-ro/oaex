defmodule OA.Application do
  @moduledoc """
  Helpers for dealing with Application keys from config
  """
  @doc """
    Same as Application.get_env, but resolves {:system,key,default} tuples to system environments varse if those are set
    - `{:system, key, default}` is converted to the System.get_env(key,default)
    - `{:system, key}` rerurns `nil` id `System.get_env(key)` is not set

    `key` can be either a string containing the system variable name, or a list.
    For a list of variable names the first one which is set is picked. If no variable in the list is set default is returned
  """
  def get_env(app, key) do
    Application.get_env(app,key)
    |> extract()
  end
  @doc """
  Same as &Application.get_all_env/1,
  but applying methods discussed in &OA.Application.get_env/2
  """
  def get_all_env(app) do
    Application.get_all_env(app)
    |> Enum.map(fn {key,value} -> {key, extract(value)} end)
    |>Map.new()
  end
  def extract({:system, key, default}) when is_bitstring(key) do
    System.get_env(key) || default
  end
  def extract({:system, [key|_]=list, default}) when is_bitstring(key)do
    ret=
      list
      |> Stream.map( fn key ->
        System.get_env(key) || default
      end )
      |> Stream.filter(fn
          nil -> false
          _->true
        end)
      |>Enum.take(1)
    if is_nil(ret) do
      default
    else
      ret
    end
  end
  def extract({:system, key}) when is_bitstring(key) do
    extract({:system,key,nil})
  end
  def extract({:system, [key|_]=list}) when is_bitstring(key) do
    extract({:system,list,nil})
  end
  def extract(other), do: other
end