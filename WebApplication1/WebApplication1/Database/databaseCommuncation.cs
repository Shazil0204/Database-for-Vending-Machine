﻿using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Data.SqlClient;


namespace WebApplication1.Database
{
    public class DatabaseConnection
    {
        public List<string> GetCities()
        {
            List<string> cities = new List<string>();

            var config = new ConfigurationBuilder()
               .AddJsonFile("appsettings.json")
               .Build();

            var conn = config.GetConnectionString("AllVendingMachinesDB");

            using (SqlConnection connection = new SqlConnection(conn))
            {
                string query = "SELECT DBName FROM DBRecords";

                SqlCommand command = new SqlCommand(query, connection);

                try
                {
                    connection.Open();

                    SqlDataReader reader = command.ExecuteReader();

                    while (reader.Read())
                    {
                        cities.Add(reader["DBName"].ToString());
                    }

                    reader.Close();
                }
                catch (SqlException e)
                {
                    Console.WriteLine(e.Message);
                    // Handle exception
                }
            }

            return cities;
        }
    }
}


