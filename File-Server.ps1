Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Threading.Tasks;

public class SimpleFileServer
{
    public TcpListener Listener { get; private set; }

    public SimpleFileServer(IPAddress address, int port)
    {
        Listener = new TcpListener(address, port);
    }

    public async Task StartAsync(string rootDirectory)
    {
        Listener.Start();
        Console.WriteLine("Listening on " + Listener.LocalEndpoint);

        while (true)
        {
            var client = await Listener.AcceptTcpClientAsync();
            var _ = Task.Run(() => HandleClientAsync(client, rootDirectory)); // Handle client asynchronously
        }
    }

    private async Task HandleClientAsync(TcpClient client, string rootDirectory)
    {
        var clientEndpoint = client.Client.RemoteEndPoint.ToString();
        Console.WriteLine("Client connected: " + clientEndpoint);

        using (client)
        using (var stream = client.GetStream())
        using (var reader = new StreamReader(stream))
        using (var writer = new StreamWriter(stream))
        {
            var request = await reader.ReadLineAsync();
            Console.WriteLine(request);
            var tokens = request.Split(' ');

            if (tokens[0] == "GET")
            {
                var url = tokens[1];
                if (url == "/") url = "/index.html";
                var path = Path.Combine(rootDirectory, url.Replace("/", "\\").TrimStart('\\'));

                if (File.Exists(path))
                {
                    var content = File.ReadAllBytes(path);
                    writer.WriteLine("HTTP/1.1 200 OK");
                    writer.WriteLine("Content-Length: " + content.Length);
                    writer.WriteLine("Connection: close");
                    writer.WriteLine("");
                    await writer.FlushAsync();
                    await stream.WriteAsync(content, 0, content.Length);
                }
                else
                {
                    writer.WriteLine("HTTP/1.1 404 Not Found");
                    writer.WriteLine("Connection: close");
                    writer.WriteLine("");
                }
            }
            await writer.FlushAsync();
        }
    }
}
"@ -Language CSharp

function File-Server {
    
    param($Port, $Path)
    
    if(!$Port){$Port = 8080}
    if(!$Path){$Path = $pwd}

    # Now create an instance of this server in PowerShell and start it
    $server = New-Object SimpleFileServer ([IPAddress]::Any, $Port)
    $rootDirectory = $Path  # Set your files' directory here
    
    $task = $server.StartAsync($rootDirectory)
    $task.Wait()
}
