defmodule RandomColor.Color do
  @moduledoc false
  defstruct [:name, :lower_bounds, :hue_range, :saturation_range, :brightness_range]

  alias RandomColor.Color

  def monochrome do
    define(:monochrome, nil, [
      0..0,
      100..0
    ])
  end

  def red do
    define(:red, -26..18, [
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
    define(:orange, 18..46, [
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
    define(:yellow, 46..62, [
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
    define(:green, 62..178, [
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
    define(:blue, 178..257, [
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
    define(:purple, 257..282, [
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
    define(:pink, 282..334, [
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

    Enum.reduce_while(RandomColor.color_dictionary(), nil, fn {_name, color}, _acc ->
      if not is_nil(color.hue_range) and Enum.member?(color.hue_range, hue) do
        {:halt, color}
      else
        {:cont, nil}
      end
    end)
  end

  def get_color_hue_range(color_name) do
    color =
      Enum.reduce_while(RandomColor.color_dictionary(), nil, fn {name, color}, _acc ->
        if name == color_name do
          {:halt, color}
        else
          {:cont, nil}
        end
      end)

    if not is_nil(color) and not is_nil(color.hue_range) do
      color.hue_range
    else
      0..360
    end
  end
end
