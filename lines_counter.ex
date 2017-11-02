defmodule LinesCounter do
    def count(path) do
        file = File.read(path)
        lines_num(file)
        lines_content(file)
    end

    defp lines_content({:ok, contents}) do
        contents
            |> String.split("\n")
            |> Enum.each( &(IO.puts("\t>> #{&1}")) )
    end

    defp lines_content(error), do: error

    defp lines_num({:ok, contents}) do
        contents
            |> String.split("\n")
            |> length
    end

    defp lines_num(error), do: error
end
