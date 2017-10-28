defmodule CommerceCure.Tesla.InjectBody do
  @behaviour Tesla.Middleware

  def call(env, next, opts) do
    opts = opts || []

    env
    |> inject(opts)
    |> Tesla.run(next)
  end

  def inject(env, opts) do
    env
    |> Map.update!(:body, &inject_body(&1, opts))
  end

  defp inject_body(body, opts) do
    body
    |> puke_prefix(Keyword.get(opts, :prefix))
    |> puke_suffix(Keyword.get(opts, :suffix))
  end

  defp injectable?(%{body: body}) when is_binary(body), do: true
  defp injectable?(%{body: nil}),                       do: false
  defp injectable?(%{body: %Tesla.Multipart{}}),        do: false
  defp injectable?(_),                                  do: false

  defp puke_prefix(string, prefix) do
    if prefix do
      prefix <> string
    else
      string
    end
  end

  defp puke_suffix(string, suffix) do
    if suffix do
      string <> suffix
    else
      string
    end
  end
end
