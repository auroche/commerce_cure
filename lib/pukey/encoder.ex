defmodule Pukey.Encoder do

  @spec encode(map | Keyword.t) :: Pukey.xml
  def encode(any)
  def encode(list) when is_list(list) do
    list
    |> Macro.escape()
    |> element()
    |> XmlBuilder.generate()
  end
  def encode(map) when is_map(map) do
    map
    |> Macro.escape()
    |> element()
    |> XmlBuilder.generate()
  end

  defp element(element)
  defp element({:%{}, _, element}) do
    element element
  end

  defp element([element | rest]) do
    element(rest, [element(element)])
  end

  defp element({k, v}) do
    {k, nil, element(v)}
  end

  defp element(v) do
    "#{v}"
  end

  defp element([], result) when is_list(result) do
    Enum.reverse(result)
  end

  defp element([element | rest], result) when is_list(result) do
    element(rest, [element(element)] ++ result)
  end
end
