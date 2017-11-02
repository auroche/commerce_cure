defmodule CommerceCure.Name do
  @type name :: String.t
  @type first_name :: name
  @type last_name :: name
  @type t :: %__MODULE__{first_name: name, last_name: name}

  @enforce_keys [:first_name, :last_name]
  defstruct     [:first_name, :last_name]

  @doc """
  iex> Name.new("Ezra Smith")
  {:ok, %Name{first_name: "Ezra", last_name: "Smith"}}
  iex> Name.new(%{first_name: "First", last_name: "last"})
  {:ok, %Name{first_name: "First", last_name: "last"}}
  iex> Name.new("mala Alan", "Baran")
  {:ok, %Name{first_name: "Baran", last_name: "mala Alan"}}
  """
  @spec new(String.t | map) :: {:ok, t} | {:error, String.t}
  def new(name) when is_binary(name) do
    parse(name)
  end

  def new(%{first_name: first, last_name: last})
    when is_binary(first) and is_binary(last)
  do
    new(last, first)
  end

  @spec new!(String.t | map) :: t | nil
  def new!(term) do
    case new(term) do
      {:ok, name} ->
        name
      {:error, reason} ->
        raise ArgumentError, "#{inspect term} has error of #{inspect reason}"
    end
  end

  @spec new(name, name) :: t
  def new(last_name, first_name) when is_binary(last_name) and is_binary(first_name) do
    {:ok, %__MODULE__{first_name: first_name, last_name: last_name}}
  end

  @spec new!(name, name) :: t
  def new!(last, first) do
    case new(last, first) do
      {:ok, name} ->
        name
      {:error, reason} ->
        raise ArgumentError, "#{inspect last} and #{inspect first} have error of #{inspect reason}"
    end
  end

  @doc """
  iex> Name.parse("Johann von Neumann")
  {:ok, %Name{first_name: "Johann von", last_name: "Neumann"}}
  iex> Name.parse("Bob McCloud")
  {:ok, %Name{first_name: "Bob", last_name: "McCloud"}}
  """
  # BUG: can only capture one word last names
  @spec parse(String.t) :: t
  def parse(name) when is_binary(name) do
    [last | firsts] = name |> String.split |> Enum.reverse()
    {:ok, %__MODULE__{first_name: firsts |> Enum.reverse() |> Enum.join(" "), last_name: last}}
  end

  @doc """
  iex> Name.full_name(%{first_name: "Commerce", last_name: "Cure"})
  "Commerce Cure"

  """
  @spec full_name(t, atom) :: String.t
  def full_name(name, first_or_last \\ :first)
  def full_name(%{first_name: first, last_name: last}, :first) do
    "#{first} #{last}"
  end
  def full_name(%{first_name: first, last_name: last}, :last) do
    "#{last} #{first}"
  end

  @doc """
  iex> Name.to_string(%{first_name: "Commerce", last_name: "Cure"})
  "Commerce Cure"
  """
  @spec to_string(t) :: String.t
  def to_string(%{first_name: first, last_name: last}) do
    full_name(%{first_name: first, last_name: last})
  end

  defimpl String.Chars do
    def to_string(%{first_name: first, last_name: last}) do
      CommerceCure.Name.to_string(%{first_name: first, last_name: last})
    end
  end
end
