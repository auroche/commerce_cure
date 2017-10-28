defmodule CommerceCure.DataTypeTest do
  use ExUnit.Case
  alias CommerceCure.{
    Address,
    BillingAddress,
    Country,
    ExpiryDate,
    Month,
    Name,
    PaymentCardNumber,
    PaymentCard,
    Phone,
    Province,
    Year
  }
  
  doctest Address
  doctest BillingAddress
  doctest Country
  doctest ExpiryDate
  doctest Month
  doctest Name
  doctest PaymentCardNumber
  doctest PaymentCard
  doctest Phone
  doctest Province
  doctest Year
end
