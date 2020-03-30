import java.sql.*;

 
public class Driver {
 
	public static void main(String[] argv) {
     
     Assignment2 a2=new Assignment2();
     if(a2.connectDB("jdbc:postgresql://db:5432/usama06","usama06","212497103")==true)
     {
         System.out.println("Connection successful!");
     }
     else
     {
         System.out.println("Connection not successful!");
     }
     /*if(a2.disconnectDB()==true)
     {
       System.out.println("Disconnection successful!");
     }
     else
     {
       System.out.println("Disconnection not successful!");
     }*/

      if(a2.insertPlayer(106,"YellowKing",7,1)==true)
      {
          System.out.println("player Inserted!!");
      }
      else
      {
          System.out.println("player not Inserted!!");
      }

      System.out.println(a2.getChampions(101));
      System.out.println(a2.getCourtInfo(1));
      


    }
    }