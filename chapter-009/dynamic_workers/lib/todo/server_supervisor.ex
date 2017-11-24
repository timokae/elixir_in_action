defmodule Todo.ServerSupervisor do
    use Supervisor

    def start_link do
        Supervisor.start_link(
            __MODULE__,
            nil,
            name: :todo_server_supervisor
        )
    end

    def init(_) do
        supervise(
            [worker(Todo.Server, [])],
            strategy: :simple_one_for_one
        )
    end

    def start_child(name) do
        Supervisor.start_child(:todo_server_supervisor, [name])
    end
end