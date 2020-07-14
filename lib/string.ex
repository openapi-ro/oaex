defmodule OA.String do
  @doc """
    returns
    - the atom if `parameter` is already an atom
    - `String.to_atom(parameter)` if it is a `bitstring`
  """
  def ensure_atom( string) when is_bitstring(string) do
    String.to_atom string
  end
  def ensure_atom( atom) when is_atom(atom) do
   atom
  end
  @doc """
    returns
    - the atom if `parameter` is already an atom
    - `String.to_existing_atom(parameter)` if it is a `bitstring`
  """
  def ensure_existing_atom( string) when is_bitstring(string) do
    String.to_existing_atom string
  end
  def ensure_existing_atom( atom) when is_atom(atom) do
   atom
  end
end
