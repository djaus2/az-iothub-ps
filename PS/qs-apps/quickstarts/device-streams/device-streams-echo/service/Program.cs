// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for full license information.

using System;

namespace Microsoft.Azure.Devices.Samples
{
    public static class Program
    {
        // The IoT Hub connection string. This is available under the "Shared access policies" in the Azure portal.

        // For this sample either:
        // - pass this value as a command-prompt argument
        // - set the IOTHUB_CONN_STRING_CSHARP environment variable 
        // - create a launchSettings.json (see launchSettings.json.template) containing the variable
        private static string s_connectionString = Environment.GetEnvironmentVariable("IOTHUB_CONN_STRING_CSHARP");

        // ID of the device to interact with.
        // - pass this value as a command-prompt argument
        // - set the DEVICE_ID environment variable     
        // - create a launchSettings.json (see launchSettings.json.template) containing the variable
        private static string s_deviceId = Environment.GetEnvironmentVariable("DEVICE_ID");

        // Select one of the following transports used by ServiceClient to connect to IoT Hub.
        private static TransportType s_transportType = TransportType.Amqp;
        //private static TransportType s_transportType = TransportType.Amqp_WebSocket_Only;

        public static int Main(string[] args)
        {
            if (string.IsNullOrEmpty(s_connectionString) && args.Length > 0)
            {
                s_connectionString = args[0];
            }

            if (string.IsNullOrEmpty(s_deviceId) && args.Length > 1)
            {
                s_deviceId = args[1];
            }

            if (string.IsNullOrEmpty(s_connectionString) ||
                string.IsNullOrEmpty(s_deviceId))
            {
                Console.WriteLine("Service: Please provide a connection string and device ID");
                Console.WriteLine("Service: Usage: ServiceClientC2DStreamingSample [iotHubConnString] [deviceId]");
                return 1;
            }
            Console.WriteLine("Service: Starting (Got parameters)");
            Console.WriteLine ("Using Env Var IOTHUB_CONN_STRING_CSHARP = " + s_connectionString );
            Console.WriteLine ("Using Env Var DEVICE_ID (N.b Same as DEVICE_NAME) = " + s_deviceId );
            Console.WriteLine("Using TransportTyoe {0}",s_transportType );
            
            using (ServiceClient serviceClient = ServiceClient.CreateFromConnectionString(s_connectionString, s_transportType))
            {
                var sample = new DeviceStreamSample(serviceClient, s_deviceId);
                sample.RunSampleAsync().GetAwaiter().GetResult();
            }

            Console.WriteLine("Service: Done.\n");
            Console.WriteLine("Service:Press any key to close window.");
            Console.ReadKey();
            return 0;
        }
    }
}
