
// please write code
// from command line, ask f0f2 in MHz, fmin in MHz
// from 0 km to 3000 km, in steps of 100 km, calculate:
// angle of elevation in degrees
// MUF in MHz,
// LUF in MHz
// print results in a table
using System;

class Program
{
    static void Main(string[] args)
    {
        Console.Write("Enter f0f2 in MHz: ");
        double f0f2 = Convert.ToDouble(Console.ReadLine());

        Console.Write("Enter fmin in MHz: ");
        double fmin = Convert.ToDouble(Console.ReadLine());

        Console.Write("Enter height of F layer in km: ");
        double height = Convert.ToDouble(Console.ReadLine());

        Console.WriteLine("{0,13} {1,16} {2,10} {3,10}", "Distance (km)", "Elevation (deg)", "MUF (MHz)", "LUF (MHz)");
        Console.WriteLine(new string('-', 52));

        for (int distance = 0; distance <= 3000; distance += 100)
        {
            double elevationAngle = CalculateElevationAngle(distance, height);
            double muf = CalculateMUF(f0f2, elevationAngle);
            double luf = CalculateLUF(fmin, elevationAngle);

            Console.WriteLine("{0,13} {1,16:F2} {2,10:F2} {3,10:F2}", distance, elevationAngle, muf, luf);
        }
    }

    static double CalculateElevationAngle(int distance, double height)
    {
        // Simple model for elevation angle calculation
        if (distance == 0) return 90;
        return Math.Atan(height / (distance / 2.0)) * (180 / Math.PI);
    }

    static double CalculateMUF(double f0f2, double elevationAngle)
    {
        // Simple model for MUF calculation
        return f0f2 / Math.Sin(elevationAngle * (Math.PI / 180));
    }

    static double CalculateLUF(double fmin, double elevationAngle)
    {
        // Simple model for LUF calculation
        return fmin / Math.Sin(elevationAngle * (Math.PI / 180));
    }
}