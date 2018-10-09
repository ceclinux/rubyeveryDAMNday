Naming dynamic processes with atoms is a terrible idea! If we use atoms, we would need to convert the bucket name (often received from an external client) to atoms, and **we should never convert user input to atoms**. This is because atoms are not garbage collected. Once an atom is created, it is never reclaimed. Generating atoms from user input would mean the user can inject enough different names to exhaust our system memory!



Instead of abusing the built-in name facilit, we will create our own `process registry` that associates the bucket name to the bucket process.



A Genserver is implemented in two parts: the client API and the server callbacks. You can either combine both parts into a single module or you can separate them into a client module and a server module. The client and server run in separate processes, with the client passing message back and forth to the server as its functions are called.



```elixir
defmodule KV.Registry do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def lookup(server, name) do
    GenServer.call(server, {:lookup, name})
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:lookup, name}, _from, names) do
    {:reply, Map.fetch(names, name), names}
  end

  def handle_cast({:create, name}, names) do
    if Map.has_key?(names, name) do
      {:noreply, names}
    else
      {:ok, bucket} = KV.Bucket.start_link([])
      {:noreply, Map.put(names, name, bucket)}
    end
  end
end

```

1. The module where the server callbacks are implemented, in this case `__MODULE__`, meaning the current module
2.  the initialization arguments, in this case, the atom `:ok`
3. A list of options which can be used to specify things like the name of the server. For now, we forward the list of options that we receive on `start_link/1`, which defaults to an empty list. 

There are two types of requests you can send to GenServer: calls and casts. `Calls` are synchrounous and the server must send a response back to such requests. `Casts` are asynchronous and the server won't send a response back.

The next two functions, `lookup/2` and `create/2` are responsible for sending requests to the server. In this case, we have used `{:lookup, name}` and `{:create, name}` respectively. Requests are often specified as tuples, like this, in order to provide more than one "argument" in that first argument slot. It's common to specifiy the action being requested as the first element of a tuple, and arguments for that action in the remaining elements. Note that the requests must match the first argument to `handle_call/3` or `handle_cast/2`.



That's it for the client API. On the server side, we can implement a varitety callbacks to guarantee the server initialization, termination and handling of requests. Those callbacks are optional and for now, we have oly implemented the ones we care about.



The first is the `init/1` callback, that receives the second argument given to `GenServer.start_link/3` and returns `{:ok, state}`, where state is a new map. We can already notice how the `GenServer` API makes the client/server segregation more apparent. `start_link/3` happens in the client, while `init/1` is the respective callback that runs on the server.



For `call/2` requests, we implement a `handle_call/3` callback that receives the `request`,  the process from which we received the request `_from`, and the current server state `names`. The