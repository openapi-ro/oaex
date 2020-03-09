defmodule OA.Ecto.Migrator do
  @moduledoc """
  Same as `&Ecto.Migrator.with_repo/2`, but accepts a list of repos to ensure those are started
  """
  def with_repos([], fun, ensured_repos) do
    fun.(ensured_repos)
  end
  def with_repos([repo| other_repos ], fun, ensured \\[]) do
    Ecto.Migrator.with_repo repo, fn repo ->
      with_repos(other_repos, fun, [repo | ensured])
    end
  end
  @moduledoc """
  Find migrations corresponding to multiple repos and merges them into a list cotaining
  {:up|:down, order, name, file, module}
  """
  def merged_migrations(repos) do
    require IEx
    IEx.pry
  end
  @moduledoc """
  Tests whether a module is a migration.
  Added here pecause the same-named function in Ecto is private.
  """
  def migration?(mod) do
    function_exported?(mod, :__migration__, 0)
  end
  defp load_migration!({version, _, file}) when is_binary(file) do
    loaded_modules = file |> Code.load_file() |> Enum.map(&elem(&1, 0))

    if mod = Enum.find(loaded_modules, &migration?/1) do
      {version, mod}
    else
      raise Ecto.MigrationError, "file #{Path.relative_to_cwd(file)} does not define an Ecto.Migration"
    end
  end
  @moduledoc """
  Finds the files and modules for the given repos
  the repos argument can be a Repo or a {Repo, directory}, or a list of those (even interleved Modules/path strings).
  The result is returned ordered by the `order tuple member`

  returns a list of tuples in the format `{:up|down, order_int, repo, full_filename,migration_module}`
  """
  def find_migration_modules(repos) when is_list(repos) do
    repos
    |>Enum.map(&find_migration_modules/1)
    |>Enum.flat_map(&(&1))
    |>Enum.sort_by(fn {_,order,_,_,_}-> order end)
    |>Enum.uniq()
  end
  def find_migration_modules({repo, path}) when is_atom(repo), do: find_migration_modules(repo, path)
  def find_migration_modules(repo) when is_atom(repo) do
    path = Ecto.Migrator.migrations_path(repo)
    find_migration_modules(repo, path)
  end
  def find_migration_modules(repo, path) when is_atom(repo) and is_bitstring(path) do
    migrations =
      Ecto.Migrator.migrations(repo, path)
      |>Enum.filter(fn
        {_,_,"** FILE NOT FOUND **"} -> false
        _ -> true
        end)
      |> Enum.map(fn {up_down, order, name}->
          [file] =
            Path.join([path, "**", "*#{order}*#{name}*.exs"])
            |>Path.wildcard()
          loaded_modules = file |> Code.load_file() |> Enum.map(&elem(&1, 0))
          {up_down,order, repo,file,Enum.find(loaded_modules, &migration?/1)}
      end)
  end
end
