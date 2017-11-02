defmodule ListHelper do
    def sum(list) do
        do_sum(0, list)
    end

    defp do_sum(current_sum, []) do
        current_sum
    end

    defp do_sum(current_sum, [head|tail]) do
        new_sum = head + current_sum
        do_sum(new_sum, tail)
    end

    def test(number, text) do
        new_number = number + 1
        IO.puts text
        new_number
    end
end