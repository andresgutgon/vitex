ExUnit.start()

Application.put_env(:my_app, MyAppWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: String.duplicate("a", 64),
  server: false,
  render_errors: [formats: [html: MyAppWeb.ErrorHTML]],
  url: [host: "localhost"]
)

Application.ensure_all_started(:my_app)

case MyAppWeb.Endpoint.start_link() do
  {:ok, _pid} -> :ok
  {:error, {:already_started, _pid}} -> :ok
end
