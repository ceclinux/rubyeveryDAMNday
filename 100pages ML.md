## What is Maching Learning

Maching learning can also be defined as the process of solving a pratical problem by

1. gathering a dataset
2. algorithmically building a **statistical model** on that dataset

That statistical model is assumed to be used somehow to solve the practical problem.



## Supervised Learning

The supervised learning process starts with gathering the data. The data for supervised learning is a collection of pairs(input, output).  Input could be anything, for example, email messages, pictures, or sensor measurements.  Outputs are usually real numbers, or labels. In some cases, outputs are vectors, sequences(e.g. ["adj", "adj", "noun"] for the input "big beautiful car"), or have some other structure.



Lets say the problem that you want to solve using supervised learning is spam detection. You gather the data, for example, 10000 email messages, each with a label either "spam" or "not_spam". Now you have to convert each email message into a **feature vector**.



One common way to convert a text into a feature vector, called a bag of words, is to take a dictionary of English words(let's say it contains 20000 alphabetically sorted words) and stipulate that in our feature vector.

- The first feature is equal to 1 if the email message contains the word "a"; otherwise,   the feature is 0
- The second feature is equal to 1 if the email message contains the word "Aaron"; otherwise, this feature equals 0



You repeat the above procedure for every email message in our collection, which gives use 10000 feature vectors (each vector have the dimensionality of 20000) and a label ("spam"/"not spam").



Now you have a machine-readable input data, but the output labels are still in the form of human-readable text. Some learning algorithms require transforming labels into numbers. For example, some algorithms require numbers like 0(to represent the label "not spam" and 1(to represent the label "spam").  **Support Vector Machine** requires that the positive label(in our case it's "spam") has the numeric value of +1, and the negative label("not spam") has the value of -1.



At this point, you have a **dataset** and a **learning algorithm**, so you are ready to apply the learning algorithm to the dataset to get the model.



**SVM** sees every feature vector as a point in a high-dimensional space(in our case, space is 20000-dimensional).  The algorithm puts all feature vectors on an imaginary 20000 dimensional plot and draws an imaginary 19999-dimensional line  (a hyperplane) that separates examples with positive labels from examples with negative labels. In ML, the boundary separating the examples of different classes is called **decision boundary**.



The equation of the hyperplane is given by two **parameters**, a real-valued vector **w** of the same dimensionality as our input feature vector **x**, and a real number **b** like this:

$$wx - b = 0$$

Where the expression **wx** means $w^{(1)}x^{(1)} + w^{(2)}x^{(2)} + … +  w^{(D)}x^{(D)}$ , and **D** is the number of dimensions of the feature vector **x**



Now, the predicted label for some input feature vector **x** is given like this:

$$y = sign(wx - b)$$

Where sign is a mathematical operator that takes any value as input and returns +1 if the input is a positive number or -1 if the input is a negative number.



The goal of the learning algorithm —  SVM in this case — is to leverage the dataset and find the optimal value **w*** and b* for the parameter **w** and b. Once the learning algorithm identifies these optimal values, the **model** $$f(x)$$ is then defined as:



$$y = sign(w^{*}x - b^{*})$$



Therefore, to predict whether an email message is spam or not spam using an SVM model, you have to take a text of the message, convert it into a feature vector, then multiply this vector by **w***, subtract b* for parameters **w** and b* and take the sign of the result. This will give us the prediction (+1 means "spam", -1 means "not spam")

The constraints are natually:

$$ wx_{I} - b \ge 1\  if\  y_{I} = +1$$

$$ wx_{I} - b \le -1\  if\  y_{I} = -1$$

We would prefer that the hyperplane separates positive examples from negative one with with the largest **margin**. The margin is the distance between the closest examples of two classes, as defined by the decision boundary. A large margin contributes to a better **generalization**, that is how well the model will classify new examples in the future. To achieve that, we need to minimize the Euclidean norm of  **w** denoted by $||w||$ and given by $\sqrt{\sum^{D}_{j=1}(w^{(j)})^2}$

So, the optimization problem that we want the machine to solve looks like this:



Minimize $||w||$ subject to $$ y_{I}(wx_{I} - b ) \gt +1$$ for $$I = 1, … , N$$.

The solution of this optimization problem, given by $$w^{*}$$ and $b^{*}$, is called the **statistical model**, or, simply, the   **model**. The process of building the model is called **training**.



This is how Support Vector Machines work. This particular version of the algorithm builds the so-called linear model.  It is called linear because the decision boundary is a straight line(or a plane, or a hyperplane.) SVM can also incorporate **kernels** that can make the decision arbitrarily non-linear. In some cases, it could be impossible to perfectly separate the two groups of points because of noise in the data, errors of labeling, or outliers(examples very different from a "typical" example in the dataset). 









