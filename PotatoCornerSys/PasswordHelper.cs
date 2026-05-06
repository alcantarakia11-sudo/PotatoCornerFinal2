using System;
using System.Security.Cryptography;
using System.Text;

namespace PotatoCornerSys
{
    public static class PasswordHelper
    {
        /// <summary>
        /// Hashes a password using SHA256 (compatible with SQL Server HASHBYTES)
        /// </summary>
        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                return string.Empty;

            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                {
                    builder.Append(b.ToString("x2")); // lowercase hex
                }
                return builder.ToString();
            }
        }

        /// <summary>
        /// Verifies if a plain text password matches a hashed password
        /// </summary>
        public static bool VerifyPassword(string plainPassword, string hashedPassword)
        {
            if (string.IsNullOrEmpty(plainPassword) || string.IsNullOrEmpty(hashedPassword))
                return false;

            string hashOfInput = HashPassword(plainPassword);
            return string.Equals(hashOfInput, hashedPassword, StringComparison.OrdinalIgnoreCase);
        }
    }
}
