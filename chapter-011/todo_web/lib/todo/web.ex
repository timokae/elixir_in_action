defmodule Todo.Web do
	use Plug.Router

    def start_server do
        Plug.Adapters.Cowboy.http(__MODULE__, nil, port: 5454)
    end

	plug :match
	plug :dispatch

	post "/add_entry" do
		conn
		|> Plug.Conn.fetch_query_params
		|> add_entry
		|> respond
	end

	defp add_entry(conn) do
		conn.params["list"]
		|> Todo.Cache.server_process
		|> Todo.Server.add_entry(
			%{
				date: parse_date(conn.params["date"]),
				title: conn.params["title"]
			}
		)

		Plug.Conn.assign(conn, :response, "OK")
	end

	defp respond(conn) do
		conn
		|> Plug.Conn.put_resp_content_type("text/plain")
		|> Plug.Conn.send_resp(200, conn.assigns[:response])
	end

	defp parse_date(
    	# Using pattern matching to extract parts from YYYYMMDD string
    	<< year::binary-size(4), month::binary-size(2), day::binary-size(2) >>
  	) do
    	{String.to_integer(year), String.to_integer(month), String.to_integer(day)}
	end

	match _ do
		Plug.Conn.send_resp(conn, 404, "not found")
	end
end