# Rails create a controller instance for every request

The overhead of instantiating a new controller instance is insignificant, and it means there is no accidentally shared state between two completely unrelated requests. Any "savings" in processor time would be more than offset by the potential to produce devastating bugs.

Remember that controllers are for storing request-specific state. Reusing controllers would require you to reset every @variable you'd ever set, at the start of every action. Otherwise, something like @is_admin = true could wind-up being set and never cleared. The less contrived bugs you'd actually be introducing would be much more subtle and draining on developer time.

You're seeing optimizations where there are none. Something must maintain state and reset it between requests, or you have this nightmare of accidentally shared state. If you persist controller instances between requests, you're simply pushing the job of maintaining/resetting state down to some lower level, where the answer will likely still be to instantiate a fresh instance of some state-managing class for each request. Computers are very good at allocating and freeing resources, so never worry about that until you actually know it's a bottleneck. In this case, instantiating a new controller for each request is easily the correct choice.

In the case of Rails, being able to use @variable = value is a major win from a code-clarity and usability stand-point, and this more or less necessitates discarding each instance of a controller when the request completes.
