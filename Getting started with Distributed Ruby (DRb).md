Let’s start off with a very simple dRuby program. We will write server.rb which exposes a very simple object over the network. The object responds to a #greet method and returns the string “Hello, world!”.

```ruby
# server.rb
require 'drb/drb'

class MyApp
  def greet
    'Hello, world!'
  end
end

object = MyApp.new

DRb.start_service('druby://localhost:9999', object)
DRb.thread.join
```

Let’s focus on the last two lines of the code above. DRb.start_service starts a local dRuby server on port 9999. The second argument to the method is the object that we want to be able to call from other processes.

The final line DRb.thread.join is so that the program doesn’t exit immediately. This keeps the program running until the DRb thread stops. Start this program in one tab in the terminal.

Next, we will write another program that talks to the server. Save the following code and run it.

```ruby
# client.rb
require 'drb/drb'
DRb.start_service
remote_object = DRbObject.new_with_uri('druby://localhost:9999')

remote_object.greet   #=> 'Hello, world!'
```

Here, we create an instance of DRbObject which proxies all method calls to the object we shared in server.rb. Now we can call greet method on remote_object and the method call is sent across the network to the process running server.rb.

Under the hood, DRbObject uses method_missing to delegate all method calls over the network.
