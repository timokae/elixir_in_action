defmodule Circle do
    @moduledoc """
    Implements basic cirlce functions
    """
    @pi 3.14159

    @doc "Computes the area of a cirlce"
    @spec area(number) :: number
    def area(r), do: r*r*@pi

    @doc "Computes the circumference of a cirlce"
    @spec circumference(number) :: number
    def circumference(r), do: 2*r*@pi
end