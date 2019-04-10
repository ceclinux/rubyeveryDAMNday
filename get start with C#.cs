// C#語言和公共語言運行時(CLR)的2.0版本中添加了范型。范型將類型參數的概念引入了.NET Framework
// ，這樣就可以設計具有以下特征的類和方法：在客戶端代碼申明並出示haul這些類和方法之前，這些類和方法會延遲指定
// 一個或多個類型。例如，通過使用泛型類型參數T，可以編寫其他客戶端代碼能夠使用的單個類，而不會產生運行時轉換或裝箱操作的成本和風險
using System;

namespace HelloWorld
{
    // Declare the generic class.
    public class GenericList<T>
    {
        public void Add(T input) { }
    }
    class TestGenericList
    {
        private class ExampleClass { }
        static void Main()
        {
            // Declare a list of type int.
            GenericList<int> list1 = new GenericList<int>();
            list1.Add(1);

            // Declare a list of type string.
            GenericList<string> list2 = new GenericList<string>();
            list2.Add("");

            // Declare a list of type ExampleClass.
            GenericList<ExampleClass> list3 = new GenericList<ExampleClass>();
            list3.Add(new ExampleClass());

            // CRL和C#語言早期版本中存在一個局限，其中通過將類型與通用類型Object相互強制完成泛化，泛型提供了此局限的解決方案。
            //通過創建方形類，可在編譯時創建類型安全的集合。
            //通過編寫一個使用.NET類庫中的ArrayList集合類的小程序，可體現出使用非泛型集合類的局限。
            //ArrayList類的實例可以存儲任何引用或值類型
            System.Collections.ArrayList list11 = new System.Collections.ArrayList();
            list11.Add(3);
            list11.Add(105);

            System.Collections.ArrayList list22 = new System.Collections.ArrayList();
            list22.Add("It is raining in Redmond.");
            list22.Add("It is snowing in the mountains.");

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
            i = (int)o; //unboxing


            //String.concat example
            //it takes three object values here. Both 42 and true must be boxed
            Console.WriteLine(String.Concat("Answer", 42, true));

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

    
            TestStringEquality();
            
        }
            public static void OpEqualsTest<T>(T s, T t) where T : class
{
    //在應用`where T: class`約束時，請避免對類型參數使用`==`和`!=`運算符，這些運算符僅測試引用標誌而不測試
    //相等性。即使再用作參數的類型中重載這些運算符也會發生此行為。下面的代碼說明了這一點；即使String類重載了`==`
    //運算符，輸出也為`false`
    System.Console.WriteLine(s == t);
    string first = "aaa";
    string second = first.ToString();
    System.Console.WriteLine(second == first);
}
private static void TestStringEquality()
{
    string s1 = "target";
    System.Text.StringBuilder sb = new System.Text.StringBuilder("target");
    string s2 = sb.ToString();
    OpEqualsTest<string>(s1, s2);
}
    }


    //可以對統一類型參數引用多個約束，並且約束自身可以是泛型類型， 如下所示
    // class EmployeeList<T> where T : Employee, IEmployee, System.IComparable<T>, new()
    // {
    // }

}
