# Structs

# A Struct is similar to a Map however we can set default values
# and it has compile time checking of properties.
# Structs enforce that the only properties I can use are the ones
# that I have defined on the Struct.

# iex(3)> %Identicon.Image{}
# %Identicon.Image{hex: nil}
# iex(4)> %Identicon.Image{hex: []}
# %Identicon.Image{hex: []}

defmodule Identicon.Image do
  defstruct hex: nil, color: nil, grid: nil, pixel_map: nil
end