// C#語言和公共語言運行時(CLR)的2.0版本中添加了范型。范型將類型參數的概念引入了.NET Framework
// ，這樣就可以設計具有以下特征的類和方法：在客戶端代碼申明並出示haul這些類和方法之前，這些類和方法會延遲指定
// 一個或多個類型。例如，通過使用泛型類型參數T，可以編寫其他客戶端代碼能夠使用的單個類，而不會產生運行時轉換或裝箱操作的成本和風險
#define DEBUG
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
namespace HelloWorld {
    // Declare the generic class.
    public class GenericList<T> {
        public void Add (T input) { }
    }

    class TestGenericList {
        [Conditional ("DEBUG")]
        public static void Message (string msg) {
            Console.WriteLine (msg);
        }

        static void function1 () {
            Message ("In Function 1.");
            function2 ();
        }
        static void function2 () {
            Message ("In Function 2.");
        }

        private class ExampleClass { }
        static void Main () {
            Message ("In Main function.");
            function1 ();
            // Declare a list of type int.
            GenericList<int> list1 = new GenericList<int> ();
            list1.Add (1);

            // Declare a list of type string.
            GenericList<string> list2 = new GenericList<string> ();
            list2.Add ("");

            // Declare a list of type ExampleClass.
            GenericList<ExampleClass> list3 = new GenericList<ExampleClass> ();
            list3.Add (new ExampleClass ());

            // CRL和C#語言早期版本中存在一個局限，其中通過將類型與通用類型Object相互強制完成泛化，泛型提供了此局限的解決方案。
            //通過創建方形類，可在編譯時創建類型安全的集合。
            //通過編寫一個使用.NET類庫中的ArrayList集合類的小程序，可體現出使用非泛型集合類的局限。
            //ArrayList類的實例可以存儲任何引用或值類型
            System.Collections.ArrayList list11 = new System.Collections.ArrayList ();
            list11.Add (3);
            list11.Add (105);

            System.Collections.ArrayList list22 = new System.Collections.ArrayList ();
            list22.Add ("It is raining in Redmond.");
            list22.Add ("It is snowing in the mountains.");

            // 但這種便利有一定代價。添加到ArrayList的任何引用或值均隱式向上轉換為Object.
            // 如果項為值類型，將他們添加到列表時必須將其裝箱，檢索它們時必須取消裝箱。轉換與裝箱/取消裝箱
            // 這兩種操作到會降低性能；在必須循環訪問大型集合的方案中，裝箱與取消裝箱的影響非常大

            //另一局限是缺少編譯時類型檢查；由於ArrayList將所有內容都轉換為`Object`，因此在編譯時無法阻止客戶端代碼執行如下操作

            // System.Collections.ArrayList list = new System.Collections.ArrayList();
            // // Add an integer to the list.
            // list.Add(3);
            // // Add a string to the list. This will compile, but may cause an error later.
            // list.Add("It is raining in Redmond.");

            // int t = 0;
            // // This causes an InvalidCastException to be returned.
            // foreach (int x in list)
            // {
            //     t += x;
            // }
            // Boxing is the process of converting a value type to the type `object` or to any interface type implemented 
            // by this value type. When CLR boxes a value type, it wraps the value inside a System. Object and stores
            // it on the managed heap. Unboxing extracts the value type from the object. Boxing is implicit; unboxing is explicit.
            // The concept of boxing and unboxing underlies the C# unified view of the type system in
            // which a vaule of any type can be treated as an object.

            int i = 123;
            // The following line boxes i.
            object o = i;

            o = 123;
            i = (int) o; //unboxing

            //String.concat example
            //it takes three object values here. Both 42 and true must be boxed
            Console.WriteLine (String.Concat ("Answer", 42, true));

            // A variable of value type contains a value of the type. For example, a varibale
            // of the `int` type might contain the value `42`. This differes from a variable of a reference type, 
            // which contains a reference to an instance of the type, also known as an object.                

            // Boxing is used to store value types in the garbage-collected heap. Boxing is 
            // an implicit conversion of a value type `object` or to any interface type implemented by
            // this value type. Boxing a value type allocates an object instance on the heap and copies the value into
            // the new object

            // see here
            //https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/types/media/boxing-and-unboxing/unboxing-conversion-operation.gif

            //類型參數的約束
            //約束告知編譯器類型參數必須具備的功能。在沒有任何約束的情況下，類型參數可以是任何類型。
            // 編譯器智能假定System.Object的成員，它是任何.NET類型的最終基類。如果客戶端代碼嘗試使用約束所不允許的類型來
            //實例化類，則會產生編譯時錯誤。通過使用`where`上下文關鍵字指定約束。

            //where T : class 	类型参数必须是引用类型。 此约束还应用于任何类、接口、委托或数组类型。

            TestStringEquality ();
            Customer cust1 = new Customer (4987.63, "Northwind", 90108);
            cust1.TotalPurchases += 499.99;
            Console.WriteLine (cust1.TotalPurchases);

            // Creating a static class is therefore basically the same as
            // creating a class that contains only static members and a private
            // constructor. A private constructor prevents the class from being 
            // instantiated. The advantange of using a static class is taht the
            // compiler can check to make sure that no instance members are
            // accidentally added. 

            // The following list provides the main features of a static class:
            // - contains only static members.
            // - cannot be instanitated
            // - is sealed
            // - cannot contain Instance Constructors

            F f = new F ();
            f.DoWork (2);
            D d = new Q ();
            d.TestVirtual ();

            // The `out` keyword causes argument to be passed by reference. It makes the formal parameter an alias for the argument, which must be a variable. In other words, any operation on the parameter is made on the argument.
            int initializeInMethod;
            OutArgExample (out initializeInMethod);
            Console.WriteLine (initializeInMethod);
            // When used in a method's parameter list, the ref keyword indicates that an argument is passed by reference, not by value. 

            // An argument that is passed to a `ref` or `in` parameter must be initialized before it is passed. This differs from `out` parameters, whose arguments do not have to be explicitly initialized before they are passed.
            int number = 1;
            Method (ref number);
            Console.WriteLine (number);

            //it's like the `ref` or `out` keywords, except that `in` arguments may be modified, `out` arguments must be modified by the called method, and those modifications are observable int he calling context.

            int readonlyArgument = 44;
            InArgExample (readonlyArgument);
            Console.WriteLine (readonlyArgument);

            // Attributes provide a powerful method of associating metadata, or declarative information, with(assemblies, types, methods, properties, and so forth).  After an attribute is associated with a program entity, the attribute can be queried at run time by using a technique called reflection.

            // In this example ,the `SerializableAttribute` attribute is used to apply a specific characteristic to a class

        }

        private static void InArgExample (in int number) {
            // number = 19;
        }

        static void Method (ref int refArgument) {
            refArgument = refArgument + 44;
        }

        static void OutArgExample (out int number) {
            number = 44;
        }

        public class D {

            // The `virual` keyword is used to modify a method, property,
            // indexr, or event declaration and allow for it to be overriden
            // in a derived class.
            public virtual void DoWork (int i) {

            }

            public virtual void TestVirtual () {
                Console.WriteLine ("in d");
            }
        }
        public class Q : D {
            public override void TestVirtual () {
                Console.WriteLine ("in q");
            }
        }

        [Serializable]
        public class SampleClass {
            // Object of this type can be serialized
        }
        public abstract class E : D {
            public abstract override void DoWork (int s);

        }
        public class F : E {
            public override void DoWork (int i) {
                Console.WriteLine ("here we go");
            }
        }

        public static void OpEqualsTest<T> (T s, T t) where T : class {
            //在應用`where T: class`約束時，請避免對類型參數使用`==`和`!=`運算符，這些運算符僅測試引用標誌而不測試
            //相等性。即使再用作參數的類型中重載這些運算符也會發生此行為。下面的代碼說明了這一點；即使String類重載了`==`
            //運算符，輸出也為`false`
            System.Console.WriteLine (s == t);
            string first = "aaa";
            string second = first.ToString ();
            System.Console.WriteLine (second == first);
        }
        private static void TestStringEquality () {
            string s1 = "target";
            System.Text.StringBuilder sb = new System.Text.StringBuilder ("target");
            string s2 = sb.ToString ();
            OpEqualsTest<string> (s1, s2);
        }
    }

    //可以對統一類型參數引用多個約束，並且約束自身可以是泛型類型， 如下所示
    // class EmployeeList<T> where T : Employee, IEmployee, System.IComparable<T>, new()
    // {
    // }
    class Customer {
        public double TotalPurchases { get; set; }
        public string Name { get; set; }
        public int CustomerID { get; set; }

        public Customer (double purchases, string name, int ID) {
            TotalPurchases = purchases;
            Name = name;
            CustomerID = ID;
        }

        // More than one attribute can be placed on a declaration as the following example shows:

        void MethodA ([In][Out] ref double x) { }
        void MethodB ([Out][In] ref double x) { }
        void MethodC ([In, Out] ref double x) { }

        // Some attributes can be specified more than once for a given entity. An example of such a mutiuse attrbute is `ConditionalAttribute`
        // [Conditional ("DEBUG"), Conditional ("Test1")]
        void TraceMethod () {

        }

        // Use the async modifier to specify that a method, lambda expression, or
        // anonymous method is asynchronous. If you use this modifier on a method or expression, it is referred to
        // as an async method. The following example defined an async method named `ExampleMethodAsync`

        // public async Task<int> ExampleMethodAsync(){

        // }

        // The Task asynchronous programming model(TAP) provides an abstraction over asynchronous code. You write code as a sequence of statements, just like always. You can read the code as though each statement completes before the next begins. The complier performs a number of transformations because some of those statements may start work and return a `Task` that represent the ongoing work.

        // That's the goal of this syntax: enable code reads like a sequence of statements, but executes in a much complicated order based on external resource allocation and when tasks complete.

        //These concerns are important for the programs you write today. When you write client programs, you want the UI to be responsive to use input. Your application shouldn't make a phone appear frozen while it's downloading data from the web. When you write server programs, you don't want threads blocked. Those threads could be serving other requests.

    }

// ```csharp
// static async Task Main(string[] args)
// {
//     Coffee cup = PourCoffee();
//     Console.WriteLine("coffee is ready");
//     Egg eggs = await FryEggs(2);
//     Console.WriteLine("eggs are ready");
//     Bacon bacon = await FryBacon(3);
//     Console.WriteLine("bacon is ready");
//     Toast toast = await ToastBread(2);
//     ApplyButter(toast);
//     ApplyJam(toast);
//     Console.WriteLine("toast is ready");
//     Juice oj = PourOJ();
//     Console.WriteLine("oj is ready");

//     Console.WriteLine("Breakfast is ready!");
// }
// ```

// This code doesn't block while the eggs or the bacon are cooking. This code won't start any other tasks though. You's still put the toast in the toaster and stare at it until it pops.

// Now, the thread working on the breakfast isn't blocked while awaiting any started task taht hasn't yet finished. For some applications, this change is all that's needed. A GUI application still responds to the user with just this change.

// ```csharp
// Copy
// Coffee cup = PourCoffee();
// Console.WriteLine("coffee is ready");
// Task<Egg> eggTask = FryEggs(2);
// Task<Bacon> baconTask = FryBacon(3);
// Task<Toast> toastTask = ToastBread(2);
// Toast toast = await toastTask;
// ApplyButter(toast);
// ApplyJam(toast);
// Console.WriteLine("toast is ready");
// Juice oj = PourOJ();
// Console.WriteLine("oj is ready");

// Egg eggs = await eggTask;
// Console.WriteLine("eggs are ready");
// Bacon bacon = await baconTask;
// Console.WriteLine("bacon is ready");

// Console.WriteLine("Breakfast is ready!");
// ```

// The preciding code works better. You start all the asynchronous tasks at once. You await each task only when you need the results. The preceding code may be similar to code in a web application that makes request of differeent microservices, then combines the result into a single page. You'll make all the requests immediately, then await all those tasks and compose the web page.
}
