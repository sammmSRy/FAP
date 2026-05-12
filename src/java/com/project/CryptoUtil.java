package com.project;

import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.security.Key;

public class CryptoUtil {
    
    public static String encrypt(String data, String keyString, String algorithm) throws Exception {
        Key key = new SecretKeySpec(keyString.getBytes(), algorithm);
        Cipher cipher = Cipher.getInstance(algorithm);
        cipher.init(Cipher.ENCRYPT_MODE, key);
        byte[] encryptedBytes = cipher.doFinal(data.getBytes());
        return Base64.getEncoder().encodeToString(encryptedBytes);
    }

    
    public static String decrypt(String encryptedData, String keyString, String algorithm) throws Exception {
        Key key = new SecretKeySpec(keyString.getBytes(), algorithm);
        Cipher cipher = Cipher.getInstance(algorithm);
        cipher.init(Cipher.DECRYPT_MODE, key);
        byte[] decodedBytes = Base64.getDecoder().decode(encryptedData);
        byte[] decryptedBytes = cipher.doFinal(decodedBytes);
        return new String(decryptedBytes);
    }
}