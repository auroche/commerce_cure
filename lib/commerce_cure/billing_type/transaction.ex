defmodule CommerceCure.Transaction do
  @enforce_keys [:id, :time]
  defstruct     [:id, :time]
end
