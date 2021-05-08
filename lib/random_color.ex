defmodule RandomColor do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias RandomColor.Color

  ## Dictionary

  @color_dictionary [
    monochrome: Color.monochrome(),
    red: Color.red(),
    orange: Color.orange(),
    yellow: Color.yellow(),
    green: Color.green(),
    blue: Color.blue(),
    purple: Color.purple(),
    pink: Color.pink()
  ]

  @doc false
  def color_dictionary do
    @color_dictionary
  end

  ## Interface

  @doc """
  Generator a random color

  ## Options
    * `hue:` - `:monochrome`, `:red`, `:orange`, `:yellow`, `:green`, `:blue`, `:purple`, `:pink`
    * `luminosity:` - `:dark`, `:bright`, `:light`, `:random`
    * `format:` - `:string` (default), `:tuple`

  ## Output Format
    * `string` - `"rgb(221, 186, 95)"`
    * `tuple` - `{221, 186, 95}`

  ## Examples
      iex> RandomColor.rgb(hue: :red, luminosity: :light)

  """
  def rgb(opts \\ []) do
    format = Keyword.get(opts, :format, :string)

    opts
    |> random_color()
    |> hsv_to_rgb()
    |> format(:rgb, format)
  end

  @doc """
  Generator a random color

  ## Options
    * `hue:` - `:monochrome`, `:red`, `:orange`, `:yellow`, `:green`, `:blue`, `:purple`, `:pink`
    * `luminosity:` - `:dark`, `:bright`, `:light`, `:random`
    * `format:` - `:string` (default), `:tuple`


    `alpha` a value between `0.0` and `1.0`

  ## Output Format
    * `string` - `"rgba(221, 186, 95, 0.1)"`
    * `tuple` - `{221, 186, 95, 0.1}`

  ## Examples
      iex> RandomColor.rgba([hue: :purple], 0.8)

  """
  def rgba(opts \\ [], alpha \\ nil) do
    format = Keyword.get(opts, :format, :string)

    hsv = random_color(opts)

    alpha =
      if alpha do
        alpha
      else
        Enum.random(0..10) / 10
      end

    hsv
    |> hsv_to_rgb()
    |> Tuple.append(alpha)
    |> format(:rgba, format)
  end

  @doc """
  Generator a random color

  ## Options
    * `hue:` - `:monochrome`, `:red`, `:orange`, `:yellow`, `:green`, `:blue`, `:purple`, `:pink`
    * `luminosity:` - `:dark`, `:bright`, `:light`, `:random`

  ## Output Format
    * `string` - `"#13B592"`

  ## Examples
      iex> RandomColor.hex(hue: :blue)


  """
  def hex(opts \\ []) do
    opts
    |> random_color()
    |> hsv_to_hex()
  end

  @doc """
  Generator a random color

  ## Options
    * `hue:` - `:monochrome`, `:red`, `:orange`, `:yellow`, `:green`, `:blue`, `:purple`, `:pink`
    * `luminosity:` - `:dark`, `:bright`, `:light`, `:random`
    * `format:` - `:string` (default), `:tuple`

  ## Output Format
    * `string` - `"hsl(139, 82.32%, 71.725%)"`
    * `tuple` - `{139, 82.32, 71.725}`

  ## Examples
      iex> RandomColor.hsl(hue: :yellow, luminosity: :light)
  """
  def hsl(opts \\ []) do
    format = Keyword.get(opts, :format, :string)

    opts
    |> random_color()
    |> hsv_to_hsl()
    |> format(:hsl, format)
  end

  @doc """
  Generator a random color

  ## Options
    * `hue:` - `:monochrome`, `:red`, `:orange`, `:yellow`, `:green`, `:blue`, `:purple`, `:pink`
    * `luminosity:` - `:dark`, `:bright`, `:light`, `:random`
    * `format:` - `:string` (default), `:tuple`


    `alpha` a value between `0.0` and `1.0`

  ## Output Format
    * `string` - `"hsl(139, 82.32%, 71.725%)"`
    * `tuple` - `{139, 82.32, 71.725}`

  ## Examples
      iex> RandomColor.hsl(hue: :yellow, luminosity: :light)

  """
  def hsla(opts \\ [], alpha \\ nil) do
    format = Keyword.get(opts, :format, :string)

    hsv = random_color(opts)

    alpha =
      if alpha do
        alpha
      else
        Enum.random(0..10) / 10
      end

    hsv
    |> hsv_to_hsl()
    |> Tuple.append(alpha)
    |> format(:hsla, format)
  end

  ## Implementation

  defp random_color(opts) do
    # FIXME(ts): handle seed opt

    h = pick_hue(opts)
    s = pick_saturation(h, opts)
    v = pick_brightness(h, s, opts)

    {h, s, v}
  end

  defp pick_hue(opts) do
    hue_opt = Keyword.get(opts, :hue)
    hue_range = Color.get_color_hue_range(hue_opt)

    hue = Enum.random(hue_range)

    if hue < 0 do
      360 + hue
    else
      hue
    end
  end

  defp pick_saturation(h, opts) do
    cond do
      opts[:hue] === :monochrome ->
        0

      opts[:luminosity] === :random ->
        Enum.random(0..100)

      true ->
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
  end

  defp pick_brightness(h, s, opts) do
    b_min = floor(get_min_brightness(h, s))
    b_max = 100

    brightness_range =
      cond do
        opts[:luminosity] == :random -> 0..100
        opts[:luminosity] == :dark -> b_min..(b_min + 20)
        opts[:luminosity] == :light -> round((b_max + b_min) / 2)..b_max
        true -> b_min..b_max
      end

    Enum.random(brightness_range)
  end

  defp hsv_to_hex(hsv) do
    hsv
    |> hsv_to_rgb()
    |> Tuple.to_list()
    |> Enum.reduce("#", fn v, acc ->
      acc <> (v |> Integer.to_string(16) |> String.pad_leading(2, "0"))
    end)
  end

  defp hsv_to_hsl({h, s, v}) do
    s = s / 100
    v = v / 100
    k = (2 - s) * v

    {
      h,
      round(
        s * v /
          if k < 1 do
            k
          else
            2 - k
          end * 10000
      ) / 100,
      k / 2 * 100
    }
  end

  defp hsv_to_rgb({h, s, v}) do
    h =
      case h do
        0 -> 1
        360 -> 359
        _ -> h
      end

    {h, s, v} = {h / 360, s / 100, v / 100}

    h_i = floor(h * 6)
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

    {floor(r * 255), floor(g * 255), floor(b * 255)}
  end

  defp get_min_brightness(h, s) do
    color_info = Color.get_color_info(h)

    lower_bounds = color_info.lower_bounds

    lower_bounds
    |> Enum.with_index()
    |> Enum.reduce_while(0, fn {lb, index}, acc ->
      next = Enum.at(lower_bounds, index + 1)

      if next do
        s1..v1 = lb
        s2..v2 = next

        if s >= s1 and s <= s2 do
          m = v2 / v1 / (s2 - s1)
          b = v1 - m * s1

          {:halt, m * s + b}
        else
          {:cont, acc}
        end
      else
        {:halt, 0}
      end
    end)
  end

  ## Formatting

  defp format({r, g, b}, :rgb, :string), do: "rgb(#{r}, #{g}, #{b})"
  defp format(rgb, :rgb, :tuple), do: rgb

  defp format({r, g, b, a}, :rgba, :string), do: "rgba(#{r}, #{g}, #{b}, #{a})"
  defp format(rgba, :rgba, :tuple), do: rgba

  defp format({h, s, l}, :hsl, :string), do: "hsl(#{h}, #{s}%, #{l}%)"
  defp format(hsl, :hsl, :tuple), do: hsl

  defp format({h, s, l, a}, :hsla, :string), do: "hsla(#{h}, #{s}%, #{l}%, #{a})"
  defp format(hsla, :hsla, :tuple), do: hsla
end
