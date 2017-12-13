defmodule Identicon do
  @moduledoc """
  Creates an Identicon from user input.
  """

  @doc """
  Takes in user input and returns Identicon.

  ## Examples

      iex> Identicon.main("asdf")

  """
  def main(input) do
    input
    |> hash_input
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(input)
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def draw_image(%Identicon.Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      # this is actually modifying the original image, not returning a copy.
      :egd.filledRectangle(image, start, stop, fill)
    end
    :egd.render(image)
  end

  def build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({ _code, index }) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = { horizontal, vertical }
      bottom_right = { horizontal + 50, vertical + 50 }
      { top_left, bottom_right }
    end
    %Identicon.Image{image | pixel_map: pixel_map}
  end

  @doc """
  Takes in a hex_list and returns Identicon.Image Struct
  with defined hex & color property.

  ## Examples

      iex> Identicon.main("asdf")
      %Identicon.Image{color: {145, 46, 200},hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]}

  """
  def pick_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    # WTF is happening here!?!?!
    # well this...
    # image is a Struct that has a list of hex values
    # pull out the first three values and
    # pipe the rest of the values to _tail
    # then return a new Struct with image supplied
    # and color updated to the first 3 values of image.
    %Identicon.Image{image | color: {r, g, b}}
  end

  @doc """
  Takes in user input and returns Identicon.Image Struct with hex property as value of hashed input.

  ## Examples

      iex> Identicon.hash_input("asdf")
      %Identicon.Image{color: nil, hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]}

  """
  def hash_input(input) do
    hex = :crypto.hash(:md5, input)
    |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  @doc """
  Takes in an image struct and returns an updated image struct with a grid value present.

  ## Examples

    iex> Identicon.main("asdf")
    %Identicon.Image{color: nil, hex: [145, 46, 200, 3, 178, 206, 73, 228, 165, 65, 6, 141, 73, 90, 181, 112]}

  """
  def build_grid(%Identicon.Image{hex: hex} = image) do
    # &method/#
    # we pass around references to functions using the '&' symbol
    # to specify the function we use '/' and declare the arity of the function
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{image | grid: grid }
  end

  @doc """
  Takes in an list of numbers and returns list with first 2 values added to the end of the list.

  ## Examples

    iex> Identicon.mirror_row([145, 46, 200])
    [145, 46, 200, 46, 145]

  """
  def mirror_row(row) do
    [first, second | _tail] = row
    # ++ operator is how we add to lists
    row ++ [second, first]
  end

  @doc """
  Takes in an image struct and returns ____.

  ## Examples

    iex> Identicon.mirror_row([145, 46, 200])
    [145, 46, 200, 46, 145]

  """
  def filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({ code, _index }) ->
      # calculates the remainder
      rem(code, 2) == 0
    end
    %Identicon.Image{image | grid: grid }
  end

end
