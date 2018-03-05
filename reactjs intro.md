## React

```
const element = <h1>Hello, world!</h1>;
```
This funny tag syntax is neither a string nor HTML.

It is called JSX, and it is a syntax extension to JavaScript. We recommend using it with React to describe what the UI should look like. JSX may remind you of a template language, but it comes with the full power of JavaScript.

JSX produces React “elements”. We will explore rendering them to the DOM in the next section. Below, you can find the basics of JSX necessary to get you started.

**Babel compiles JSX down to React.createElement() calls.**

Elements are what components are “made of”

React elements are immutable. Once you create an element, you can’t change its children or attributes. An element is like a single frame in a movie: it represents the UI at a certain point in time.

With our knowledge so far, the only way to update the UI is to create a new element, and pass it to ReactDOM.render().

Conceptually, components are like JavaScript functions. They accept arbitrary inputs (called “props”) and return React elements describing what should appear on the screen.

All React components must act like pure functions with respect to their props.

We want to set up a timer whenever the Clock is rendered to the DOM for the first time. This is called “mounting” in React.

We also want to clear that timer whenever the DOM produced by the Clock is removed. This is called “unmounting” in React.

React may batch multiple setState() calls into a single update for performance.

Because this.props and this.state may be updated asynchronously, you should not rely on their values for calculating the next state.

For example, this code may fail to update the counter:
```
// Wrong
this.setState({
  counter: this.state.counter + this.props.increment,
});
```
To fix it, use a second form of setState() that accepts a function rather than an object. That function will receive the previous state as the first argument, and the props at the time the update is applied as the second argument:
```
// Correct
this.setState((prevState, props) => ({
  counter: prevState.counter + props.increment
}));
```

Returning `null` from a component’s render method does not affect the firing of the component’s lifecycle method

每当根元素有不同类型，React将卸载旧树并重新构建新树。从<a>到<img>或从<Article>到<Comment>，或从<Button> 到 <div>，任何的调整都会导致全部重建。

当树被卸载，旧的DOM节点将被销毁。组件实例会调用componentWillUnmount()。当构建一棵新树，新的DOM节点被插入到DOM中。组件实例将依次调用componentWillMount()和componentDidMount()。任何与旧树有关的状态都将丢弃。

这个根节点下所有的组件都将会被卸载，同时他们的状态将被销毁。 例如，以下节点对比之后：
```jsx
<div>
  <Counter />
</div>
```

```jsx
<span>
  <Counter />
</span>
```
这将会销毁旧的Counter并重装新的Counter。
