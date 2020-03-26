defmodule OA.Ecto.Repo do
  def maybe_parse_url([]) do
    raise ValueError, "Repo not Configured!"
  end
  def maybe_parse_url(nil) do
    raise ValueError, "Repo not Configured!"
  end
  def maybe_parse_url(config) do
    case Keyword.get(config, :url) do
      {:system, env_name} -> Keyword.replace!(config,:url , System.get_env(env_name))
      _ -> config
    end
  end
end
