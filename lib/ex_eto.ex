defmodule ExETo do
  @moduledoc """
  Provides functions for estimating reference evapotransporation (ETo) for
  a grass reference crop using the FAO-56 Penman-Monteith, Hargreaves
  and Thornthwaite equations. This module includes numerous methods for
  estimating missing meteorological data.
  """

  # Solar constant (MJ m-2 min-1)
  @solar_constant 0.0820

  # Stefan Boltzmann constant (MJ K-4 m-2 day-1)
  @stefan_boltzman_constant 0.000000004903

  # for thornthwaite function implementations
  # @month_days [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
  # @leap_month_days [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

  @doc """
  Estimate atmospheric pressure from altitude.

  Calculated using a simplification of the ideal gas law, assuming 20 degrees
  Celsius for a standard atmosphere. Based on equation 7, page 62 in Allen
  et al (1998).

  ## Parameters
    - altitude: elevation/altitude above sea level (m)

  ## Returns
    - atmospheric pressure (kPa)

  ## Examples

      iex> ExEto.atm_pressure()

  """
  @spec atm_pressure(float) :: float
  def atm_pressure(altitude) do
    tmp = (293.0 - 0.0065 * altitude) / 293.0
    tmp ** 5.26 * 101.3
  end

  @doc """
  Estimate actual vapour pressure (*ea*) from minimum temperature.

  This method is to be used where humidity data are lacking or are of
  questionable quality. The method assumes that the dewpoint temperature
  is approximately equal to the minimum temperature (*tmin*), i.e. the
  air is saturated with water vapour at *tmin*.

  **Note**: This assumption may not hold in arid/semi-arid areas.
  In these areas it may be better to subtract 2 deg C from the
  minimum temperature (see Annex 6 in FAO paper).

  Based on equation 48 in Allen et al (1998).

  ## Parameters
    - tmin: daily minimum temperature (deg C)

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_tmin()

  """
  @spec avp_from_tmin(float) :: float
  def avp_from_tmin(tmin) do
    0.611 * :math.exp(17.27 * tmin / (tmin + 237.3))
  end

  @doc """
  Estimate actual vapour pressure (*ea*) from saturation vapour pressure and
  relative humidity.

  Based on FAO equation 17 in Allen et al (1998).

  ## Parameters
    - svp_tmin: saturation vapour pressure at daily min temp (kPa). can estimate with svp_from_t
    - svp_tmax: saturation vapour pressure at daily max temp (kPa). can estimate with svp_from_t
    - rh_min: minimum relative humidity (%)
    - rh_max: maximum relative humidity (%)

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_rhmin_rhmax()

  """
  @spec avp_from_rhmin_rhmax(float, float, float, float) :: float
  def avp_from_rhmin_rhmax(svp_tmin, svp_tmax, rh_min, rh_max) do
    tmp1 = svp_tmin * (rh_max / 100.0)
    tmp2 = svp_tmax * (rh_min / 100.0)
    (tmp1 + tmp2) / 2.0
  end

  @doc """
  Estimate actual vapour pressure (*ea*) from saturation vapour pressure at
  daily minimum and maximum temperature, and mean relative humidity.

  Based on FAO equation 19 in Allen et al (1998).

  ## Parameters
    - svp_tmin: saturation vapour pressure at daily min temp (kPa). can estimate with svp_from_t
    - rh_max: maximum relative humidity (%)

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_rhmax()

  """
  @spec avp_from_rhmax(float, float) :: float
  def avp_from_rhmax(svp_tmin, rh_max) do
    svp_tmin * (rh_max / 100.0)
  end

  @doc """
  Estimate actual vapour pressure (*e*a) from saturation vapour pressure at
  daily minimum temperature and maximum relative humidity.

  Based on FAO equation 18 in Allen et al (1998).

  ## Parameters
    - svp_tmin: saturation vapour pressure at daily min temp (kPa). can estimate with svp_from_t
    - svp_tmax: saturation vapour pressure at daily max temp (kPa). can estimate with svp_from_t
    - rh_mean: mean relative humidity (%) (average of RH min and RH max).

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_rhmean()

  """
  @spec avp_from_rhmean(float, float, float) :: float
  def avp_from_rhmean(svp_tmin, svp_tmax, rh_mean) do
    rh_mean / 100.0 * ((svp_tmax + svp_tmin) / 2.0)
  end

  @doc """
  Estimate actual vapour pressure (*ea*) from dewpoint temperature.

  Based on equation 14 in Allen et al (1998). As the dewpoint temperature is
  the temperature to which air needs to be cooled to make it saturated, the
  actual vapour pressure is the saturation vapour pressure at the dewpoint
  temperature.

  This method is preferable to calculating vapour pressure from
  minimum temperature.

  ## Parameters
    - tdew: dewpoint temperature (deg C)

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_tdew()

  """
  @spec avp_from_tdew(float) :: float
  def avp_from_tdew(tdew) do
    0.6108 * :math.exp(17.27 * tdew / (tdew + 237.3))
  end

  @doc """
  Estimate actual vapour pressure (*ea*) from wet and dry bulb temperature.

  Based on equation 15 in Allen et al (1998). As the dewpoint temperature
  is the temperature to which air needs to be cooled to make it saturated, the
  actual vapour pressure is the saturation vapour pressure at the dewpoint
  temperature.

  This method is preferable to calculating vapour pressure from
  minimum temperature.

  Values for the psychrometric constant of the psychrometer (*psy_const*)
  can calculate with psyc_const_of_psychrometer.

  ## Parameters
    - twet: wet bulb temperature (deg C)
    - tdry: dry bulb temperature (deg C)
    - svp_twet: saturated vapour pressure at the wet bulb temperature (kPa). can estimate with svp_from_t
    - psy_const: psychrometric constant of the pyschrometer (kPa deg C-1). can estimate with psy_const or psy_const_of_psychrometer

  ## Returns
    - actual vapour pressure (kPa)

  ## Examples

      iex> ExEto.avp_from_twet_tdry()

  """
  @spec avp_from_twet_tdry(float, float, float, float) :: float
  def avp_from_twet_tdry(twet, tdry, svp_twet, psy_const) do
    svp_twet - psy_const * (tdry - twet)
  end

  @doc """
  Estimate clear sky radiation from altitude and extraterrestrial radiation.

  Based on equation 37 in Allen et al (1998) which is recommended when
  calibrated Angstrom values are not available.

  ## Parameters
    - altitude: elevation above sea level (m)
    - et_rad: extraterrestrial radiation (MJ m-2 day-1). can estimate with et_rad

  ## Returns
    - clear sky radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.cs_rad()

  """
  @spec cs_rad(float, float) :: float
  def cs_rad(altitude, et_rad) do
    (0.00002 * altitude + 0.75) * et_rad
  end

  @doc """
  Estimate mean daily temperature from the daily minimum and maximum
  temperatures.

  ## Parameters
    - tmin: min daily temp (deg C)
    - tmax: max daily temp (deg C)

  ## Returns
    - mean daily temperature (deg C)

  ## Examples

      iex> ExEto.daily_mean_t()

  """
  @spec daily_mean_t(float, float) :: float
  def daily_mean_t(tmin, tmax) do
    (tmax + tmin) / 2.0
  end

  @doc """
  Calculate daylight hours from sunset hour angle.

  Based on FAO equation 34 in Allen et al (1998).

  ## Parameters
    - sha: sunset hour angle (rad). can calculate with sunset_hour_angle

  ## Returns
    - daylight hours

  ## Examples

      iex> ExEto.daylight_hours()

  """
  @spec daylight_hours(float) :: float
  def daylight_hours(sha) do
    {:ok, sha} = ExETo.Validation.check_sunset_hour_angle_rad(sha)
    24.0 / :math.pi() * sha
  end

  @doc """
  Estimate the slope of the saturation vapour pressure curve at a given
  temperature.

  Based on equation 13 in Allen et al (1998). If using in the Penman-Monteith
  *t* should be the mean air temperature.

  ## Parameters
    - t: air temp (deg C). use mean air temp for use in Penman-Monteith

  ## Returns
    - saturation vapour pressure (kPa degC-1)

  ## Examples

      iex> ExEto.delta_svp()

  """
  @spec delta_svp(float) :: float
  def delta_svp(t) do
    tmp = 4098 * (0.6108 * :math.exp(17.27 * t / (t + 237.3)))
    tmp / (t + 237.3) ** 2
  end

  @doc """
  Convert energy (e.g. radiation energy) in MJ m-2 day-1 to the equivalent
  evaporation, assuming a grass reference crop.

  Energy is converted to equivalent evaporation using a conversion
  factor equal to the inverse of the latent heat of vapourisation
  (1 / lambda = 0.408).

  Based on FAO equation 20 in Allen et al (1998).

  ## Parameters
    - energy: energy e.g. radiation or heat flux (MJ m-2 day-1)

  ## Returns
    - equivalent evaporation (mm day-1)

  ## Examples

      iex> ExEto.energy_to_evap()

  """
  @spec energy_to_evap(float) :: float
  def energy_to_evap(energy) do
    0.408 * energy
  end

  @doc """
  Estimate daily extraterrestrial radiation (*Ra*, 'top of the atmosphere
  radiation').

  Based on equation 21 in Allen et al (1998). If monthly mean radiation is
  required make sure *sol_dec*. *sha* and *irl* have been calculated using
  the day of the year that corresponds to the middle of the month.

  **Note**: From Allen et al (1998): "For the winter months in latitudes
  greater than 55 degrees (N or S), the equations have limited validity.
  Reference should be made to the Smithsonian Tables to assess possible
  deviations."

  ## Parameters
    - latitude: latitude (radians)
    - sol_dec: solar declination (radians). can calculate with sol_dec
    - sha: sunset hour angle (radians). can calculate with sunset_hour_angle
    - ird: inverse relative distance earth-sun (dimensionless). can calculate with inv_rel_dist_earth_sun

  ## Returns
    - daily extraterrestrial radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.et_rad()

  """
  @spec et_rad(float, float, float, float) :: float
  def et_rad(latitude, sol_dec, sha, ird) do
    {:ok, latitude} = ExETo.Validation.check_latitude_rad(latitude)
    {:ok, sol_dec} = ExETo.Validation.check_sol_dec_rad(sol_dec)
    {:ok, sha} = ExETo.Validation.check_sunset_hour_angle_rad(sha)

    tmp1 = 24.0 * 60.0 / :math.pi()
    tmp2 = sha * :math.sin(latitude) * :math.sin(sol_dec)
    tmp3 = :math.cos(latitude) * :math.cos(sol_dec) * :math.sin(sha)
    tmp1 * @solar_constant * ird * (tmp2 + tmp3)
  end

  @doc """
  Estimate reference evapotranspiration (ETo) from a hypothetical
  short grass reference surface using the FAO-56 Penman-Monteith equation.

  Based on equation 6 in Allen et al (1998).

  ## Parameters
    - net_rad: net radiation at crop surface (MJ m-2 day-1). if necessary can estimate with net_rad
    - t: air temp at 2 m height (deg Kelvin)
    - ws: wind speed at 2 m height (m s-1). ff not measured at 2m, convert using wind_speed_at_2m
    - svp: saturation vapour pressure (kPa). can estimated with svp_from_t
    - avp: actual vapour pressure (kPa). can estimate with a range of methods with names beginning with avp_from
    - delta_svp: slope of saturation vapour pressure curve (kPa degC-1). can estimate with delta_svp
    - psy: psychrometric constant (kPa deg C). Can estimate with psy_const_of_psychrometer or psy_const
    - shf: soil heat flux (G) (MJ m-2 day-1) (default is 0.0, which is reasonable for a daily or 10-day time steps). for monthly time steps *shf* can be estimated with monthly_soil_heat_flux or monthly_soil_heat_flux2

  ## Returns
    - reference evapotranspiration (ETo) from a hypothetical grass reference surface (mm day-1)

  ## Examples

      iex> ExEto.fao56_penman_monteith()

  """
  @spec fao56_penman_monteith(float, float, float, float, float, float, float, float) :: float
  def fao56_penman_monteith(net_rad, t, ws, svp, avp, delta_svp, psy, shf \\ 0.0) do
    a1 = 0.408 * (net_rad - shf) * delta_svp / (delta_svp + psy * (1 + 0.34 * ws))
    a2 = 900 * ws / t * (svp - avp) * psy / (delta_svp + psy * (1 + 0.34 * ws))
    a1 + a2
  end

  @doc """
  Estimate reference evapotranspiration over grass (ETo) using the Hargreaves
  equation.

  Generally, when solar radiation data, relative humidity data
  and/or wind speed data are missing, it is better to estimate them using
  the methods available in this module, and then calculate ETo
  the FAO Penman-Monteith equation. However, as an alternative, ETo can be
  estimated using the Hargreaves ETo equation.

  Based on equation 52 in Allen et al (1998).

  ## Parameters
    - tmin: minimum daily temp (deg C)
    - tmax: max daily temp (deg C)
    - tmean: mean daily temp (deg C). if measurements not available, can estimate as (*tmin* + *tmax*) / 2
    - et_rad: extraterrestrial radiation (Ra) (MJ m-2 day-1). can estimate with et_rad

  ## Returns
    - reference evapotranspiration over grass (ETo) (mm day-1)

  ## Examples

      iex> ExEto.hargreaves()

  """
  @spec hargreaves(float, float, float, float) :: float
  def hargreaves(tmin, tmax, tmean, et_rad) do
    # Note, multiplied by 0.408 to convert extraterrestrial radiation could
    # be given in MJ m-2 day-1 rather than as equivalent evaporation in
    # mm day-1
    0.0023 * (tmean + 17.8) * (tmax - tmin) ** 0.5 * 0.408 * et_rad
  end

  @doc """
  Calculate the inverse relative distance between earth and sun from
  day of the year.

  Based on FAO equation 23 in Allen et al (1998).

  ## Parameters
    - day_of_year: day of the year (1 to 366)

  ## Returns
    - inverse relative distance between earth and the sun

  ## Examples

      iex> ExEto.inv_rel_dist_earth_sun()

  """
  @spec inv_rel_dist_earth_sun(integer) :: float
  def inv_rel_dist_earth_sun(day_of_year) do
    {:ok, day_of_year} = ExETo.Validation.check_doy(day_of_year)
    1 + 0.033 * :math.cos(2.0 * :math.pi() / 365.0 * day_of_year)
  end

  @doc """
  Estimate mean saturation vapour pressure, *es* [kPa] from minimum and
  maximum temperature.

  Based on equations 11 and 12 in Allen et al (1998).

  Mean saturation vapour pressure is calculated as the mean of the
  saturation vapour pressure at tmax (maximum temperature) and tmin
  (minimum temperature).

  ## Parameters
    - tmin: min temp (deg C)
    - tmax: max temp (deg C)

  ## Returns
    - mean saturation vapour pressure (*es*) (kPa)

  ## Examples

      iex> ExEto.mean_svp()

  """
  @spec mean_svp(float, float) :: float
  def mean_svp(tmin, tmax) do
    (svp_from_t(tmin) + svp_from_t(tmax)) / 2.0
  end

  @doc """
  Estimate monthly soil heat flux (Gmonth) from the mean air temperature of
  the previous and next month, assuming a grass crop.

  Based on equation 43 in Allen et al (1998). If the air temperature of the
  next month is not known use monthly_soil_heat_flux2 instead. The
  resulting heat flux can be converted to equivalent evaporation [mm day-1]
  using energy_to_evap.

  ## Parameters
    - t_month_prev: mean air temp of the previous month (deg Celsius)
    - t_month_next: mean air temp of the next month (deg Celsius)

  ## Returns
    - monthly soil heat flux (Gmonth) (MJ m-2 day-1)

  ## Examples

      iex> ExEto.monthly_soil_heat_flux()

  """
  @spec monthly_soil_heat_flux(float, float) :: float
  def monthly_soil_heat_flux(t_month_prev, t_month_next) do
    0.07 * (t_month_next - t_month_prev)
  end

  @doc """
  Estimate monthly soil heat flux (Gmonth) from the mean air temperature of
  the previous and next month, assuming a grass crop.

  Based on equation 44 in Allen et al (1998). If the air temperature of the
  next month is available, use monthly_soil_heat_flux instead. The
  resulting heat flux can be converted to equivalent evaporation [mm day-1]
  using energy_to_evap.

  ## Parameters
    - t_month_prev: mean air temp of the previous month (deg Celsius)
    - t_month_cur: mean air temperature of the current month (deg Celsius)

  ## Returns
    - monthly soil heat flux (Gmonth) (MJ m-2 day-1)

  ## Examples

      iex> ExEto.monthly_soil_heat_flux2()

  """
  @spec monthly_soil_heat_flux2(float, float) :: float
  def monthly_soil_heat_flux2(t_month_prev, t_month_cur) do
    0.14 * (t_month_cur - t_month_prev)
  end

  @doc """
  Calculate net incoming solar (or shortwave) radiation from gross
  incoming solar radiation, assuming a grass reference crop.

  Net incoming solar radiation is the net shortwave radiation resulting
  from the balance between incoming and reflected solar radiation. The
  output can be converted to equivalent evaporation [mm day-1] using
  energy_to_evap.

  Based on FAO equation 38 in Allen et al (1998).

  ## Parameters
    - sol_rad: gross incoming solar radiation (MJ m-2 day-1). if necessary, can estimate with methods whose name begins with sol_rad_from
    - albedo: albedo of the crop as the proportion of gross incoming solar radiation that is reflected by the surface. default value is 0.23, which is the value used by the FAO for a short grass reference crop. albedo can be as high as 0.95 for freshly fallen snow and as low as 0.05 for wet bare soil. a green vegetation over has an albedo of about 0.20-0.25 (Allen et al, 1998)

  ## Returns
    - net incoming solar (or shortwave) radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.net_in_sol_rad()

  """
  @spec net_in_sol_rad(float, float) :: float
  def net_in_sol_rad(sol_rad, albedo \\ 0.23) do
    (1 - albedo) * sol_rad
  end

  @doc """
  Estimate net outgoing longwave radiation.

  This is the net longwave energy (net energy flux) leaving the
  earth's surface. It is proportional to the absolute temperature of
  the surface raised to the fourth power according to the Stefan-Boltzmann
  law. However, water vapour, clouds, carbon dioxide and dust are absorbers
  and emitters of longwave radiation. This method corrects the Stefan-
  Boltzmann law for humidity (using actual vapor pressure) and cloudiness
  (using solar radiation and clear sky radiation). The concentrations of all
  other absorbers are assumed to be constant.

  The output can be converted to equivalent evaporation [mm day-1] using energy_to_evap.

  Based on FAO equation 39 in Allen et al (1998).

  ## Parameters
    - tmin: absolute daily min temp (degrees Kelvin)
    - tmax: absolute daily max temp (degrees Kelvin)
    - sol_rad: solar radiation (MJ m-2 day-1). if necessary, can estimate with methods with names beginning with sol_rad
    - cs_rad: clear sky radiation (MJ m-2 day-1). can estimate with cs_rad
    - avp: actual vapour pressure (kPa). can estimate with methods with names beginning with avp_from

  ## Returns
    - net outgoing longwave radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.net_out_lw_rad()

  """
  @spec net_out_lw_rad(float, float, float, float, float) :: float
  def net_out_lw_rad(tmin, tmax, sol_rad, cs_rad, avp) do
    tmp1 = @stefan_boltzman_constant * ((tmax ** 4 + tmin ** 4) / 2)
    tmp2 = 0.34 - 0.14 * :math.sqrt(avp)
    tmp3 = 1.35 * (sol_rad / cs_rad) - 0.35
    tmp1 * tmp2 * tmp3
  end

  @doc """
  Calculate daily net radiation at the crop surface, assuming a grass
  reference crop.

  Net radiation is the difference between the incoming net shortwave (or
  solar) radiation and the outgoing net longwave radiation. Output can be
  converted to equivalent evaporation [mm day-1] using energy_to_evap.

  Based on equation 40 in Allen et al (1998).

  ## Parameters
    - ni_sw_rad: net incoming shortwave radiation (MJ m-2 day-1). can estimate with net_in_sol_rad
    - no_lw_rad: net outgoing longwave radiation (MJ m-2 day-1). can estimate with net_out_lw_rad

  ## Returns
    - daily net radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.net_rad()

  """
  @spec net_rad(float, float) :: float
  def net_rad(ni_sw_rad, no_lw_rad) do
    ni_sw_rad - no_lw_rad
  end

  @doc """
  Calculate the psychrometric constant.

  This method assumes that the air is saturated with water vapour at the
  minimum daily temperature. This assumption may not hold in arid areas.

  Based on equation 8, page 95 in Allen et al (1998).

  ## Parameters
    - atmos_pres: atmospheric pressure (kPa). can estimate with atm_pressure

  ## Returns
    - psychrometric constant (kPa degC-1)

  ## Examples

      iex> ExEto.psy_const()

  """
  @spec psy_const(float) :: float
  def psy_const(atmos_pres) do
    0.000665 * atmos_pres
  end

  @doc """
  Calculate the psychrometric constant for different types of
  psychrometer at a given atmospheric pressure.

  Based on FAO equation 16 in Allen et al (1998).

  psychrometer types:
    1. ventilated (Asmann or aspirated type) psychrometer with an air movement of approximately 5 m/s
    2. natural ventilated psychrometer with an air movement of approximately 1 m/s
    3. non ventilated psychrometer installed indoors

  ## Parameters
    - psychrometer: integer between 1 and 3 which denotes type of psychrometer
    - atmos_pres: atmospheric pressure [kPa]. Can be estimated using atm_pressure

  ## Returns
    - psychrometric constant (kPa degC-1)

  ## Examples

      iex> ExEto.psy_const_of_psychrometer()

  """
  @spec psy_const_of_psychrometer(integer, float) :: float
  def psy_const_of_psychrometer(psychrometer, atmos_pres) do
    # Select coefficient based on type of ventilation of the wet bulb
    psy_coeff =
      case psychrometer do
        1 ->
          0.000662

        2 ->
          0.000800

        3 ->
          0.001200

        _ ->
          raise ArgumentError, message: "psychrometer should be in range 1 to 3: #{psychrometer}"
      end

    psy_coeff * atmos_pres
  end

  @doc """
  Calculate relative humidity as the ratio of actual vapour pressure
  to saturation vapour pressure at the same temperature.

  See Allen et al (1998), page 67 for details.

  ## Parameters
    - avp: actual vapour pressure (units do not matter so long as they are the same as for *svp*). can estimate with methods whose name begins with avp_from
    - svp: saturated vapour pressure (units do not matter so long as they are the same as for *avp*). can estimate with svp_from_t

  ## Returns
    - relative humidity (%)

  ## Examples

      iex> ExEto.psy_const_of_psychrometer()

  """
  @spec rh_from_avp_svp(float, float) :: float
  def rh_from_avp_svp(avp, svp) do
    100.0 * avp / svp
  end

  @doc """
  Calculate solar declination from day of the year.

  Based on FAO equation 24 in Allen et al (1998).

  ## Parameters
    - day_of_year: ay of year integer between 1 and 365 or 366

  ## Returns
    - solar declination (radians)

  ## Examples

      iex> ExEto.psy_const_of_psychrometer()

  """
  @spec sol_dec(integer) :: float
  def sol_dec(day_of_year) do
    {:ok, day_of_year} = ExETo.Validation.check_doy(day_of_year)
    0.409 * :math.sin(2.0 * :math.pi() / 365.0 * day_of_year - 1.39)
  end

  @doc """
  Calculate incoming solar (or shortwave) radiation, *Rs* (radiation hitting
  a horizontal plane after scattering by the atmosphere) from relative
  sunshine duration.

  If measured radiation data are not available this method is preferable
  to calculating solar radiation from temperature. If a monthly mean is
  required then divide the monthly number of sunshine hours by number of
  days in the month and ensure that *et_rad* and *daylight_hours* was
  calculated using the day of the year that corresponds to the middle of
  the month.

  Based on equations 34 and 35 in Allen et al (1998).

  ## Parameters
    - daylight_hours: number of daylight hours (hours). can calculate with daylight_hours()
    - sunshine_hours: sunshine duration (hours). can calculate with sunshine_hours()
    - et_rad: extraterrestrial radiation (MJ m-2 day-1). can estimate with et_rad()

  ## Returns
    - incoming solar (or shortwave) radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.sol_rad_from_sun_hours()

  """
  @spec sol_rad_from_sun_hours(integer, integer, float) :: float
  def sol_rad_from_sun_hours(daylight_hours, sunshine_hours, et_rad) do
    {:ok, sunshine_hours} = ExETo.Validation.check_day_hours(sunshine_hours, "sunshine_hours")
    {:ok, daylight_hours} = ExETo.Validation.check_day_hours(daylight_hours, "daylight_hours")

    # 0.5 and 0.25 are default values of regression constants (Angstrom values)
    # recommended by FAO when calibrated values are unavailable.
    (0.5 * sunshine_hours / daylight_hours + 0.25) * et_rad
  end

  @doc """
  Estimate incoming solar (or shortwave) radiation, *Rs*, (radiation hitting
  a horizontal plane after scattering by the atmosphere) from min and max
  temperature together with an empirical adjustment coefficient for
  'interior' and 'coastal' regions.

  The formula is based on equation 50 in Allen et al (1998) which is the
  Hargreaves radiation formula (Hargreaves and Samani, 1982, 1985). This
  method should be used only when solar radiation or sunshine hours data are
  not available. It is only recommended for locations where it is not
  possible to use radiation data from a regional station (either because
  climate conditions are heterogeneous or data are lacking).

  **NOTE**: this method is not suitable for island locations due to the
  moderating effects of the surrounding water.

  ## Parameters
    - et_rad: extraterrestrial radiation (MJ m-2 day-1). can estimate with et_rad()
    - cs_rad: clear sky radiation (MJ m-2 day-1). can estimate with cs_rad()
    - tmin: daily min temp (deg C)
    - tmax: daily max tempe (deg C)
    - coastal: true if site is a coastal location, situated on or adjacent to coast of a large land mass and where air masses are influenced by a nearby water body, false if interior location where land mass dominates and air masses are not strongly influenced by a large water body

  ## Returns
    - incoming solar (or shortwave) radiation (Rs) (MJ m-2 day-1)

  ## Examples

      iex> ExEto.sol_rad_from_t()

  """
  @spec sol_rad_from_t(float, float, float, float, boolean) :: float
  def sol_rad_from_t(et_rad, cs_rad, tmin, tmax, coastal) do
    # Determine value of adjustment coefficient [deg C-0.5] for
    # coastal/interior locations
    adj = if(coastal, do: 0.19, else: 0.16)

    sol_rad = adj * :math.sqrt(tmax - tmin) * et_rad

    # The solar radiation value is constrained by the clear sky radiation
    min(sol_rad, cs_rad)
  end

  @doc """
  Estimate incoming solar (or shortwave) radiation, *Rs* (radiation hitting
  a horizontal plane after scattering by the atmosphere) for an island
  location.

  An island is defined as a land mass with width perpendicular to the
  coastline <= 20 km. Use this method only if radiation data from
  elsewhere on the island is not available.

  **NOTE**: This method is only applicable for low altitudes (0-100 m)
  and monthly calculations.

  Based on FAO equation 51 in Allen et al (1998).

  ## Parameters
    - et_rad: extraterrestrial radiation (MJ m-2 day-1). can be estimate with et_rad()

  ## Returns
    - incoming solar (or shortwave) radiation (MJ m-2 day-1)

  ## Examples

      iex> ExEto.sol_rad_island()

  """
  @spec sol_rad_island(float) :: float
  def sol_rad_island(et_rad) do
    0.7 * et_rad - 4.0
  end

  @doc """
  Calculate sunset hour angle (*Ws*) from latitude and solar
  declination.

  Based on FAO equation 25 in Allen et al (1998).

  ## Parameters
    - latitude: latitude (radians). note: *latitude* should be negative if it in the southern hemisphere, positive if in the northern hemisphere
    - sol_dec: solar declination (radians). can calculate with sol_dec()

  ## Returns
    - sunset hour angle (radians)

  ## Examples

      iex> ExEto.sunset_hour_angle()

  """
  @spec sunset_hour_angle(float, float) :: float
  def sunset_hour_angle(latitude, sol_dec) do
    {:ok, latitude} = ExETo.Validation.check_latitude_rad(latitude)
    {:ok, sol_dec} = ExETo.Validation.check_sol_dec_rad(sol_dec)

    cos_sha = -:math.tan(latitude) * :math.tan(sol_dec)
    # If cos_sha is >= 1 there is no sunset, i.e. 24 hours of daylight
    # If cos_sha is <= 1 there is no sunrise, i.e. 24 hours of darkness
    # See http://www.itacanet.org/the-sun-as-a-source-of-energy/
    # part-3-calculating-solar-angles/
    # Domain of acos is -1 <= x <= 1 radians (this is not mentioned in FAO-56!)
    :math.acos(min(max(cos_sha, -1.0), 1.0))
  end

  @doc """
  Estimate saturation vapour pressure (*es*) from air temperature.

  Based on equations 11 and 12 in Allen et al (1998).

  ## Parameters
    - t: temp (deg C)

  ## Returns
    - saturation vapour pressure (kPa)

  ## Examples

      iex> ExEto.svp_from_t()

  """
  @spec svp_from_t(float) :: float
  def svp_from_t(t) do
    0.6108 * :math.exp(17.27 * t / (t + 237.3))
  end

  @doc """
  Convert wind speed measured at different heights above the soil
  surface to wind speed at 2 m above the surface, assuming a short grass
  surface.

  Based on FAO equation 47 in Allen et al (1998).

  ## Parameters
    - ws: measured wind speed (m s-1)
    - z: height of wind measurement above ground surface (m)

  ## Returns
    - wind speed at 2 m above the surface (m s-1)

  ## Examples

      iex> ExEto.wind_speed_2m()

  """
  @spec wind_speed_2m(float, float) :: float
  def wind_speed_2m(ws, z) do
    ws * (4.87 / :math.log(67.8 * z - 5.42))
  end

  # TODO
  # def thornthwaite(monthly_t, monthly_mean_dlh, year \\ nil) do
  # end

  # TODO
  # def monthly_mean_daylight_hours(latitude, year \\ nil) do
  # end
end
