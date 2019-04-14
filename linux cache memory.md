Buffer最常见的是铁道端头那个巨大的弹簧一类的东西。作用是万一车没停住，撞坦汗上减速慢，危险小一些。叫缓冲。

Cache就是一种保险箱。功能就是把你需要用的东西放在更容易拿到的地方。虽然常用准确翻译叫**缓存**，但丢了一般的功能。台湾的翻译更好，叫**快取**。

简单的说，Buffer的核心作用是用来缓冲，缓和冲击。比如你每秒要写100次硬盘，对系统冲击很大，浪费了大量时间在忙着处理开始写和结束写着两件事。用个buffer暂存起来，编程每10s写一次硬盘，对系统的冲击就很小，写入效率搞了，日子过得爽了。极大缓和了冲击。

Cache的核心作用是加快取用的速度。比如你一个很复杂的计算做完了，下次还要用结果，就把结果放手变一个好拿的地方存着，下次不用再算了。加快了数据取用的速度。

所以，如果你注意关系过存储系统的话，你会发现硬盘的读写缓冲/缓存名称是不一样的，叫`write-buffer`和`read-cache`。

当然很多时候宏观上说两者可能是混用的。比如实际上`memcached`很多人就是用来读写都用的。严格来说，CPU里的L2和L3 Cache也是读写兼用的—因为你没法简单地定义CPU用它们的方法是读还是写。硬盘里也是个典型例子，`buffer`和`cache`都在一起的空间上，到底是`buffer`还是`cache`？

你说拿cache做buffer行不行？当然行，只要能控制cache淘汰逻辑就没有任何问题。那么拿buffer做cache用呢？貌似在很特殊的情况下，能确定访问顺序的时候，也是可以的。

## How cache works in Linux

Here is a C app that gobbles up as much memory as it can, or to a specified limit:

```c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char** argv) {
    int max = -1;
    int mb = 0;
    char* buffer;

    if(argc > 1)
        max = atoi(argv[1]);

    while((buffer=malloc(1024*1024)) != NULL && mb != max) {
        memset(buffer, 0, 1024*1024);
        mb++;
        printf("Allocated %d MB\n", mb);
    }

    return 0;
}
```



Running out of memory isn't fun, but the OOM killer should end just this
process and hopefully the rest will remain undisturbed. We'll 
definitely want to disable swap for this, or the app will gobble up that
as well.



```shell
$ sudo swapoff -a

$ free -m
```

```
             total       used       free     shared    buffers     cached
Mem:          1504       1490         14          0         24        809
-/+ buffers/cache:        656        848
Swap:            0          0          0
```

```shell
$ gcc munch.c -o munch

$ ./munch
Allocated 1 MB
Allocated 2 MB
(...)
Allocated 877 MB
Allocated 878 MB
Allocated 879 MB
Killed

$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504        650        854          0          1         67
-/+ buffers/cache:        581        923
Swap:            0          0          0

```

Even though it said 14MB "free", that did't stop the application from grabbing 879MB. Afterwards, the cache is pretty empty(Some parts of the cache can't be dropped), but it will gradually fill up again as file are read and written.

**Disk cache won't cause applications** to use swap. Let's try that as well,

```shell
$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504       1490         14          0         10        874
-/+ buffers/cache:        605        899
Swap:         2047          6       2041

$ ./munch 400
Allocated 1 MB
Allocated 2 MB
(...)
Allocated 399 MB
Allocated 400 MB

$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504       1090        414          0          5        485
-/+ buffers/cache:        598        906
Swap:         2047          6       2041
```

Munch ate 400MB of ram, which was taken from the disk cache without resorting to swap. Likewise, we can fill the disk cache again and it will not start eating swap either.If you run `watch free -m` in one terminal, and `find . -type f -exec cat {} + > /dev/null` in another, you can see that "cached" will rise while "free" falls. After a while, it tapers off but swap is never touched[1](https://www.linuxatemyram.com/play.html#footnote1)

### Clear the disk cache

By writing 3 to `/proc/sys/vm/drop_caches`. We can clear most of the disk cache

```
$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504       1471         33          0         36        801
-/+ buffers/cache:        633        871
Swap:         2047          6       2041

$ echo 3 | sudo tee /proc/sys/vm/drop_caches 
3

$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504        763        741          0          0        134
-/+ buffers/cache:        629        875
Swap:         2047          6       2041
```



Notice how "buffers" and "cached" went down, free mem went up, and free+buffers/cache stayed the same

### Effects of disk cache on file reading

  Let's make a big file and see how disk cache affects how fast we can  read it. I'm making a 200mb file, but if you have less free ram, you can  adjust it.  

```
$ echo 3 | sudo tee /proc/sys/vm/drop_caches
3

$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504        546        958          0          0         85
-/+ buffers/cache:        461       1043
Swap:         2047          6       2041

$ dd if=/dev/zero of=bigfile bs=1M count=200
200+0 records in
200+0 records out
209715200 bytes (210 MB) copied, 6.66191 s, 31.5 MB/s

$ ls -lh bigfile
-rw-r--r-- 1 vidar vidar 200M 2009-04-25 12:30 bigfile

$ free -m
             total       used       free     shared    buffers     cached
Mem:          1504        753        750          0          0        285
-/+ buffers/cache:        468       1036
Swap:         2047          6       2041

$
```

  Since the file was just written, it will go in the disk cache. The 200MB  file caused a 200MB bump in "cached". Let's read it, clear the cache,  and read it again to see how fast it is:  

```
$ time cat bigfile > /dev/null

real    0m0.139s
user    0m0.008s
sys     0m0.128s

$ echo 3 | sudo tee /proc/sys/vm/drop_caches
3

$ time cat bigfile > /dev/null

real    0m8.688s
user    0m0.020s
sys     0m0.336s

$
```

  That's more than fifty times faster!  

### Effect of disk cache on load times

Let's make two test programs, one in Python and one in Java. Python and  Java both come with pretty big runtimes, which have to be loaded in  order to run the application. This is a perfect scenario for disk cache  to work its magic.   

```
$ cat hello.py
print "Hello World! Love, Python"

$ cat Hello.java
class Hello {
    public static void main(String[] args) throws Exception {
        System.out.println("Hello World! Regards, Java");
    }
}

$ javac Hello.java

$ python hello.py
Hello World! Love, Python

$ java Hello
Hello World! Regards, Java

$
```

​      Our hello world apps work. Now let's drop the disk cache, and see how long it takes to run them.  

```
$ echo 3 | sudo tee /proc/sys/vm/drop_caches
3

$ time python hello.py
Hello World! Love, Python

real    0m1.026s
user    0m0.020s
sys     0m0.020s

$ time java Hello
Hello World! Regards, Java

real    0m2.174s
user    0m0.100s
sys     0m0.056s

$
```

  Wow. 1 second for Python, and 2 seconds for Java? That's a lot just to  say hello. However, now all the file required to run them will be in the  disk cache so they can be fetched straight from memory. Let's try  again:   

```
$ time python hello.py
Hello World! Love, Python

real    0m0.022s
user    0m0.016s
sys     0m0.008s

$ time java Hello
Hello World! Regards, Java

real    0m0.139s
user    0m0.060s
sys     0m0.028s

$
```

  Yay! Python now runs in just 22 milliseconds, while java uses 139ms.  That's 45 and 15 times faster! All your apps get this boost  automatically!  
