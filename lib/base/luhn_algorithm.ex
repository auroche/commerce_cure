defmodule LuhnAlgorithm do
  @moduledoc """
  https://en.wikipedia.org/wiki/Luhn_algorithm

  """
  ### TODO: Optimize Integer.digits() -> Enum.reverse
  ### BUG: Except for checksum, it does not strictly check if the input is all numbers and will raise when any is not

  @doc """
  iex> LuhnAlgorithm.make_checksum!("7992739871")
  "79927398713"
  iex> LuhnAlgorithm.make_checksum!(7992739871)
  79927398713
  iex> LuhnAlgorithm.make_checksum!("799273987a1")
  ** (ArgumentError) `a` must be 0-9
  """
  @spec make_checksum!(integer | String.t) :: {:ok, integer | String.t}
  def make_checksum!(numbers) when is_binary(numbers) do
    numbers <> make_checksum_digit!(numbers)
  end

  def make_checksum!(numbers) when is_integer(numbers) do
    numbers
    |> Integer.digits()
    |> Enum.reverse()
    |> List.insert_at(0, make_checksum_digit!(numbers))
    |> Enum.reverse()
    |> Integer.undigits()
  end

  @doc """
  iex> LuhnAlgorithm.make_checksum("7992739871")
  {:ok, "79927398713"}
  iex> LuhnAlgorithm.make_checksum(7992739871)
  {:ok, 79927398713}
  iex> LuhnAlgorithm.make_checksum("799273987a1")
  {:error, "`a` must be 0-9"}
  """
  @spec make_checksum(integer | String.t) :: {:ok, integer | String.t} | {:error, String.t}
  def make_checksum(numbers) do
    try do
      make_checksum!(numbers)
    rescue
      ae in [ArgumentError] ->
        {:error, ae.message}
    else
      numbers ->
        {:ok, numbers}
    end
  end

  @doc """
  iex> LuhnAlgorithm.make_checksum_digit!("7992739871")
  "3"
  iex> LuhnAlgorithm.make_checksum_digit!(7992739871)
  3
  iex> LuhnAlgorithm.make_checksum_digit!("799273987a1")
  ** (ArgumentError) `a` must be 0-9
  """
  @spec make_checksum_digit!(integer | String.t) :: integer | String.t
  def make_checksum_digit!(numbers) when is_binary(numbers) do
    10 - (numbers
          |> algorithm()
          |> Integer.digits()
          |> List.last())
    |> to_string()
  end

  def make_checksum_digit!(numbers) when is_integer(numbers) do
    10 - (numbers
          |> algorithm()
          |> Integer.digits()
          |> List.last())
  end

  @doc """
  iex> LuhnAlgorithm.make_checksum_digit("7992739871")
  {:ok, "3"}
  iex> LuhnAlgorithm.make_checksum_digit(7992739871)
  {:ok, 3}
  iex> LuhnAlgorithm.make_checksum_digit("799273987a1")
  {:error, "`a` must be 0-9"}
  """
  @spec make_checksum_digit(integer | String.t) :: {:ok, integer | String.t} | {:error, String.t}
  def make_checksum_digit(numbers) do
    try do
      make_checksum_digit!(numbers)
    rescue
      ae in [ArgumentError] ->
        {:error, ae.message}
    else
      numbers ->
        {:ok, numbers}
    end
  end

  @doc """
  iex> LuhnAlgorithm.checksum("79927398713")
  true
  iex> LuhnAlgorithm.checksum(79927398713)
  true
  iex> LuhnAlgorithm.checksum(79927398423)
  false
  iex> LuhnAlgorithm.checksum("799273987a1")
  false
  """
  @spec checksum(integer | String.t) :: boolean
  def checksum(numbers) when is_binary(numbers) do
    if String.match?(numbers, ~r/^\d+$/) do
      [check_digit | numbers] = numbers
        |> Kernel.to_charlist()
        |> Enum.reverse()

      case {:reversed, numbers}
        |> algorithm_codepoint()
        |> Kernel.+(ce(check_digit))
        |> rem(10)
      do
        0 -> true
        _ -> false
      end
    else
      false
    end
  end

  def checksum(numbers) when is_integer(numbers) do
    [check_digit | numbers] = numbers
      |> Integer.digits()
      |> Enum.reverse()

    case {:reversed, numbers}
      |> algorithm_integer()
      |> Kernel.+(check_digit)
      |> rem(10)
    do
      0 -> true
      _ -> false
    end
  end

  defp algorithm(numbers) when is_binary(numbers) do
    algorithm_codepoint({:charlisted, Kernel.to_charlist(numbers)})
  end
  defp algorithm(numbers) when is_integer(numbers) do
    algorithm_integer({:listed, Integer.digits(numbers)})
  end

  defp algorithm_codepoint({:charlisted, numbers}) when is_list(numbers)  do
    algorithm_codepoint({:reversed, Enum.reverse(numbers)})
  end
  defp algorithm_codepoint({:reversed, numbers}) when is_list(numbers) do
    algorithm_codepoint(numbers, 0, true)
  end

  defp algorithm_codepoint(numbers, sum, odd?)
  defp algorithm_codepoint([ digit | numbers ], sum, true) when is_integer(digit) do
    algorithm_codepoint(numbers, co(digit) + sum, false)
  end
  defp algorithm_codepoint([ digit | numbers ], sum, false) when is_integer(digit) do
    algorithm_codepoint(numbers, ce(digit) + sum, true)
  end
  defp algorithm_codepoint([], sum, _) do
    sum
  end

  defp algorithm_integer({:listed, numbers}) when is_list(numbers) do
    algorithm_integer({:reversed, Enum.reverse(numbers)})
  end
  defp algorithm_integer({:reversed, numbers}) when is_list(numbers) do
    algorithm_integer(numbers, 0, true)
  end

  defp algorithm_integer(numbers, sum, odd?)
  defp algorithm_integer([ digit | numbers ], sum, true) when is_integer(digit) do
    algorithm_integer(numbers, e(digit) + sum, false)
  end
  defp algorithm_integer([ digit | numbers ], sum, false) when is_integer(digit) do
    algorithm_integer(numbers, digit + sum, true)
  end
  defp algorithm_integer([], sum, _) do
    sum
  end

  @compile {:inline, e: 1}

  defp e(0), do: 0
  defp e(1), do: 2
  defp e(2), do: 4
  defp e(3), do: 6
  defp e(4), do: 8
  defp e(5), do: 1
  defp e(6), do: 3
  defp e(7), do: 5
  defp e(8), do: 7
  defp e(9), do: 9

  @compile {:inline, co: 1}

  defp co(48), do: 0
  defp co(49), do: 2
  defp co(50), do: 4
  defp co(51), do: 6
  defp co(52), do: 8
  defp co(53), do: 1
  defp co(54), do: 3
  defp co(55), do: 5
  defp co(56), do: 7
  defp co(57), do: 9
  defp co(c), do: raise ArgumentError, "`#{[c]}` must be 0-9"

  @compile {:inline, ce: 1}

  defp ce(48), do: 0
  defp ce(49), do: 1
  defp ce(50), do: 2
  defp ce(51), do: 3
  defp ce(52), do: 4
  defp ce(53), do: 5
  defp ce(54), do: 6
  defp ce(55), do: 7
  defp ce(56), do: 8
  defp ce(57), do: 9
  defp ce(c), do: raise ArgumentError, "`#{[c]}` must be 0-9"

end
