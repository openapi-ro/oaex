defmodule OA.ConfigStruct do
  @moduledoc """
    Module implements reading a configuration
    into a config struct.

    The config struct is a module, which can provide defaults within it's defstruct macro.

    `OA.ConfigStruct` is used by adding `use OA.ConfigStruct [app, key |more_keys]`
    The conficuration root is `[app, key |more_keys]` as would be used in `Application.get_env(app,key)`
    or in `Application.get_all_env(app,key)`


    All configuration under the given key must consist of keys which are also present in the
    target config struct.
    Keys which are missing from confiuguration are defaulted according to the `defstruct` definition

    Key values can be

    * either `{:system, "ENV_VAR"}` which will be resolved at *load time* using 
    System.getEnv("ENV_VAR")
    * or any other value which is not being translated by default.
    ##Example

      iex> defmodule MyConfig do
              use OA.ConfigStruct, [:key, :sub_key]
              defstruct config_key1: :default1,
                config_key2: :default2,
                config_key2: :default2,
           end
      iex> MyConfig.read()

    `OA.ConfigStruct` implements `read()` which will return the configuration struct as read
    from the config

    It is possible to override reading keys by implementing read(key).
    `OA.ConfigStruct.get_root_config()` will return the configuration beneath the config root path
    `get_root()` will return root path for the configuration as supplied to `use OA.ConfigStruct`
  """
  defmacro __using__(root_key_path) do
    root_key_path=
      case root_key_path do
        []-> raise "use argument must be an atom or a list of atoms"
        key when is_atom(key)->[key]
        list->
          Enum.map(list, fn
            key when is_atom(key)-> key
            no_key ->
              raise "use argument must be an atom or a list of atoms. '#{inspect no_key}' is not"
          end)
      end
    ret=
    quote do
      def get_root() do
        unquote(root_key_path)
      end
      #this reads the root key from Application.
      #the root key path is fixed at compile time
      def get_root_config() do
        {rest,acc} =
          case unquote(root_key_path) do
            [app, key| rest] ->{rest, Application.get_env(app, key)}
            [app | rest]->{rest, Application.get_all_env(app)}
          end
        Enum.reduce(rest, acc, fn key, val->
          val[key] end)
      end
      def read() do
        ret = struct __MODULE__
        Enum.reduce(get_root_config(), struct(__MODULE__), fn 
          nil, config-> config
          {key, val}, config ->
            Map.put(config ,  key, read(key))
          end)
      end
      def read(key) when is_atom(key) do

        case get_root_config()[key] do
          nil-> Map.get(struct(__MODULE__),key)
          {:system, val} -> System.get_env(val)
          other-> other
        end
      end
      defoverridable [read: 1]
    end
  end
end