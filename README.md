# RandomColor

<!-- MDOC !-->

Elixir port of [davidmerfield/randomColor](https://github.com/davidmerfield/randomColor)

## Installation

The package can be installed
by adding `random_color` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:random_color, "~> 0.1.0"}
  ]
end
```

## Basic Usage

```elixir
RandomColor.hex() # #13B592

RandomColor.rgb() # {189, 81, 542}
RandomColor.rgb(format: :string) # rgb(189, 81, 542)

RandomColor.hex(hue: :red) # #9B112C
RandomColor.hex(hue: :red, luminosity: :light) # #FFB2CA

RandomColor.hsla([], 0.5) # hsla(117, 65.29%, 48.4%, 0.5)
```

<!-- MDOC !-->

The docs can
be found at [https://hexdocs.pm/random_color](https://hexdocs.pm/random_color).

## License

[MIT](./LICENSE)