defmodule Todo.ProcessRegistry do
    use GenServer
    import Kernel, except: [send: 2]

    def start_link do
        IO.puts "Starting process registry"
        GenServer.start_link(__MODULE__, nil, name: :process_registry)
    end


    def init(_) do
        :ets.new(:ets_registry, [:set, :named_table, :protected])
        {:ok, nil}
    end

    def register_name(key, pid) do
        GenServer.call(:process_registry, {:register_name, key, pid})
    end

    def unregister_name(key) do
        GenServer.call(:process_registry, {:unregister_name, key})
    end

    def whereis_name(key) do
        case :ets.lookup(:ets_registry, key) do
            [{^key, pid}] -> pid

            _ -> :undefined
        end
    end

    def handle_call({:register_name, key, pid}, _, state) do
        if whereis_name(key) != :undefined do
            {:reply, :no, state}
        else
            Process.monitor(pid)
            :ets.insert(:ets_registry, {key, pid})
            {:reply, :yes, state}
        end
    end

    def handle_call({:unregister_name, key}, _, state) do
        :ets.delete(:ets_registry, key)
        {:reply, key, state}
    end

    def handle_info({:DOWN, _, :process, terminated_pid, _}, state) do
        :ets.match_delete(:ets_registry, {:_, terminated_pid})
        {:noreply, state}
    end

    def send(key, message) do
        case whereis_name(key) do
            :undefined -> {:badarg, {key, message}}
            pid ->
                Kernel.send(pid, message)
                pid
        end
    end
end