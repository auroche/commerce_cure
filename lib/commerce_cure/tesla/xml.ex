defmodule CommerceCure.Tesla.XML do
  @behaviour Tesla.Middleware

  @moduledoc """
  Encode requests and decode responses as XML.
  """

  unless Code.ensure_loaded?(Pukey) do
    raise CompileError, line: __ENV__.line, file: __ENV__.file, description: "#{Pukey} must be loaded"
  end

  @default_content_types ["application/xml", "text/xml"]
  @default_engine Pukey

  def call(env, next, opts) do
    opts = opts || []

    env
    |> encode(opts)
    |> Tesla.run(next)
    |> decode(opts)
  end

  @doc """
  Encode request body as XML. Used by `Tesla.Middleware.EncodeXml`
  """
  def encode(env, opts) do
    if encodable?(env) do
      env
      |> Map.update!(:body, &encode_body(&1, opts))
      |> Tesla.Middleware.Headers.call([], %{"content-type" => "application/xml"})
    else
      env
    end
  end

  defp encode_body(%Stream{} = body, opts),             do: encode_stream(body, opts)
  defp encode_body(body, opts) when is_function(body),  do: encode_stream(body, opts)
  defp encode_body(body, opts), do: process(body, :encode, opts)

  defp encode_stream(body, opts) do
    Stream.map body, fn item -> encode_body(item, opts) <> "\n" end
  end

  defp encodable?(%{body: nil}),                        do: false
  defp encodable?(%{body: body}) when is_binary(body),  do: false
  defp encodable?(%{body: %Tesla.Multipart{}}),         do: false
  defp encodable?(_),                                   do: true

  @doc """
  Decode response body as XML. Used by `Tesla.Middleware.DecodeXml`
  """
  def decode(env, opts) do
    if decodable?(env, opts) do
      Map.update!(env, :body, &process(&1, :decode, opts))
    else
      env
    end
  end

  defp decodable?(env, opts), do: decodable_body?(env) && decodable_content_type?(env, opts)

  defp decodable_body?(env) do
    (is_binary(env.body)  && env.body != "") ||
    (is_list(env.body)    && env.body != [])
  end

  defp decodable_content_type?(env, opts) do
    case env.headers["content-type"] do
      nil           -> false
      content_type  -> Enum.any?(content_types(opts), &String.starts_with?(content_type, &1))
    end
  end

  defp content_types(opts), do: @default_content_types ++ Keyword.get(opts, :decode_content_types, [])

  defp process(data, op, opts) do
    with {:ok, value} <- do_process(data, op, opts) do
      value
    else
      {:error, reason} -> raise %Tesla.Error{message: "XML #{op} error: #{inspect reason}", reason: reason}
    end
  end

  defp do_process(data, op, opts) do
    if fun = opts[op] do # :encode/:decode
      fun.(data)
    else
      engine  = Keyword.get(opts, :engine, @default_engine)
      opts    = Keyword.get(opts, :engine_opts, [])

      apply(engine, op, [data, opts])
    end
  end
end

defmodule CommerceCure.Tesla.DecodeXML do
  def call(env, next, opts) do
    opts = opts || []

    env
    |> Tesla.run(next)
    |> CommerceCure.Tesla.XML.decode(opts)
  end
end

defmodule CommerceCure.Tesla.EncodeXML do
  def call(env, next, opts) do
    opts = opts || []

    env
    |> CommerceCure.Tesla.XML.encode(opts)
    |> Tesla.run(next)
  end
end
