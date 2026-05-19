package com.project;
import java.io.*;
import java.security.*;
import java.util.*;
import javax.crypto.*;
import javax.crypto.spec.*;
import javax.servlet.*;
import com.project.LoginServlet;
import java.sql.*;

public class AuthenticationExtras
{
    /**
     * Sounds like a SHA-256 but it only uses one key :p
     * @param phrase The passphrase. If it exceeds 128 characters it throws an exception.
     * @return A 64-byte hexadecimal hash.
     */
    public static String encrypt(byte[] key, String phrase) throws
            IllegalArgumentException,
            ServletException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            IllegalBlockSizeException,
            BadPaddingException
    {
        if (phrase.length()>32)
            throw new IllegalArgumentException("Desired password is over 32 characters long, which can expand the hash past 64 bytes. Truncation can present a problem in the future.");
        
        String p;
        
        //try
        //{
            SecretKeySpec s = new SecretKeySpec(key, "AES");
            Cipher c = Cipher.getInstance("AES/ECB/NoPadding");
            
            byte[] f = Arrays.copyOf(phrase.getBytes(), 32); c.init(Cipher.ENCRYPT_MODE, s);
            byte[] e = c.doFinal(f); StringBuilder hex = new StringBuilder();
            for (byte b : e) hex.append(String.format("%02x", b));
            
            p = hex.toString();
        //}
        //catch (Exception e)
        //{
         //   throw new ServletException("Catastrophic error in the encryption process. Get a programmer! (" + e + ")");
        //}
        
        return p;    
    }
    
    /**
     * Decyption method for returning plaintext for show and changing password modules
     * @param phrase The 64-byte hash. Any other value will be 
     * @return A 64-byte hexadecimal hash.
     */
    public static String decrypt(byte[] key, String phrase) throws IllegalArgumentException, ServletException
    {
        if (phrase.length()!=64)
            throw new IllegalArgumentException("Invalid hash length. This is abnormal behaviour. Get a programmer!");
         
        String p;
        try
        {
            SecretKeySpec s = new SecretKeySpec(key, "AES");
            Cipher c = Cipher.getInstance("AES/ECB/NoPadding");
            
            byte[] encrypted = new byte[phrase.length() / 2];
            for (int i = 0; i < encrypted.length; i++) 
            {
                int index = i * 2; int j = Integer.parseInt(phrase.substring(index, index + 2), 16);
                encrypted[i] = (byte) j;
            }
            
            c.init(Cipher.DECRYPT_MODE, s);
            byte[] decrypted = c.doFinal(encrypted);
            p = new String(decrypted).trim();
        }
        catch (Exception e)
        {
            throw new ServletException("Catastrophic error in the encryption process. Get a programmer!");
        }
        
        return p;    
    }
    
    /**
     * Encrypts all passwords at once. (debug only)
     */
    static void DEBUG__encryptAllPasswords(Connection con, PrintWriter out, byte[] key)  throws
            IllegalArgumentException,
            ServletException,
            NoSuchAlgorithmException,
            NoSuchPaddingException,
            InvalidKeyException,
            IllegalBlockSizeException,
            BadPaddingException
    {
        // the forbidden query hot potato
        try (Statement stm = con.createStatement(); ResultSet rsm = stm.executeQuery("SELECT * FROM USERS WHERE LENGTH(PASSWORD) <> 64"))
        {
            while (rsm.next())
            {
                //out.println(rsm.getString("PASSWORD") != null? rsm.getString("PASSWORD") : "fah");
                //out.println(rsm.getString("EMAIL") != null? rsm.getString("EMAIL") : "fah");
                
                try (PreparedStatement pstm = con.prepareStatement("UPDATE USERS SET PASSWORD = ? WHERE EMAIL = ?"))
                {
                    pstm.setString(1, encrypt(key, rsm.getString("PASSWORD")));
                    pstm.setString(2, rsm.getString("EMAIL"));
                    pstm.executeUpdate();
                }
            }
        }
        catch (SQLException e)
        {
            System.err.println("Error in authentication process!");
            System.err.println(e.getMessage());
            throw new ServletException(e);
        }
    }
}