defmodule RecursionPracticeTc do
    # --- list_len/1 ---
    def list_len(list) do
        calc_list_len(0, list)
    end

    defp calc_list_len(len, []), do: len

    defp calc_list_len(len, [_|tail]) do
        calc_list_len(len + 1, tail)        
    end

    # --- range/2 ---
    def range(from, to) when from < to do
        calc_range(from, to, [])
    end

    defp calc_range(from, to, list) when from > to do
        list
    end

    defp calc_range(from, to, list) do
        calc_range(from, to - 1, [to|list])
    end

    # --- positive/1 ---
    def positive(list) do
        filter_positive(list, [])
    end

    defp filter_positive([], list) do
        Enum.reverse(list)
    end

    defp filter_positive([head|tail], list) when head > 0 do
        filter_positive(tail, [head|list])
    end

    defp filter_positive([_|tail], list) do
        filter_positive(tail, list)
    end
end