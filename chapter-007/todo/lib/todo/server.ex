defmodule Todo.Server do
    use GenServer

    def start(name) do
        GenServer.start(Todo.Server, name)
    end

    def init(name) do
        {:ok, {name, Todo.Database.get(name) || Todo.List.new}}
    end

    # --- Request Functions ---
    
    def entries(todo_server, date) do
        GenServer.call(todo_server, {:entries, date})
    end

    def add_entry(todo_server, new_entry) do
        GenServer.cast(todo_server, {:add_entry, new_entry})
    end

    def delete_entry(todo_server, id) do
        GenServer.cast(todo_server, {:delete_entry, id})
    end

    # > TodoServer.update_entry(server_pid, 1, &Map.put(&1, :title, "New Title") 
    def update_entry(todo_server, id, updater_fun) do
        GenServer.cast(todo_server, {:update_entry, id, updater_fun})
    end

    # --- Handle Call ---

    # Entries
    def handle_call({:entries, date}, _, {name, todo_list}) do
        {:reply, Todo.List.entries(todo_list, date), {name, todo_list}}
    end

    # --- Handle Cast ---

    # Add Entry
    def handle_cast({:add_entry, new_entry}, {name, todo_list}) do
        new_state = Todo.List.add_entry(todo_list, new_entry)
        Todo.Database.store(name, new_state)
        {:noreply, {name, new_state}}
    end

    # Delete Entry
    def handle_cast({:delete_entry, id}, {name, todo_list}) do
        new_state = Todo.List.delete_entry(todo_list, id)
        Todo.Database.store(name, new_state)
        {:noreply, {name, new_state}}
    end

    # Update Entry
    def handle_cast({:update_entry, id, updater_fun}, {name, todo_list}) do
        new_state = Todo.List.update_entry(todo_list, id, updater_fun)
        Todo.Database.store(name, new_state)
        {:noreply, {name, new_state}}
    end
end

