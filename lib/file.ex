defmodule OA.File do
  @doc """
    ensures the parent directory of the file exists
    if a trailing slash is contained, the directory is the `file` argument without the trailing separator
    returns `{:ok, ensured_dir}` or `{:error, reason}`
  """
  def ensure_dir(file) do
    dir = Path.dirname(file)
    case File.mkdir_p(dir) do
      :ok-> {:ok, dir}
      {:error,_}=error-> error
    end
  end
  @doc """
  same as `ensure_dir/1` but trows on error.
  """
  def ensure_dir!(file) do
    {:ok, _} = ensure_dir(file)
    file
  end
end