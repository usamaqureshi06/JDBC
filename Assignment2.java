import java.sql.*;

public class Assignment2 {
    
    // A connection to the database  
    Connection connection;
  
    // Statement to run queries
    Statement sql;
  
    // Prepared Statement
    PreparedStatement ps;
  
    // Resultset for the query
    ResultSet rs;
  
    //CONSTRUCTOR
    Assignment2(){
        
		try {
		
 			// Load JDBC driver
			Class.forName("org.postgresql.Driver");
 
		} catch (ClassNotFoundException e) {
 
			e.printStackTrace();
			return;
 
		}
    }
  
    //Using the input parameters, establish a connection to be used for this session. Returns true if connection is sucessful
    public boolean connectDB(String URL, String username, String password){
        
       
		try {
			
 			//Make the connection to the database, ****** but replace <dbname>, <username>, <password> with your credentials ******
         connection=DriverManager.getConnection(URL,username,password);
         return true;
		} catch (SQLException e) {
 
			System.out.println("Connection Failed! Check output console");
			e.printStackTrace();
			return false;
 
		}
    }
  
    //Closes the connection. Returns true if closure was sucessful
    public boolean disconnectDB(){
        
       try {
        connection.close();
        return true;
       }
       catch(SQLException e)
       {
        return false;
       }
    }
    
    public boolean insertPlayer(int pid, String pname, int globalRank, int cid) {
        try{
        String sqlText;
        sqlText="Select * from player where pid ="+pid;
        
        int count=0;
        sql=connection.createStatement();
        rs=sql.executeQuery(sqlText);
        if(rs!=null)
        {
        while(rs.next())
        {
            count++;
        }
        }
        
        if(count==0)
        {
            sqlText="Insert INTO player values (?,?,?,?)";
           
            ps=connection.prepareStatement(sqlText);
            ps.setInt(1,pid);
            ps.setString(2,pname);
            ps.setInt(3,globalRank);
            ps.setInt(4,cid);
                          
            ps.executeUpdate();
            ps.close();
            
           
        return true;
        }
        
        
        rs.close();
        return false;
        }
        catch(SQLException e)
        {
        e.printStackTrace();
         System.out.println("insertion not performed");
         return false;
        }
    }
  
    public int getChampions(int pid) {
        int count=0;
        try{
          String sqlText;
        sqlText="Select * from champion where pid = "+pid;
        sql=connection.createStatement();
        rs=sql.executeQuery(sqlText);
        if(rs!=null)
        {
        while(rs.next())
        {
            count++;
        }
        }
        rs.close();

        }
        catch(SQLException e)
        {
         e.printStackTrace();
        }
	      return count;  
    }
   
    public String getCourtInfo(int courtid){
        int count=0;
        try{
        String sqlText;
        sqlText="Select courtid,courtname,capacity,tname from court,tournament where court.tid = tournament.tid and courtid ="+courtid;
        sql=connection.createStatement();
        rs=sql.executeQuery(sqlText);
        
        if(rs.next())
         {
            
        int crt=rs.getInt("courtid"); 
        String cname=rs.getString("courtname");
        int cap=rs.getInt("capacity");
        String tn=rs.getString("tname");
        
        rs.close();
        return crt+":"+cname+":"+cap+":"+tn;
         }
        
        else
        {
            rs.close();
            return "";
        }
        }
        catch(SQLException e)
        {
         e.printStackTrace();
        }

        return "";
    }

    public boolean chgRecord(int pid, int year, int wins, int losses){
        try{
            String sqlText="Select * from record where pid="+ pid;
            sql=connection.createStatement();
            rs=sql.executeQuery(sqlText);
            if(rs.next())
            {
            sqlText=" Update record set wins=?,losses=? where pid=? and year=?";
            ps = connection.prepareStatement(sqlText);
            ps.setInt(1,wins);
            ps.setInt(2,losses);
            ps.setInt(3,pid);
            ps.setInt(4,year);
                          
            ps.executeUpdate();
            ps.close();
            rs.close();
            return true;
            }
            else
            {   rs.close();
                return false;
            }
            
        }
        catch(SQLException e){
            e.printStackTrace();
            return false;
        }
        
    }

    public boolean deleteMatchBetween(int p1id, int p2id){
        try{
              
            String sqlText=" Delete from event where winid=? and lossid=? or (winid=? and lossid=?)";
            ps = connection.prepareStatement(sqlText);
            ps.setInt(1,p1id);
            ps.setInt(2,p2id);
            ps.setInt(3,p2id);
            ps.setInt(4,p1id);
                          
            ps.executeUpdate();
            ps.close();
            return true;
            
        }
        catch(SQLException e){
            e.printStackTrace();
            return false;
        }
              
    }
  
    public String listPlayerRanking(){
        try{
            int count=0;
            String temp="";
            String sqlText="Select pname,globalrank from player order by globalrank ASC";
            sql=connection.createStatement();
            rs=sql.executeQuery(sqlText);
            while(rs.next())
            {
               count++;
               temp=temp+rs.getString("pname")+":"+rs.getInt("globalrank")+"\n";

            }
            if(count>0)
            {
                 return temp;
            }
            else{
                return "";                               // no player exist in DB.
            }
        }
        catch(SQLException e)
        {
            e.printStackTrace();
             return "";
        }
    }
  
    public int findTriCircle(){
        try{
            int count=0;           // to check number of rows.
            String sqlText="select * from event e1 join event e2 on e2.winid=e1.lossid join event e3 on e2.lossid=e3.winid where e1.eid<>e3.eid";
            sql=connection.createStatement();
            rs=sql.executeQuery(sqlText);
            while(rs.next())
            {
               count++;
            }
            return count;
        }
        catch(SQLException e){
         return 0;
        }
        
    }
    
    public boolean updateDB(){
     
         try{
         String sqlText= " CREATE Table championPlayers( pid int NOT NULL,pname varchar(20) NOT NULL, nchampions int,PRIMARY KEY (pid), FOREIGN KEY(pid) REFERENCES player(pid))";
         sql=connection.createStatement();
         sql.executeUpdate(sqlText);

         sqlText="Insert into championPlayers(pid,pname,nchampions) select c.pid as pid ,p.pname as pname, count(c.pid) as nchampions from champion c,player p where c.pid=p.pid group by(c.pid,pname) order by (c.pid) ASC";
         sql.executeUpdate(sqlText);
         return true;
         }
         catch(SQLException e)
         {
         e.printStackTrace();
         return false;
         }
    }
      
    
}
//Insert into championPlayers(pid,pname,nchampions) select c.pid as pid ,p.pname as pname, count(c.pid) as nchampions from champion c,player p where c.pid=p.pid group by(c.pid,pname) order by (c.pid);
// select * from event e1 join event e2 on e2.winid=e1.lossid join event e3 on e2.lossid=e3.winid where e1.eid<>e3.eid;