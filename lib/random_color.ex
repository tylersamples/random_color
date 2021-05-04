defmodule RandomColor do
  @moduledoc """
  Documentation for `RandomColor`.
  """

  alias RandomColor.Color

  defmodule Color do
    defstruct [:name, :lower_bounds, :hue_range, :saturation_range, :brightness_range]

    def color_dictionary() do
      [
        monochrome: monochrome(),
        red: red(),
        orange: orange(),
        yellow: yellow(),
        green: green(),
        blue: blue(),
        purple: purple(),
        pink: pink()
      ]
    end

    def monochrome do
      define("monochrome", nil, [
        0..0,
        100..0
      ])
    end

    def red do
      define("red", -26..18, [
        20..100,
        30..92,
        40..89,
        50..85,
        60..78,
        70..70,
        80..60,
        90..55,
        100..50
      ])
    end

    def orange do
      define("orange", 18..46, [
        20..100,
        30..93,
        40..88,
        50..86,
        60..85,
        70..70,
        100..70
      ])
    end

    def yellow do
      define("yellow", 46..62, [
        25..100,
        40..94,
        50..89,
        60..86,
        70..84,
        80..82,
        90..80,
        100..75
      ])
    end

    def green do
      define("green", 62..178, [
        30..100,
        40..90,
        50..85,
        60..81,
        70..74,
        80..64,
        90..50,
        100..40
      ])
    end

    def blue do
      define("blue", 178..257, [
        20..100,
        30..86,
        40..80,
        50..74,
        60..60,
        70..52,
        80..44,
        90..39,
        100..35
      ])
    end

    def purple do
      define("purple", 257..282, [
        20..100,
        30..87,
        40..79,
        50..70,
        60..65,
        70..59,
        80..52,
        90..45,
        100..42
      ])
    end

    def pink do
      define("pink", 282..334, [
        20..100,
        30..90,
        40..86,
        60..84,
        80..80,
        90..75,
        100..73
      ])
    end

    defp define(name, hue_range, lower_bounds) do
      first = hd(lower_bounds)
      last = Enum.at(lower_bounds, Enum.count(lower_bounds) - 1)

      s_min..b_max = first
      s_max..b_min = last

      %Color{
        name: name,
        lower_bounds: lower_bounds,
        hue_range: hue_range,
        saturation_range: s_min..s_max,
        brightness_range: b_min..b_max
      }
    end

    def get_color_info(hue) do
      hue =
        if hue >= 334 and hue <= 360 do
          hue - 360
        else
          hue
        end

      Enum.reduce_while(color_dictionary(), nil, fn foo = {name, color}, _acc ->
        if not is_nil(color.hue_range) and Enum.member?(color.hue_range, hue) do
          {:halt, color}
        else
          {:cont, nil}
        end
      end)
    end
  end

  def random_color(opts \\ [])

  def random_color(opts) do
    h = pick_hue(opts)
    s = pick_saturation(h, opts)
    v = pick_brightness(h, s, opts)

    set_format({h, s, v}, opts)
  end

  def pick_hue(opts) do
    hue_range = 0..360

    hue = Enum.random(hue_range)

    hue
  end

  def pick_saturation(h, opts) do
    color_info = Color.get_color_info(h)

    saturation_range = color_info.saturation_range

    s_min..s_max = saturation_range

    saturation_range =
      cond do
        opts[:luminosity] == :bright -> 55..s_max
        opts[:luminosity] == :dark -> (s_max - 10)..s_max
        opts[:luminosity] == :light -> s_min..55
        true -> saturation_range
      end

    Enum.random(saturation_range)
  end

  def pick_brightness(h, s, opts) do
    b_min = floor(get_min_brightness(h, s))
    b_max = 100

    brightness_range =
      cond do
        opts[:luminosity] == :random -> 0..100
        opts[:luminosity] == :dark -> b_min..(b_min + 20)
        opts[:luminosity] == :light -> ((b_max + b_min) / 2)..b_max
        true -> b_min..b_max
      end

    Enum.random(brightness_range)
  end

  def set_format(hsv = {_h, _s, _v}, opts) do
    cond do
      opts[:format] == :hsv ->
        hsv

      opts[:format] == :rgb ->
        hsv_to_rgb(hsv)

      true ->
        hsv_to_hex(hsv)
    end
  end

  def hsv_to_hex(hsv) do
    hsv
    |> hsv_to_rgb()
    |> Tuple.to_list()
    |> Enum.reduce("#", fn v, acc ->
      acc <> (v |> Integer.to_string(16) |> String.pad_leading(2, "0"))
    end)
  end

  def hsv_to_rgb({h, s, v}) do
    h =
      case h do
        0 -> 1
        360 -> 359
        _ -> h
      end

    {h, s, v} = {h / 360, s / 100, v / 100}

    h_i = floor(h * 6) |> IO.inspect()
    f = h * 6 - h_i
    p = v * (1 - s)
    q = v * (1 - f * s)
    t = v * (1 - (1 - f) * s)

    {r, g, b} =
      case h_i do
        0 -> {v, t, p}
        1 -> {q, t, p}
        2 -> {p, v, t}
        3 -> {p, q, v}
        4 -> {t, p, v}
        5 -> {v, p, q}
      end

    {floor(r * 255), floor(g * 255), floor(b * 255)} |> IO.inspect(label: :out)
  end

  defp get_min_brightness(h, s) do
    color_info = Color.get_color_info(h)

    lower_bounds = color_info.lower_bounds

    lower_bounds
    |> Enum.with_index()
    |> Enum.reduce_while(0, fn {lb, index}, acc ->
      next = Enum.at(lower_bounds, index + 1)

      s1..v1 = lb
      s2..v2 = next

      if s >= s1 and s <= s2 do
        m = v2 / v1 / (s2 - s1)
        b = v1 - m * s1

        {:halt, m * s + b}
      else
        {:cont, acc}
      end
    end)
  end
end
