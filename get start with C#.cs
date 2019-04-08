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

            // Boxing is the process of converting a va

            // A variable of value type contains a value of the type. For example, a varibale
            // of the `int` type might contain the value `42`. This differes from a variable of a reference type, 
            // which contains a reference to an instance of the type, also known as an object
        }
    }
}
