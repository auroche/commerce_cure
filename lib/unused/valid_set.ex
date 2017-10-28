defmodule CommerceCure.ValidSet do
  alias __MODULE__

  @type t :: %__MODULE__{
               valid?: boolean,
               errors: [],
               data: map
             }

  @enforce_keys [:data]
  defstruct [:data, valid?: true, errors: []]

  def new(data) do
    cond do
      is_map(data) ->
        {:ok, %__MODULE__{data: data, valid?: true}}
      Keyword.keyword?(data) ->
        {:ok, %__MODULE__{data: Enum.into(data, %{}), valid?: true}}
      true ->
        {:error, "#{inspect data} must be a map or keywords"}
    end
  end

  def validate_required(%{data: data} = valid_set, keys) do
    new_errors = keys
    |> Enum.filter(fn key ->
      Map.get(data, key, nil)
    end)
    |> Enum.map(fn key ->
      {key, "is required"}
    end)

    put_new_errors(valid_set, new_errors)
  end

  defp put_new_errors(%{errors: errors} = valid_set, new_errors) do
    if length(new_errors) > 0 do
      valid_set
      |> Map.put(:valid?, false)
      |> Map.put(:errors, new_errors ++ errors)
    else
      valid_set
    end
  end
end
