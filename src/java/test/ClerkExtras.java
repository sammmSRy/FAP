/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package test;

import java.nio.*;
import java.util.*;

/**
 *
 * @author Adrian
 */
public class ClerkExtras {
    public static String abbr(String given)
    {
        String[] comps = given.toUpperCase().split(" ");
        String fin = "";
        for (String comp: comps) fin+=comp.charAt(0)+". ";
        return fin.trim();
    }
    
    public static byte[] uuidEncoding(UUID id)
    {
        UUID thing = UUID.randomUUID();
        ByteBuffer buffer = ByteBuffer.allocate(16);
        buffer.putLong(thing.getMostSignificantBits());
        buffer.putLong(thing.getLeastSignificantBits());
        return buffer.array();
    }
}
