/**
 * @ CopyRight (C) 2024 by Piero Rolando
 * github.com/pierorolando1
 */
package com.example;

import org.jpl7.*;

public class App 
{
    public static void main( String[] args ) {
      Query consultQuery = new Query(
            "consult", 
            new Term[] {new Atom("/app/src/main/resources/test.pl")}
      );
      if (!consultQuery.hasSolution()) {
            throw new RuntimeException("Failed to consult the Prolog file.");
      }

      Query query = new Query("maricon(charlie).");

      if(query.hasSolution())
        System.out.println("Charlie is a maricon.");
      else
        System.out.println("No solution found.");
    }
}
