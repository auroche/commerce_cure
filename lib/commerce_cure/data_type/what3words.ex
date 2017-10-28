defmodule CommerceCure.What3Words do
  alias __MODULE__
  @type t :: %__MODULE__{one: String.t, two: String.t, three: String.t}
  @enforce_keys [:one, :two, :three]
  defstruct     [:one, :two, :three]

  @spec new(String.t, String.t, String.t) :: {:ok, t} | {:error, atom}
  def new(one, two, three)
    when is_binary(one) and is_binary(two) and is_binary(three)
  do
    {:ok, %__MODULE__{one: one, two: two, three: three}}
  end

  # BUG: the words are English, and accented letters or other binary are not valid
  def new(words) do
    word_list = String.split(words, ".")
    if length(word_list) === 3 do
      [one|[two|[three|[]]]] = word_list
      {:ok, %__MODULE__{one: one, two: two, three: three}}
    else
      {:error, :invalid_3words}
    end
  end

  def to_string(%{one: one, two: two, three: three}) do
    "#{one}.#{two}.#{three}"
  end

  ### Helpers

  defimpl String.Chars do
    def to_string(%{one: one, two: two, three: three}) do
      What3Words.to_string(%{one: one, two: two, three: three})
    end
  end
end
