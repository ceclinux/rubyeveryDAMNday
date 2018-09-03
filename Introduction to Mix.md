**OTP(Open Telecom Platform)** is a set of libraries that ships with Erlang. Erlang developers use OTP to build robust, fault-tolerant applications.

**Mix** is a build tool that shops with elixir that provides tasks for creating, compiling, testing your application, managing its dependencies and much more;

**ExUnit** is a test-unit based framework that ships with Elixir

Out `mix.exs` defines two public functions, `project`, which returns project configuration like the project name and version, and `application`, which is used to generate an application file.

If you copy the test location in full, including the file and line number, and append it to mix test, Mix will load and run just that particular test:

```elixir
 mix test test/kv_test.exs:5
```

Customization per environment can be done by accessing the `Mix.env` function in your `mix.exs` file, which returns the current environment as an atom. That's what we have used in the `:start_permanent` option.

```elixir
def project do
  [...,
   start_permanent: Mix.env == :prod,
   ...]
end
```
