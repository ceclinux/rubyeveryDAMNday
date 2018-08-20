A single-page application (SPA) is a web application or web site that interacts with the user by dynamically rewriting the current page rather than loading entire new pages from a server. This approach avoids interruption of the user experience between successive pages, making the application behave more like a desktop application. In an SPA, either all necessary code – HTML, JavaScript, and CSS – is retrieved with a single page load,[1] or the appropriate resources are dynamically loaded and added to the page as necessary, usually in response to user actions. The page does not reload at any point in the process, nor does control transfer to another page, although the location hash or the HTML5 History API can be used to provide the perception and navigability of separate logical pages in the application.[2] Interaction with the single page application often involves dynamic communication with the web server behind the scenes. 

什么是 SPA？Single Page Application 其核心特点就是通过浏览器提供的 History API（或 fallback 到 hash）来实现非重载且能够持久状态的路由系统，从而达到只需要加载一个静态 HTML 页面就可以作出不限数量的“页面”（确切地说是“视图”）的应用形态。只要能够满足这种形态的，无论其是否是分离架构，也无论其使用了什么框架（或者完全不用框架），更无论其使用的视图渲染技术……它们都是 SPA。

再说虚拟 DOM，这已经快被说烂了还要被拿来继续嚼。首先，用不用虚拟 DOM 跟是不是 SPA 没有丝毫关系！其次，虚拟 DOM 的诞生不是为了比传统操作 DOM 快（尽管很多场景下它的确比传统方式快，不过这个“快”的幅度是要取决于实现的人的），而是为了给越来越复杂的客户端状态管理与视图渲染的同步问题找到一个新的解决方案。如果你认为像 QQ 邮箱的状态管理就能称之为“复杂”，那你得是多没有见识？不要因为那些初心者总是拿框架搞点博客和 Todo 就觉得这些框架就是用来干这些事情的。

    虚拟dom是只要一个元素变化，整个区域都重新渲染 

请不要总是活在几年前，技术总是在进步的，如今的主流渲染机制都能做到精确的节点（DOM NODE）更新了。

作者：磨牙行者
链接：https://www.zhihu.com/question/20874229/answer/24708736
来源：知乎
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

直白地说，就是没用AJAX的网页，你点一个按钮就要刷新一下页面，尽管新页面上只有一行字和当前页面不一样，但你还是要无聊地等待页面刷新。用了AJAX之后，你点击，然后页面上的一行字就变化了，页面本身不用刷。AJAX只是一种技术，不是某种具体的东西。不同的浏览器有自己实现AJAX的组件。=====================================突然想让这个答案更加完美，所以补充一下下面的内容：ajax的全称是AsynchronousJavascript+XML。异步传输+js+xml。所谓异步，在这里简单地解释就是：向服务器发送请求的时候，我们不必等待结果，而是可以同时做其他的事情，等到有了结果我们可以再来处理这个事。（当然，在其他语境下这个解释可能就不对了）这个很重要，如果不是这样的话，我们点完按钮，页面就会死在那里，其他的数据请求不会往下走了。这样比等待刷新似乎更加讨厌。（虽然提供异步通讯功能的组件默认情况下都是异步的，但它们也提供了同步选项，如果你好奇把那个选项改为false的话，你的页面就会死在那里）xml只是一种数据格式，在这件事里并不重要，我们在更新一行字的时候理论上说不需要这个格式，但如果我们更新很多内容，那么格式化的数据可以使我们有条理地去实现更新。现在大部分人其实是用JSON这种格式来代替XML的，因为前者更加简洁，据说目前的解析速度也更快。多快好省，能省则省啊。总结：只要是JS调用异步通讯组件并使用格式化的数据来更新web页面上的内容或操作过程，那么我们用的方法就可算是AJAX。
