defmodule RecursionPractice do
    # --- list_len/1 ---
    def list_len([]), do: 0

    def list_len([_|tail]) do
        1 + list_len(tail)
    end

    # --- range/2 ---
    def range(from, to) when from > to do
        []
    end

    def range(from, to) do
        [from|range(from + 1, to)]
    end

    # --- positive/1 ---
    def positive([]), do: []

    def positive([head|tail]) when head > 0 do
        [head|positive(tail)]
    end

    def positive([_|tail]) do
        positive(tail)
    end
end