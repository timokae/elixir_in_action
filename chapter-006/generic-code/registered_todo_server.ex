defmodule ServerProcess do
    def start(callback_module) do
        spawn(fn ->
            initial_state = callback_module.init
            loop(callback_module, initial_state)
        end)
    end

    defp loop(callback_module, current_state) do
        receive do
            {:call, request, caller} ->
                {response, new_state} = callback_module.handle_call(
                    request,
                    current_state
                )

            send(caller, {:response, response})
            loop(callback_module, new_state)

        {:cast, request} ->
            new_state = callback_module.handle_cast(
                request,
                current_state
            )

            loop(callback_module, new_state)
        end
    end

    def call(server_pid, request) do
        send(server_pid, {:call, request, self})

        receive do
            {:response, response} ->
                response
        end
    end

    def cast(server_pid, request) do
        send(server_pid, {:cast, request})
    end
end

defmodule TodoServer do
    def start do
        ServerProcess.start(TodoServer)
    end

    def init do
        Process.register(self(), :todo_server)
        TodoList.new
    end

    # --- Request Functions ---
    
    def entries(date) do
        ServerProcess.call(:todo_server, {:entries, date})
    end

    def add_entry(new_entry) do
        ServerProcess.cast(:todo_server, {:add_entry, new_entry})
    end

    def delete_entry(id) do
        ServerProcess.cast(:todo_server, {:delete_entry, id})
    end

    # > TodoServer.update_entry(server_pid, 1, &Map.put(&1, :title, "New Title") 
    def update_entry(id, updater_fun) do
        ServerProcess.cast(:todo_server, {:update_entry, id, updater_fun})
    end

    # --- Handle Call ---

    # Entries
    def handle_call({:entries, date}, todo_list) do
        {TodoList.entries(todo_list, date), todo_list}
    end

    # --- Handle Cast ---

    # Add Entry
    def handle_cast({:add_entry, new_entry}, todo_list) do
        TodoList.add_entry(todo_list, new_entry)
    end

    # Delete Entry
    def handle_cast({:delete_entry, id}, todo_list) do
        TodoList.delete_entry(todo_list, id)
    end

    # Update Entry
    def handle_cast({:update_entry, id, updater_fun}, todo_list) do
        TodoList.update_entry(todo_list, id, updater_fun)
    end
end

defmodule TodoList do
    defstruct auto_id: 1, entries: HashDict.new

    #def new, do: %TodoList{}

    def new(entries \\ []) do
        Enum.reduce(
            entries,
            %TodoList{},
            fn(entry, todo_list_acc) ->
                add_entry(todo_list_acc, entry)
            end
        )
    end
    
    def add_entry(
        %TodoList{entries: entries, auto_id: auto_id} = todo_list,
        entry
    ) do
        entry = Map.put(entry, :id, auto_id)
        new_entries = HashDict.put(entries, auto_id, entry)

        %TodoList{todo_list |
            entries: new_entries,
            auto_id: auto_id + 1
        }
    end

    def entries(%TodoList{entries: entries}, date) do
        entries
            |> Stream.filter(fn({_,entry}) -> 
                entry.date == date 
            end)
            |> Enum.map(fn({_,entry}) ->
                entry
            end)
    end

    def update_entry(
        %TodoList{entries: entries} = todo_list,
        entry_id,
        updater_fun
    ) do
        case entries[entry_id] do
            nil -> todo_list

            old_entry -> 
                new_entry = updater_fun.(old_entry)
                new_entries = HashDict.put(entries, new_entry.id, new_entry)
                %TodoList{todo_list | entries: new_entries}
        end
    end

    def delete_entry(
        %TodoList{entries: entries} = todo_list,
        entry_id
    ) do
        %TodoList{todo_list | entries: HashDict.delete(entries, entry_id)};
    end
end