defmodule Pukey.Decoder do
  require Record

  # TODO: MOVE away from :xmerl, their ability to consume atom from untrusted source can be dangerous

  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText,    Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  def decode(xml) do
    xml
    |> to_charlist()
    |> to_xmerl()
    |> decode([])
  end

  defp decode({doc, rest}, result) do
    decode(to_xmerl(rest), [element(doc)] ++ result)
  end

  defp decode([], result) do
    result |> Enum.reverse() |> List.flatten
  end

  defp to_xmerl([]), do: []

  defp to_xmerl(charlist_xml) do
    charlist_xml
    |> :xmerl_scan.string()
  end

  defp element([], result) do
    case length(result) do
      1 -> List.first(result)
      _ -> result |> Enum.reverse() |> List.flatten()
    end
  end

  defp element([element | rest], result) do
    new_result = element(element)
    if new_result do
      element(rest, [new_result] ++ result)
    else
      element(rest, result)
    end
  end

  defp element(element) do
    cond do
      Record.is_record(element, :xmlElement) ->
        [{xmlElement(element, :name), element |> xmlElement(:content) |> element()}]
      Record.is_record(element, :xmlText) ->
        element
        |> xmlText(:value)
        |> to_string
        |> gulp_empty()
      is_list(element) ->
        element(element, [])
    end
  end

  defp gulp_empty(string, default \\ nil) do
    if empty_string?(string) do
      default
    else
      string
    end
  end

  defp empty_string?(string) do
    String.match?(string, ~r/^[\s\r\t\n]+$/)
  end
end
