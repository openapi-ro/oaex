defmodule ConfigStructTest do
  use ExUnit.Case

  defmodule C1 do
    use OA.ConfigStruct, [:app, :c1]
    defstruct k1: :def1, k2: :def2

  end
  test "test a config struct" do
    Application.put_env :app, :c1, k1: 1, k2: 2
    conf = C1.read()
    assert conf.k1==1
    assert conf.k2==2
    Application.put_env :app, :c1, k1: 1
    conf = C1.read()
    assert conf.k1==1
    assert conf.k2==:def2
  end
  test "test gathering config values from env" do
    Application.put_env :app, :c1, k1: 1, k2: {:system, "PATH"}
    conf = C1.read()
    assert conf.k1==1
    assert is_bitstring(conf.k2)
  end
  test "get_root and get_root_config, also read from System.get_env" do
    conf = [k1: 1, k2: {:system, "PATH"}]
    Application.put_env :app, :c1, conf
    conf_def = C1.read()
    assert C1.get_root_path == [:app, :c1]
    assert C1.get_root_config  == conf
    assert C1.get_root_config  != conf_def # PATH is supposed to be replaced
  end
  test "get_root and get_root_config do not read from System.get_env" do
    conf = [k1: 1, k2: 2]
    Application.put_env :app, :c1, conf
    conf_def = C1.read()
    assert C1.get_root_path == [:app, :c1]
    assert C1.get_root_config  == conf
    assert C1.get_root_config  == Map.from_struct(conf_def)|> Enum.map(&(&1)) # No replacements
  end

end
