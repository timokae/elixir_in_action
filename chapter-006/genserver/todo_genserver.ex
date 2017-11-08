defmodule TodoServer do
    use GenServer

    def start do
        GenServer.start(TodoServer, nil)
    end

    def init(_) do
        Process.register(self(), :todo_server)
        {:ok, TodoList.new}
    end

    # --- Request Functions ---
    
    def entries(date) do
        GenServer.call(:todo_server, {:entries, date})
    end

    def add_entry(new_entry) do
        GenServer.cast(:todo_server, {:add_entry, new_entry})
    end

    def delete_entry(id) do
        GenServer.cast(:todo_server, {:delete_entry, id})
    end

    # > TodoServer.update_entry(server_pid, 1, &Map.put(&1, :title, "New Title") 
    def update_entry(id, updater_fun) do
        GenServer.cast(:todo_server, {:update_entry, id, updater_fun})
    end

    # --- Handle Call ---

    # Entries
    def handle_call({:entries, date}, _, todo_list) do
        {:reply, TodoList.entries(todo_list, date), todo_list}
    end

    # --- Handle Cast ---

    # Add Entry
    def handle_cast({:add_entry, new_entry}, todo_list) do
        {:noreply, TodoList.add_entry(todo_list, new_entry)}
    end

    # Delete Entry
    def handle_cast({:delete_entry, id}, todo_list) do
        {:noreply, TodoList.delete_entry(todo_list, id)}
    end

    # Update Entry
    def handle_cast({:update_entry, id, updater_fun}, todo_list) do
        {:noreply, TodoList.update_entry(todo_list, id, updater_fun)}
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