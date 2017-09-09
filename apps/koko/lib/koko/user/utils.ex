defmodule Koko.User.Utils do


  @moduledoc false

  # NOTE: The code is Auth.Signature is taken verbatim from
  # https://github.com/CargoSense/ex_aws/ (@copyright CargoSense, MIT License)

  def utc_now(:tuple) do
     dt = DateTime.utc_now() # |> DateTime.to_iso8601()
     y = dt.year
     m = dt.month
     d = dt.day
     ho = dt.hour
     mi = dt.minute
     se = dt.second
     {{y,m,d}, {ho,mi,se}}
  end

  def utc_now(:list, :long) do
     dt = DateTime.utc_now() # |> DateTime.to_iso8601()
     y = dt.year
     m = dt.month
     d = dt.day
     ho = dt.hour
     mi = dt.minute
     se = dt.second
     [y,m,d,ho,mi,se]
  end

  def utc_now(:list, :short) do
     dt = DateTime.utc_now() # |> DateTime.to_iso8601()
     y = dt.year
     m = dt.month
     d = dt.day
     [y,m,d]
  end

  def utc_now(:string, :long) do
     [y,m,d,ho,mi,se] = utc_now(:list, :long)
     |> Enum.map(fn(item) -> (item |> Integer.to_string |> String.pad_leading(2, "0")) end)
     Enum.join([y,m,d,"T",ho,mi,se,"Z"], "")
  end

  def utc_now(:string, :short) do
     utc_now(:list, :short)
     |> Enum.map(fn(item) -> (item |> Integer.to_string |> String.pad_leading(2, "0")) end)
     |> Enum.join("")
  end

  defmodule S3DirectUpload.Expiration do

  @moduledoc false

  @iso8601 "~.4.0w-~.2.0w-~.2.0wT~.2.0w:~.2.0w:~.2.0wZ"
  @iso8601X "~.4.0w~.2.0w~.2.0wT~.2.0w~.2.0w~.2.0wZ"

  def datetime do
    :calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.+(60 * 60)
    |> :calendar.gregorian_seconds_to_datetime
    |> expiration_format
  end

  defp expiration_format({ {year, month, day}, {hour, min, sec} }) do
    :io_lib.format(@iso8601, [year, month, day, hour, min, sec])
    |> to_string
  end

  defp iso_format({ {year, month, day}, {hour, min, sec} }) do
    :io_lib.format(@iso8601X, [year, month, day, hour, min, sec])
    |> to_string
  end

  def iso_8601_now do
    :calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds
    |> :calendar.gregorian_seconds_to_datetime
    |> iso_format
  end

  def uri_encode(url) do
    url
    |> String.replace("+", " ")
    |> URI.encode(&valid_path_char?/1)
  end

  # Space character
  def valid_path_char?(?\ ), do: false
  def valid_path_char?(?/), do: true
  def valid_path_char?(c) do
    URI.char_unescaped?(c) && !URI.char_reserved?(c)
  end

  def hash_sha256(data) do
    :sha256
    |> :crypto.hash(data)
    |> bytes_to_hex
  end

  def hmac_sha256(key, data) do
    :crypto.hmac(:sha256, key, data)
  end

  def bytes_to_hex(bytes) do
    bytes
    |> Base.encode16(case: :lower)
  end

  def service_name(service), do: service |> Atom.to_string

  def method_string(method) do
    method
    |> Atom.to_string
    |> String.upcase
  end

  def date({date, _time}) do
    date |> quasi_iso_format
  end

  def amz_date({date, time}) do
    date = date |> quasi_iso_format
    time = time |> quasi_iso_format

    [date, "T", time, "Z"]
    |> IO.iodata_to_binary
  end

  def quasi_iso_format({y, m, d}) do
    [y, m, d]
    |> Enum.map(&Integer.to_string/1)
    |> Enum.map(&zero_pad/1)
  end

  defp zero_pad(<<_>> = val), do: "0" <> val
  defp zero_pad(val), do: val


end
