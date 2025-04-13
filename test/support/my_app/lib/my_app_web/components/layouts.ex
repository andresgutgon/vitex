defmodule MyAppWeb.Layouts do
  @moduledoc false

  use MyAppWeb, :html

  embed_templates("layouts/*")
end
