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


## Polynomial time vs pseudo-polynomial time

### Dynamic Programming for Knapsack



The input for an instance of the knapsack problem can be represented in reasonably compact form as follows:

- The number of items $n$, which can be represented using $O(log n)$ bits
- $n$ item weights. We notice that the item weight should be between $0...S$ because we can ignore any items whose weight exceeds the knapsack capacity. This means that each weight can be represented using $O(log S)$ bits, and all the weights will take up $O(n log S)$ bits.
- $n$ item values. Let $V$ be the maximum value, so we can represent each value using $O(logV)$ bits, and all the values will take up $O(n log V)$ bits.

The total input size is $O(log(n) + n(logS + logV)) = O(n(log S + log V))$. Let $b = log S, v = log V$ , so the input size is $O(n(v+b))$ . The running time for the DP solution is $O(nS) = O(n*2^{b})$ . 



We can double the input size by doubling the number of items, so $n' = 2n$. The running time is $O(nS)$, so we can expect that the running time will double. However, if we double the input size by doubling b, the running time will increase quadratically.



### Dijkstra for the Shortest-Paths

Given a graph $G$ with $V$ vertices and $E$ edges, Dijkstra's algorithm implemented with binary heaps can compute single-source shortest-paths in $O(ElogV)$.

The input graph for an instance of the single-source problem can be represented in a reasonably compact form as follows

- The number of vertices $V$, which can be represented using $O(logV)$ bits.
- The number of edges $E$, which can be represented using $O(logE)$ bits.
- $E$ edges, represented as a list of tuple $(s_{i}, t_{i}, w_{i})$(directed edge $i$ goes from vertex $S_{i}$ to vertex $t_{i}$, and has weight $w_{i}$). We notice that $s_{i}$ and $t_{i}$ can be represented using $O(logV)$ bits, since they must address $V$ vertices. Let the maximum weight be $W$, so that each $w_{i}$ takes up $O(log W)$ bits. It follows that all edges take up $O(E(logV + logW)) $ bits

The total input size is $O(log(V) + log(E) +E(2logV + logW)) = O(E(logV + logW))$. Let $b = logW$, so the input size is $O(E(logV+b))$

Note that the graph representation above, though intuitive, is not suitable for running Dijkstra. However, the edge list representation can be used to build an adjacency list representation in $O(V+E)$, so the representation choice does not impact the total running time of Dijkstra's algorithm, which is $O(ElogV)$

Note that the graph representation above, is not suitable for running Dijkstra. However, the edge list representation can be used to build an adjacency list representation in $O(V+E)$, so the representation choice does not impact the  total running time of the Dijkstra's algorithm, which is $O(ElogV)$



### adjacency list representation

Compare this result to the Knapsack solution's running time. In this case, the running time is polynomial(actually linear) in the number of bits required to represent the input.  If we double the input size by doubling $b$, the width of the numbers used to represent edge weights, the running time doesn't change. 

![](https://cdncontribute.geeksforgeeks.org/wp-content/uploads/undirectedgraph.png)



This can be represented by 

![](https://cdncontribute.geeksforgeeks.org/wp-content/uploads/listadjacency.png)

## Subset Sum

In a variant of the Knapsack problem, all the items in the vault are gold bars. The value of a gold bar is directly proportional to its weight. Therefore,  ignorer to make the most amount of money, you must fill your knapsack up to its full capacity of $$S$$ pounds. Can you find a subset of the gold bars whose weights add up to exactly $$S$$?



Dynamic Programming is generally used for optimization problems that involve maximizing an objective. The Subset Sum problem asks us for a boolean $(TRUE/FALSE)$  answer to the question "Is there a combination of bars whose weight add up to $S$ or not?". Fortunately, we can use the Boolean logic formulation below to transform this into a maximization problem.



We'll use 1 as True and 0 as false. This is motivated by the fact that we want to arrive to arrive to an answer of TRUE whenever that is possible, and only arrive to an answer of $FALSE$ otherwise.

The subset sum problem has identical decisions and state to the Knapsack solution.

$dp[i][j]$ is TRUE(1) if there is a subset of gold bars $i…n-1$ (last $n - I$ bars) which weights **exactly** j pounds. When computing $dp[i][j]$, we need to consider all the possible values of $d_{i}$(the decision at step $i$ ), which is whether or not to include bar $i$



1. Add bar $i$  to the knapsack. In this case, we need to choose a subset of the bars $i+ 1…n-1$ that weights exactly $j - s_{i}$ pounds.  $dp[i + 1][j - s_{i}]$ Indicates whether such a subset exists.
2. Don't add item $i$ to the knapsack. In this case, the solution rests on a subset of the bars $ i + 1 … n - 1$ that weights exactly $j$ pounds. The answer of whether such a subset exists is in $dp[i + 1][j]$.



Either of the above avenues yields a solution, so $dp[i][j]$ is $TRUE$ if at least one of the decision possibilities results in a solution. Recall that $OR$ is implemented using $max$ in our boolean in our Boolean logic.

$$ dp[i][j] = max(dp[i + 1][j], dp[i+1][j-s_{i}]) if j \ge S_{i}$$

The initial conditions for this problem are $dp[n][0] = 1(TRUE)$ and $dp[n][j] = 0(FALSE) \forall 1 \le j \le S$.  

```
for i in {n, n - 1 ... 0}
    for j in {0, 1 ... S}
        if i == 0
            if j == 0
                dp[i][j] = 1
            else
                dp[i][j] = 0
        else
            choices = []
            APPEND(choices, dp[i + 1][j])
            if j >= Si
                APPEND(choices, dp[i + 1][j - Si])
            dp[i][j] = MAX(choices)
 return dp[0][S]
     
```

### DAG Shortest-Path solution

The DAG representation of the problem is also very similar to the knapsack representation, and slightly simpler.



A vertex$(i,j)$ represents the possibility of finding a subset of the first $i$ bars that weights exactly $j$ pounds. So, if there is a path to vertex(i,j)(the shortest path lengths less than $inf$), then the answer the sub-problem(i,j) is $TRUE$.

The starting vertex is $(0, 0)$ because we can only achieve a weight of 0 pounds using 0 items. The destination vertex is $(n, S)$, because that maps to the goal of finding a subset of all items that weights exactly $S$ pounds.

We only care about the existence of a path, so we can use BFS or DFS on the graph. Alternatively, we can assign the same weight of 1 to all edges, and run the DAG shortest-paths algorithm. Both approaches yield the same running time, but the latter approach maps better the the dynamic programming solution.

## K-Sum

The problem becomes: given $n$ gold bars of weights $s_{0}...s_{n-1}$, can you select exactly K bars whose weights add up to exactly $S$?

### Decision and State

A solution to a problem instance looks the same as for the Knapsack problem, so we still have $n$ boolean decision $d_{0}...d_{n-1}$.



However, the knapsack structure changed. In the original problem, the knapsack capacity placed a limit on the total weight of the items, so we needed to keep track of total weight of the items that we added. That was our state. In the k-sum problem, the knapsack also has slots. When deciding whether to add a gold bar to the knapsack or not, we need to know if there are any slots available, which is equivalent to knowing how many slots we have used up. So the problem state needs to track both the total weight of the bars in the knapsack, and how many slots they take up.



### Dynamic Programming Solution

$dp[i][j][k]$ is $TRUE(1)$ if there is a $k$-element subset of the gold bars $i...n-1$ that weighs exactly $j$ pounds. $dp[i][j][k]$ is computed considering all the possibilities values of $d_{i}$ (the decision at step $i$, which is whether or not to include bar $i$).

1. add bar $i$ to the knapsack. In this case, we need to choose a $k - 1$-bar subset of the bars $i+1...n-1$ that weight exactly $j - s_{i}$ pounds. $dp[i+1][j-s_{i}][k-1]$ indicates whether such a subset exists.
2. Don't add item $i$ to the knapsack. In this case, the solution rests on a $k$-bar $i+1...n-1$ that weight exactly $j$ pounds. The answer of whether such a subset exists is in $dp[i+1][j][k]$

Either of the above avenues yields a solution, so $dp[i][j][k]$ is $TRUE$ if at least one of the decision possibilities results in a solution. The recurrence is below

$dp[i][j][k] = max(dp[i+1][j][k], dp[i+1][j-s_{i}][k-1])$

The initial condition for this problem are $dp[n][0][0] = 1(TRUE)$ and $dp[n][j][k] = 0(FALSE) \forall 1 \le j \le S, 0 \le k \le K$. The interval $n ... n - 1$ contains no items, the corresponding knapsack is empty, which means the only achievable weight is 0.

The answer the original problem is in $dp[0][S][K]$.

```
KSUM(n, K, S, s)
for i in {n, n - 1 ... 0}
    for j in {0, 1 ... S}
        for k in {0, 1 ... K}
            if j == 0 and k == 0
                dp[i][j][k] = 1
            else
                dp[i][j][k] = 0
        else
            choices = []
            APPEND(choices, dp[i + 1][j][k])
            if j >= Si and k > 0
                APPEND(choices, dp[i+1][j - Si][k-1])
            dp[i][j][k] = MAX(choices)
 return dp[0][S][K]
```

Let's attempt to use edge weights to count the number of bars. Edges from $(i, j)$ to $(i + 1, j)$ will have a cost of $0$, because it means that bar $i$ is not added to the knapsack. Edges from $(i, j)$ to $(i +1, j +s_{i})$ have a cost of 1, as they imply that one bar is added to the knapsack, and therefore one more slot is occupied.

Given the formulation above, we want to find a path from $(0, 0)$ to $(n, S)$ whose cost is exactly $K$. We can draw upon our intuition built from previous graph transformation problems, and realize that we can represent $K$-cost requirement by making $K$ copies of the graph, where each copy $k$ is a layer that captures the paths whose cost is exactly $k$.

Therefore, in the new graph, a vertex $(i, j, k)$ indicates whether there is a $k-cost$ path to vertex $(i, j)$ in the Subset Sum program graph. Each 0-cost edge from $(i, j)$ to $(i+1, j)$ in the old graph maps to K edges from $(i, j, k)$ in the new graph. Each $1-cost$ edge from $(i, j)$ to $(i, j + S_{i})$ maps to $K$ edges $(i, j, k)$ to $(i, j + S_{i}, k+1)$ . In the new graph,  we want to find a path from vertex $(0, 0, 0)$ to vertex $(n, s, K)$. All edges have the same weight.

The Dynamic programming solution solves $O(K.ns)$ sub-problems, and each sub-problem takes $O(1)$ time to solve. The solution's total running time is $O(KnS)$

The DAG has $K + 1$ layers of $O(nS)$ vertices, and K copies of the $O(nS)$ edges in the Knapsack graph. Therefore, the running time is $O(V+E) = O(KnS)$














