defmodule EnumStreams do
    def filtered_lines!(path) do
        File.stream!(path)
            |> Stream.map(&String.replace(&1, "\n", ""))
    end

    def large_lines!(path) do
        filtered_lines!(path)
            |> Enum.filter(&(String.length(&1) > 80))
    end

    def lines_length!(path) do
        filtered_lines!(path)
            |> Enum.map(&(String.length(&1)))
    end

    def longest_line_length!(path) do
        filtered_lines!(path)
            |> Stream.map(&(String.length(&1)))
            |> Enum.reduce(0, &max(&1,&2))
    end

    def longest_line!(path) do
        filtered_lines!(path)
            |> Enum.reduce("", &longer_line(&1,&2))
    end

    defp longer_line(line1, line2) do
        if String.length(line1) > String.length(line2) do
            line1
        else
            line2
        end
    end

    def words_per_line(path \\ "./example.txt") do
        filtered_lines!(path)
            |>  Stream.map(&(String.split(&1)))
            |>  Enum.map(&(length(&1)))
    end
end 
