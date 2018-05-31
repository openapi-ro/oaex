use Mix.Config

config :oaex,
  test: :test,
  cwd: {:system,"PWD"},
  val_with_active_default: {:system, "NON_EXISTING", :default}

