using System;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;

namespace multithread
{
    public class Async
    {
        // 在async标识的方法体里面，如果没有`await`关键字，那么这种方法和调用普通的方法没什么区别。
        // 在async标识的方法体里面，在`await`关键字出现之前，还是主线程顺序调用的，直到`await`关键字的出现
        // 才会出现线程堵塞
        // await关键字可以理解为等待方法执行完毕，除了可以标记有async关键字的方法外，还能标记Task对象，标识等待线程执行完毕。所以await关键字并不是针对于`async`的方法，而是针对`async`方法所返回给我们的Task
        static void Main(string[] args)
        {
            Console.WriteLine("我是主线程，线程ID：{0}", Thread.CurrentThread.ManagedThreadId);
            TestAsync();
            Console.WriteLine("Here");
            Console.ReadLine();
        }
        static async Task TestAsync()
        {
            Console.WriteLine("调用GetReturnResult()之前，线程ID：{0}。当前时间：{1}", Thread.CurrentThread.ManagedThreadId, DateTime.Now.ToString("yyyy-MM-dd hh:MM:ss"));
            var name = GetReturnResult();
            Console.WriteLine("调用GetReturnResult()之后，线程ID：{0}。当前时间：{1}", Thread.CurrentThread.ManagedThreadId, DateTime.Now.ToString("yyyy-MM-dd hh:MM:ss"));
            Console.WriteLine("得到GetReturnResult()方法的结果：{0}。当前时间：{1}", await name, DateTime.Now.ToString("yyyy-MM-dd hh:MM:ss"));
        }

        static async Task<string> GetReturnResult()
        {
            Console.WriteLine("执行Task.Run之前, 线程ID：{0}", Thread.CurrentThread.ManagedThreadId);
            return await Task.Run(() =>
            {
                Thread.Sleep(3000);
                Console.WriteLine("GetReturnResult()方法里面线程ID: {0}", Thread.CurrentThread.ManagedThreadId);
                return "我是返回值";
            });
        }
    }
}
