defmodule ExETo.Validation do
  @moduledoc """
  Validation helper functions
  """

  # Latitude
  @minlat_radians ExETo.Conversion.deg_to_rad(-90.0)
  @maxlat_radians ExETo.Conversion.deg_to_rad(90.0)

  # Solar declination
  @minsoldec_radians ExETo.Conversion.deg_to_rad(-23.5)
  @maxsoldec_radians ExETo.Conversion.deg_to_rad(23.5)

  # Sunset hour angle
  @minsha_radians 0.0
  @maxsha_radians ExETo.Conversion.deg_to_rad(180.0)

  @doc """
  Check that hours is in valid range

  ## Parameters
    - hours: day hours

  ## Examples:

      iex> ExEto.Validation.check_day_hours(11)

  """
  @spec check_day_hours(integer) :: {:ok, integer}
  def check_day_hours(hours) when is_integer(hours) and hours in 0..24, do: {:ok, hours}

  def check_day_hours(hours),
    do: {:error, "hours should be integer in the range 0-24: #{hours}"}

  @doc """
  Check day of year is in valid range

  ## Parameters
    - day: day of year

  ## Examples:

      iex> ExEto.Validation.check_doy(123)

  """
  @spec check_doy(integer) :: {:ok, integer}
  def check_doy(doy) when is_integer(doy) and doy in 1..366, do: {:ok, doy}

  def check_doy(doy),
    do: {:error, "day of the year (doy) should be integer in the range 1-366: #{doy}"}

  @doc """
  Check latitude is within valid range

  ## Parameters
    - latitude: latitude in radians

  ## Examples:

      iex> ExEto.Validation.check_latitude_rad(1.3)

  """
  @spec check_latitude_rad(number) :: {:ok, number}
  def check_latitude_rad(latitude)
      when is_number(latitude) and latitude >= @minlat_radians and latitude <= @maxlat_radians,
      do: {:ok, latitude}

  def check_latitude_rad(latitude),
    do:
      {:error,
       "latitude should be number in the range #{@minlat_radians} to #{@maxlat_radians} #{latitude}"}

  @doc """
  Check solar declination is in valid range

  ## Parameters
    - sd: solar declination in radians

  ## Examples:

      iex> ExEto.Validation.check_sol_dec_rad(1.3)

  """
  @spec check_sol_dec_rad(number) :: {:ok, number}
  def check_sol_dec_rad(sd)
      when is_number(sd) and sd >= @minsoldec_radians and sd <= @maxsoldec_radians,
      do: {:ok, sd}

  def check_sol_dec_rad(sd),
    do:
      {:error,
       "solar declination should be number in the range #{@minsoldec_radians} to #{@maxsoldec_radians} #{sd}"}

  @doc """
  Check sunset hour angle is in valid range

  ## Parameters
    - sha: sunset hour angle in radians

  ## Examples:

      iex> ExEto.Validation.check_sunset_hour_angle_rad(1.3)

  """
  @spec check_sunset_hour_angle_rad(number) :: {:ok, number}
  def check_sunset_hour_angle_rad(sha)
      when is_number(sha) and sha >= @minsha_radians and sha <= @maxsha_radians,
      do: {:ok, sha}

  def check_sunset_hour_angle_rad(sha),
    do:
      {:error,
       "sunset hour angle should be number in the range #{@minsha_radians} to #{@maxsha_radians} #{sha}"}
end
