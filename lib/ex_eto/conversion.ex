defmodule ExETo.Conversion do
  @moduledoc """
  Common unit conversion helper functions
  """

  @doc """
  Convert temperature in degrees Celsius to degrees Kelvin

  ## Parameters
    - celsius: degrees celsius

  ## Examples

      iex> ExEto.Conversion.celsius_to_kelvin(20)

  """
  @spec celsius_to_kelvin(float) :: float
  def celsius_to_kelvin(celsius) do
    celsius + 273.15
  end

  @doc """
  Convert temperature in degrees Kelvin to degrees Celsius

  ## Parameters
    - kelvin: degrees kelvin

  ## Examples

      iex> ExEto.Conversion.kelvin_to_celsius(293.15)

  """
  @spec kelvin_to_celsius(float) :: float
  def kelvin_to_celsius(kelvin) do
    kelvin - 273.15
  end

  @doc """
  Convert angular degrees to radians

  ## Parameters
    - degrees: value in degrees to be converted

  ## Examples

      iex> ExEto.Conversion.deg_to_rad(96.5)

  """
  @spec deg_to_rad(float) :: float
  def deg_to_rad(degrees) do
    degrees * (:math.pi() / 180.0)
  end

  @doc """
  Convert radians to angular degrees

  ## Parameters
    - radians: value in radians to be converted

  ## Examples

      iex> ExEto.Conversion.rad_to_deg(1.72)

  """
  @spec rad_to_deg(float) :: float
  def rad_to_deg(radians) do
    radians * (180.0 / :math.pi())
  end

  @doc """
  Convert km/hr to m/s

  ## Parameters
    - kph: kilometers per hour

  ## Examples

      iex> ExEto.Conversion.kph_to_mps(15)

  """
  @spec kph_to_mps(float) :: float
  def kph_to_mps(kph) do
    kph * 1000 / 3600
  end
end
