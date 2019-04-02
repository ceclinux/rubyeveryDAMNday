## Knapsack problem



$$d[i][j]$$ Is the maximum value that can be obtained by using a subset of the items $i … n - 1$ (last $n -i $ items) which weighs **at most** $j$ pounds. When computing $dp[i][j]$, we need to consider all the possible values of $d[i]$    (the decision at step $i$)



1. Add item $i$ to the knapsack. In this case, we need to choose a subset of the items $ i+1 … n-1$ that weight at most $ j - s_{i}$ . Assuming we do that optimally, we'll obtain $dp[i+1][j - s_{i}]$ value out of items $v_{i}+dp[i+1][j-s_{i}]$
2. Don't add item $I$ to the knapsack, so we'll re-use the optimal solution for the items   $ i+1 … n-1$ that weights at most $j$ pounds. That answer is in $dp[i+1][j-s_{i}]$ 

We want to maximum our profits, we we'll choose the best possible outcome.

$$ dp[i][j] = [dp[i+1][j], dp[i+1][j-s_{i}] + v_{i}] $$

To wrap up the loose ends, we notice that $dp[n][j] = 0, \forall 0 \le j \le S$ is a good base, as the interval $n…n-1$ contains no items, so there is nothing to add to the knapsack, which means the total sale value will be 0. The answer to our original problem can be found in $dp[0][S]$. 

The full pseudo-code is straight-forward to write, as it closely follows the topological sort and the Dynamamic Programming recurrence



```
for i in {n, n - 1 ... 0}
    for j in {0, 1 ... S}
        if i == n
            dp[i][j] = 0
        else
            choices = []
            APPEND(choices, dp[i + 1][j])
            if j >= S[i]
               APPEND(choices, dp[i + 1][j - S[i]] + v[i])
            dp[i][j] = MAX(choices)
return dp[0][S]
```

The Knapsack problem can be reduced to the single-source shortest paths problem on a DAG(directed acyclic graph)

The state associated with each vertex is similar to the DP formulation: vertex$(i,j)$ represents the state where we have considered items $0…i$ , and we have selected items whose total weight is at most $j$ pounds. We can consider that the DAG has $n+1$ layers(one layer for each value $i$$, $$0 \le i \le n$), and each layer consist of $S + 1$ vertices (the possible total weights are $0…S$)



As shown in figure 1, each vertex $(i, j)$ has the following outgoing edges:

- Item i is not taken: an edge from $(i, j )$ to $(j+1, j)$ with weight 0
- Item i is taken: an edge from $(i,j)$ to $(i + 1, j + s_{i})$ with weight $-v_{i}$ if $j + s_{i} \le S$ 



The source vertex is $(0, 0)$, representing an initial state where we haven't  considered any item yet, and our backpack is empty. The destination is the vertex with the shortest path out of all vertices $(n, j)$, for $0 \le j \le S$.



Alternately, we can create a virtual source vertex $$s$$, and connect it to all the vertices $(0, j)$ for $0 \le j \le S$, meaning that we can leave $j$ pounds of capacity unused(the knapsack will end up weighing $S-j$ pounds). In this case, the destination is the vertex $(n, S)$. The approach is less intuitive, but matches the dynamic programming solution better.



The dynamic programming solution to the Knapsack problem requires solving $O(nS)$ sub-problems. The solution of on sub-problem depends on two other sub-problems, so it can be computed in $O(1)$ time. Therefore, the solution's total running time is $O(nS)$.

The DAG shortest path solution creates a graph with $O(nS)$ vertices, where each vertex has an out-digress of $O(1)$ , so there are $O(nS)$ edges. The DAG shortest-path algorithm runs in $O(V+E)$, so the solution's total running time is also $O(nS)$.

The solution running time is not polynomial in the input size.









