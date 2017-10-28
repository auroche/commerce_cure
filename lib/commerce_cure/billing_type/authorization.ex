defmodule CommerceCure.Authorization do
  @enforce_keys [:approval_code]
  defstruct     [:approval_code, :transaction_id]
end
