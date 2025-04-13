defmodule Vitex.Inertia.SSR.Config do
  @moduledoc false

  defstruct [:vite_host]

  @type t :: %__MODULE__{vite_host: String.t() | nil}
  @spec build(keyword()) :: t()
  def build(opts) do
    %__MODULE__{
      vite_host: Keyword.get(opts, :vite_host, Vitex.default_vite_host())
    }
  end
end
