package com.project;

public class GenerateEncryptedPassword {
    public static void main(String[] args) throws Exception {
        String plainPassword = "admin";                    
        String secretKey = "MySecr3tK3y12345";           
        String algorithm = "AES";                         

        String encrypted = CryptoUtil.encrypt(plainPassword, secretKey, algorithm);

        System.out.println("Plain:  " + plainPassword);
        System.out.println("Encrypted: " + encrypted);
        System.out.println("\nINSERT statement:");
        System.out.println("INSERT INTO APP.USERS (USERNAME, PASSWORD, ROLE) VALUES ('"
                           + plainPassword + "', '" + encrypted + "', 'admin');");
    }
}