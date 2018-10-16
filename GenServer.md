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



For `call/2` requests, we implement a `handle_call/3` callback that receives the `request`,  the process from which we received the request `_from`, and the current server state `names`. The `handle_call/3` callback returns a tule in the format `{:reply, reply, new_state}`. The first element of the tuple, `:reply`, indicates that server should send a reply back to the client. The second element, `reply`, is what will be sent to the client while the third, `new_state` is the new server state

For `cast/2` requests, we implement a `handle_cast/2` callback that receives the request and the current server state(`names`). The `handle_cast/2` callback returns a tuple in the format `{:noreply, new_state}`.

```elixir
defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

    setup do
        registry = start_supervised!(KV.Registry)
        %{registry: registry}
    end

   test "spawns buckets", %{registry: registry} do
     assert KV.Registry.lookup(registry, "shopping") == :error

     KV.Registry.create(registry, "shopping")
     assert {:ok, bucket} =
     KV.Registry.lookup(registry, "shopping")

     KV.Bucket.put(bucket, "milk", 1)
       assert KV.Bucket.get(bucket, "milk") == 1
   end
end

```

The `start_supervised!` fucntion will do the job of starting the `KV.Registry`
and the one we wrote for `KV.Bucket`. Instead of starting the registry by hand
by calling `KV.Registry.startlink/1`, we instead called the
`start_supervised/1` function, passing the `KV.Registry` module.

The `start_supervised!` funtion wil do the job of starting the `KV.Registry`
process by calling `start_link/1`. The advantage of using `start_supervised!`
is that  ExUnit will guarantee the state of one test is not going to interfere
with the next on in case they depend on shared resources.

```elixir
test "removes buckets on exit", %{registry: registry} do
  KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
      Agent.stop(bucket)
        assert KV.Registry.lookup(registry, "shopping") == :error
        end
```

The test above will fail on the last assertion as the bucket name remains in
the registry every after we stop the bucket process.

In order to fix this bug, we need the registry to monitor every bucket it
spawns. Once we set up a monitor, the registry will receive a notification
every time a bucket process exits, allowing us to clean the registry up.

```elixir
iex|1 ▶ {:ok, pid} = KV.Bucket.start_link([])
{:ok, #PID<0.156.0>}
iex|2 ▶ Process.monitor(pid)
#Reference<0.1308570577.471334915.235085>
iex|3 ▶ Agent.stop(pid)
:ok
iex|4 ▶ flush()
{:DOWN, #Reference<0.1308570577.471334915.235085>, :process, #PID<0.156.0>,
 :normal}
 :ok
 iex|5 ▶
```

Noe `Process.monitor(pid)` returns a unique reference that allows us to match
upcoming messages to that monitoring reference. After we stop the agent, we
can `flush/0` all messages and notice a `:DOWN` message arrived, with the
exact reference returned by monitor, notifying that the bucket process exited
with reason `:normal`



```elixir
iex|1 ▶ {:ok, pid} = KV.Bucket.start_link([])
{:ok, #PID<0.136.0>}
iex|2 ▶ Agent.stop(pid)
:ok
iex|3 ▶ flush()
:ok
}
```
```elixir
## Server callbacks

def init(:ok) do
  names = %{}
    refs = %{}
      {:ok, {names, refs}}
      end

      def handle_call({:lookup, name}, _from, {names, _} = state) do
        {:reply, Map.fetch(names, name), state}
        end

        def handle_cast({:create, name}, {names, refs}) do
          if Map.has_key?(names, name) do
              {:noreply, {names, refs}}
                else
                    {:ok, pid} = KV.Bucket.start_link([])
                        ref = Process.monitor(pid)
                            refs = Map.put(refs, ref, name)
                                names = Map.put(names, name, pid)
                                    {:noreply, {names, refs}}
                                      end
                                      end

                                      def handle_info({:DOWN, ref, :process,
                                      _pid, _reason}, {names, refs}) do
                                        {name, refs} = Map.pop(refs, ref)
                                          names = Map.delete(names, name)
                                            {:noreply, {names, refs}}
                                            end

                                            def handle_info(_msg, state) do
                                              {:noreply, state}
                                              end
                                              end
                                              
```

Observe that we were able to considerably change the server implementation
without changing any of the client API. That's one of the benefits of
explicitly segregating the server and the client.

Finally, different from the other callbacks, we have defined a "catch-all"
clause for `handle_info/2` that discards any unknown message. To understand
why, let's move on to the next section.

1. `handle_call/3` must be used for synchronous requests. This should be the
   default choice as waiting for the server reply is a useful backpressure
   mechanism.

2. `handle_cast/2` must be used for asynchronous requests, when you don't case
   about a reply. A cast does not even guarantee the server has received the
   message and, for this reason, should be used sparingly.

3. `handle_info/2` must be used for all other messages a server may receive
   are not sent via `GenServer.call/2` or `GenServer.cast/2`, including
   regular messages sent with`send/2`. The monitoring `:DOWN` messages are
   such an example of this.

Link are bi-directional. If you link two processes and one of them crashes,
the other side will crash too(unless it is trapping exits.). A monitor is
uni-directional: only the monitoring process will receive notifications about
he monitored one. In other words: use links when you want linked crashes, and
monitors when you just want to be informed of crashes, exits and so on.

Let's talk about ExUnit callbacks. As you may expect, all`KV.Bucket` tests
will request a bucket agent to be up and running. Exunit supports callbacks
that allow us to skip such repetitive tasks.


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



For `call/2` requests, we implement a `handle_call/3` callback that receives the `request`,  the process from which we received the request `_from`, and the current server state `names`. The `handle_call/3` callback returns a tule in the format `{:reply, reply, new_state}`. The first element of the tuple, `:reply`, indicates that server should send a reply back to the client. The second element, `reply`, is what will be sent to the client while the third, `new_state` is the new server state

For `cast/2` requests, we implement a `handle_cast/2` callback that receives the request and the current server state(`names`). The `handle_cast/2` callback returns a tuple in the format `{:noreply, new_state}`.

```elixir
defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

    setup do
        registry = start_supervised!(KV.Registry)
        %{registry: registry}
    end

   test "spawns buckets", %{registry: registry} do
     assert KV.Registry.lookup(registry, "shopping") == :error

     KV.Registry.create(registry, "shopping")
     assert {:ok, bucket} =
     KV.Registry.lookup(registry, "shopping")

     KV.Bucket.put(bucket, "milk", 1)
       assert KV.Bucket.get(bucket, "milk") == 1
   end
end

```

The `start_supervised!` fucntion will do the job of starting the `KV.Registry`
and the one we wrote for `KV.Bucket`. Instead of starting the registry by hand
by calling `KV.Registry.startlink/1`, we instead called the
`start_supervised/1` function, passing the `KV.Registry` module.

The `start_supervised!` funtion wil do the job of starting the `KV.Registry`
process by calling `start_link/1`. The advantage of using `start_supervised!`
is that  ExUnit will guarantee the state of one test is not going to interfere
with the next on in case they depend on shared resources.

```elixir
test "removes buckets on exit", %{registry: registry} do
  KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(registry, "shopping")
      Agent.stop(bucket)
        assert KV.Registry.lookup(registry, "shopping") == :error
        end
```

The test above will fail on the last assertion as the bucket name remains in
the registry every after we stop the bucket process.

In order to fix this bug, we need the registry to monitor every bucket it
spawns. Once we set up a monitor, the registry will receive a notification
every time a bucket process exits, allowing us to clean the registry up.

```elixir
iex|1 ▶ {:ok, pid} = KV.Bucket.start_link([])
{:ok, #PID<0.156.0>}
iex|2 ▶ Process.monitor(pid)
#Reference<0.1308570577.471334915.235085>
iex|3 ▶ Agent.stop(pid)
:ok
iex|4 ▶ flush()
{:DOWN, #Reference<0.1308570577.471334915.235085>, :process, #PID<0.156.0>,
 :normal}
 :ok
 iex|5 ▶
```

Noe `Process.monitor(pid)` returns a unique reference that allows us to match
upcoming messages to that monitoring reference. After we stop the agent, we
can `flush/0` all messages and notice a `:DOWN` message arrived, with the
exact reference returned by monitor, notifying that the bucket process exited
with reason `:normal`



```elixir
iex|1 ▶ {:ok, pid} = KV.Bucket.start_link([])
{:ok, #PID<0.136.0>}
iex|2 ▶ Agent.stop(pid)
:ok
iex|3 ▶ flush()
:ok
}
```
```elixir
## Server callbacks

def init(:ok) do
  names = %{}
    refs = %{}
      {:ok, {names, refs}}
      end

      def handle_call({:lookup, name}, _from, {names, _} = state) do
        {:reply, Map.fetch(names, name), state}
        end

        def handle_cast({:create, name}, {names, refs}) do
          if Map.has_key?(names, name) do
              {:noreply, {names, refs}}
                else
                    {:ok, pid} = KV.Bucket.start_link([])
                        ref = Process.monitor(pid)
                            refs = Map.put(refs, ref, name)
                                names = Map.put(names, name, pid)
                                    {:noreply, {names, refs}}
                                      end
                                      end

                                      def handle_info({:DOWN, ref, :process,
                                      _pid, _reason}, {names, refs}) do
                                        {name, refs} = Map.pop(refs, ref)
                                          names = Map.delete(names, name)
                                            {:noreply, {names, refs}}
                                            end

                                            def handle_info(_msg, state) do
                                              {:noreply, state}
                                              end
                                              end
                                              
```

Observe that we were able to considerably change the server implementation
without changing any of the client API. That's one of the benefits of
explicitly segregating the server and the client.

Finally, different from the other callbacks, we have defined a "catch-all"
clause for `handle_info/2` that discards any unknown message. To understand
why, let's move on to the next section.

1. `handle_call/3` must be used for synchronous requests. This should be the
   default choice as waiting for the server reply is a useful backpressure
   mechanism.

2. `handle_cast/2` must be used for asynchronous requests, when you don't case
   about a reply. A cast does not even guarantee the server has received the
   message and, for this reason, should be used sparingly.

3. `handle_info/2` must be used for all other messages a server may receive
   are not sent via `GenServer.call/2` or `GenServer.cast/2`, including
   regular messages sent with`send/2`. The monitoring `:DOWN` messages are
   such an example of this.

Link are bi-directional. If you link two processes and one of them crashes,
the other side will crash too(unless it is trapping exits.). A monitor is
uni-directional: only the monitoring process will receive notifications about
he monitored one. In other words: use links when you want linked crashes, and
monitors when you just want to be informed of crashes, exits and so on.

Let's talk about ExUnit callbacks. As you may expect, all`KV.Bucket` tests
will request a bucket agent to be up and running. Exunit supports callbacks
that allow us to skip such repetitive tasks.

```elixir
defmodule KV.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KV.Bucket.start_link([])
    %{bucket: bucket}
  end

  test "stores value by key" do
    assert KV.Bucket.get(bucket, "milk") == nil

    KV.Bucket.put(bucket, "milk", 3)
    assert KV.Bucket.get(bucket, "milk") == 3
  end
end
```

The `setup/1` callback runs before every test, in the same process as the test
itself.

Note that we need a mechanism to pass the `bucket` pid from the callback to
the test. We do so by using the `test context`. When we return `%{bucket:
bucket}` from the callback, ExUnit will merge this map into the test context.
Since the test context is a map itself, we can pattern match the bucket out of
it, providing access to the bucket inside the test.
