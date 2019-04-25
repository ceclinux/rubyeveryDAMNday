ASP.NET Core is thelastest evolution of Microsoft's ASP.NET web framework, released in June 2016.

ASP.NET MVC has been through four more iterations ince its first release, but they have all been built on the same underlying framework provided by the `System.Web.dll` file.

The development of ASP.NET Core was motivated by the desire to create a web framework with four main goals:

- To be run and develop cross-platform
- To have a modular architecture for easier maintenance
- To be developed completed as open source software
- To be applicable to current trends in web development, such as client-side application and deloying to cloud environments

.Net Core shares many of the same APIs as .NET framework, but it's smaller and currently only implements a subset of the features.

ASP.NET core run on both .NET Framework and .Net Core, so it can run cross-platform. Conversely, ASP.NET runs on .NET framework only, so is tied to the Windows OS.

Microsoft provides, by default, a cross-platform web server called Kestrel.

This is where containers come in. Containers are far more lightweight and don't have the overhead of virtual machines. They're built in series of layers and don't require you to boot a new operating system when starting a new one. That means they're quick to start and are great for quick provisioning. Containers, and Docker in particular, are quickly becoming the go-to platform for building large, scalable systems.

As well as running on each platform. One of the selling points of .Net is the ability to write and compile only once. Your application is complied to intermediate Language code, which is a platform-independent format. If a target system has the .NET Core platform installed, then you can run compiled IL from any platform. That means you can, for example,  develop on a Mac or Windows machine and deploy the exact same files to your production Linux machines. This compile-once, run-anywhere promise has finally been realized with `ASP.NET` Core and `.Net` core.

The difference between hosting models in ASP.NET(top) and ASP.NET core(bottom). With the previous version of ASP.NET, IIS is tightly coupled with the application. The hosting model in ASP.NET core is simpler; IIS hands off the request to a self-hosted web server in the ASP.NET Core application and receives the response, but has no knowledge of the application.

![](http://ceclinux.org:8888/ae/74b754d63d698233ffc2e735b7ad8797e82d46.png)

A **reverse proxy** is a software for receiving requests and forwarding them to the appropriate web server. The reverse proxy is exposed directly to the internet, whereas the underlying web server is exposed only to the proxy. This setup has several benefits, primarily security and performance for the web servers.

Kestrel by default, which is responsible for receiving raw requests and constructing an internal representation of the data, an `HttpContext` object, which can be used by the rest of the application.

A request is received fro a browser at the reverse proxy, which passes the request to the `ASP.NET` Core application, which runs a self-hosted web server. The web server processes the request and passes it to the body of the application, which generates a response ad returns it to the web server. The web server replays this to the reverse proxy, which sends the response to the browser.

You may be thinking that having a reverse proxy and a web server is somewhat redundant. Why not have on or the other? Well, one of the benefits is the decoupling of your application fro the underlying operating system. The same ASP.NET core web-server, Kestrel, can be cross-platform and used behind a variety of proxies without putting any constraint on a particular implementation. Alternatively, if you wrote a new ASP.NET Core web server, you could use that in place of Kestrel without needing to change anything else about your application.

Another benefit of a reverse proxy is that it can be hardened against potential threats from the public internet. They're often responsible for additional aspects, such as restarting a process that has crashed. Kestrel can stay as a simple HTTP server without having to worry about these extra features when it's used behind a reverse proxy. Think of it as a simple separation of concerns: Kestrel is concerned with generating HTTP response; a reverse proxy is concerted with handling the connection to the internet.

Kestrel is responsible for receiving the request data and constructing a C# representation of the request, but it doesn't attempt to handle the request directly. For that, Kestrel hands the `HttpContext` to the middleware pipeline found in every ASP.NET Core application. This is a series of components that processes the incoming request to perform common operations such as logging, handling exceptions, or serving static files.

`Program.cs` and `Startup.cs` control the startup and configuration of your application at runtime.

The `csproj` file contains all the details required to build your project, including the NuGet packages used by your project.

The wwwroot folder is special, in that it's the only folder in your application that browsers are allowed to directly access when browsing your web app. You can store your CSS, Javascript, images, or static HTML files in here and browsers will be able to access them. They won't be able to access any file that lives outside of wwwroot.

```
<Project Sdk="Microsoft.NET.Sdk.Web">
// The SDK attribute specifies the type of project you're building
  <PropertyGroup>
    <TargetFramework>netcoreapp2.1</TargetFramework>
    //The TargetFramework is the framework you'll run on, in this case, .NET Core 2.0. if you're running on the full .NET framework, this would be `net461`
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.App" />
    <PackageReference Include="Microsoft.AspNetCore.Razor.Design" Version="2.1.2" PrivateAssets="All" />
    // You reference NuGet packages with the PackageReference element
    // Additional tools used by Visual Studio to generate controllers and views at design time
  </ItemGroup>

</Project>
```

The most common changes you'll make to the project file are to add additional NuGet packages using the `packageReference` element. 

A `metapackage` is a NuGet package that contains no code, referencing one or more other NuGet packages instead. By adding the metapackage to your app, you can conveniently and implicitly add all of the packages it references. In ASP.NET Core 2.1, the Microsoft.AspNetCore.App metapackage is referenced by default instead.

All ASP.NET Core applications start in the same way as .NET Console applications - with a `Program.cs` file. The file contains a `static void Main` function, which is a standard characteristic of console apps. This method must exist and is called whenever you start your web application. In ASP.NET Core applications, it's used to build and run an `IWebHost` instance, as shown in the following listing, which shows the default `Program.cs` file. The `IWebHost` is the core of your ASP.NET Core application, containing the application configuration and the Kestrel server that listens for requests and sends responses.

```csharp
public class Program
{
  public static void Main(string[] args){
    // Create an IWebHost using the BuildWebHost method.
    BuildWebHost(args).Run();
    // Run the IWebHost, start listening for requests and generating responses.
  }
  public static IWebHost BuildWebHost(string[] args) =>
    // create a WebHostBuilder using the default configuration
    WebHost.CreateDefaultBuilder(args).UseStartup<Startup>()
    // The startup class defines most of your application's configuration
    .Build();
     // Build and return an instance of IWebHost from the WebHostBuilder
}
```

Much of your app's configuration takes place in the `WebHostBuilder` created by the call to `CreateDefaultBuilder`, but it delegates some responsibility to a separate calss, `Startup`. The `Startup` class referenced in the generic `UseStartup<>` method is where you configure your app's services and define your middleware pipeline.

The `differnce` in configuration scope for `Program` and `Startup` . `Program` is concerned with infrastructure configuration that will typically remain stable throughout the lifetime of the project.  In contrast, you'll often modify `Startup` to add new features and to update application behavior.

![](http://ceclinux.org:8888/7b/a6996a2d23bf2645f9604801755e4c6c1ad900.png)

The startup class is responsible for configuring two main aspects of your application:

- *Service registration* - Any classes that your application depends on for providing functionality - both those used by the framework and those specific to your application - must be registered so that they can be correctly instantiated at runtime.
- *Middleware and MVC* - How your application handles and responds to requests

```cs
public class Startup
{
  public void ConfigureServices(IServiceCollection services){
    // configure services by registering services with the IServiceCollection
  }
  public void Configure(IApplication app){
    // configure the middleware pipeline for handling HTTP requests
  }
}
```

