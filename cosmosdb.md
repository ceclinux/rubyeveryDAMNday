How to count the number of vertices in the graph:

count the number of vertices in the graph
```
g.V().count()
```

You can perform filters using Gremlin's `has` and `hasLabel` steps, and combine them using `and`, `or`, and `not` to build more complex filters. Azure Cosmos DB provides schema-agnostic indexing of all properties within your vertices and degrees for fast queries.

```
g.V().hasLabel('person').has('age', gt(40))
```

You can project certain properties in the query results using the `values`step

```
g.V().hasLabel('person').values('firstName')
```

Graphs are fast and efficient for traversal operations when you need to navigate to related edges and vertices. Let's find all friends of ben. We do this by using Gremlin's `outE` step to find all the out-edges from Thomas, then traversing to the in-vertices from those edges using Gremlin's `inV` step:

```
g.V('ben').outE('knows').inV().hasLabel('person')
```

The next query performs two hops to find all of Ben "friends of friends", by calling `outE` and `inV` two times.

```
g.V('ben').outE('knows').inV().hasLabel('person').outE('knows').inV().hasLabel('person')
```
