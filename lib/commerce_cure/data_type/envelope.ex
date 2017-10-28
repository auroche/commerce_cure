defmodule CommerceCure.Envelope do
  alias __MODULE__
  @moduledoc """
  keys_map acts as a key translation lookup that transform this application's key into
  other applications' api key for data submission and responses
  """

  @type t :: %__MODULE__{document: map}
  @enforce_keys []
  defstruct [document: %{}, keys_map: %{}]

  # keys_map: in -> document and is a surjective set

  @spec new(map | list, map | list) :: t
  def new(document \\ %{}, keys_map \\ %{})
  def new(document, keys_map) do
    %__MODULE__{}
    |> learn_keys(keys_map)
    |> put_document(document)
  end

  @spec put(t, atom, String.t) :: t
  def put(%Envelope{document: document, keys_map: keys_map} = envelope, key, value) do
    %{envelope | document: put_with_mapped_keys(document, keys_map, key, value)}
  end

  @spec put_document(t, map) :: t
  def put_document(%Envelope{document: document, keys_map: keys_map} = envelope, new_document) do
    document = Enum.reduce(new_document, document, fn {k, v}, map ->
      put_with_mapped_keys(map, keys_map, k, v)
    end)
    %{envelope | document: document}
  end

  @spec add_document(t, map) :: t
  def add_document(%Envelope{document: document, keys_map: keys_map} = envelope, new_document) do
    new_document = Enum.reduce(new_document, document, fn {k, v}, map ->
      put_with_mapped_keys(map, keys_map, k, v)
    end)
    %{envelope | document: Map.merge(document, new_document)}
  end

  @spec force_put(t, atom, String.t) :: t
  def force_put(%Envelope{document: document} = envelope, key, value) do
    %{envelope | document: Map.put(document, key, value)}
  end

  @spec learn_key(t, atom, atom) :: t
  def learn_key(%Envelope{keys_map: keys_map} = envelope, from, to) do
    %{envelope | keys_map: Map.put(keys_map, from, to)}
  end

  @spec learn_keys(t, map | Keyword.t) :: t
  def learn_keys(%Envelope{keys_map: keys_map} = envelope, keys) do
    keys_map = Enum.reduce(keys, keys_map, fn {k, v}, map when is_atom(k) and is_atom(v) ->
      Map.put(map, k, v)
    end)

    %{envelope | keys_map: keys_map}
  end

  @spec to_json(t) :: Poison.Parser.t
  def to_json(%Envelope{} = envelope) do
    Poison.encode!(envelope)
  end

  defp put_with_mapped_keys(map, keys_map, k, v) do
    Map.put(map, Map.get(keys_map, k, k), v)
  end

  ### Helpers

  defimpl Poison.Encoder do
    def encode(%{document: document}, options) do
      Poison.Encoder.Map.encode(document, options)
    end
  end

  defimpl Poison.Decoder do
    def decode(json, options) do
      json
      |> Poison.decode!(options)
      |> Envelope.new()
    end
  end
end
