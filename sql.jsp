<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>

<%
    // Function to write login log to a text file
    void writeLoginLogToFile(String username, String action) {
        try {
            File file = new File("login_log.txt");
            FileWriter writer = new FileWriter(file, true);
            writer.write(username + " - " + action + " - " + new Date() + "\n");
            writer.close();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    // Function to get login logs from the database
    List<String> getLoginLogs() {
        List<String> loginLogs = new ArrayList<>();
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/db_name", "username", "password");
            Statement stmt = con.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT * FROM login_logs");

            while (rs.next()) {
                String username = rs.getString("username");
                String action = rs.getString("action");
                String timestamp = rs.getString("timestamp");
                loginLogs.add(username + " - " + action + " - " + timestamp);
            }

            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return loginLogs;
    }

    // Function to add a login log to the database
    void addLoginLog(String username, String action) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/db_name", "username", "password");
            PreparedStatement pstmt = con.prepareStatement("INSERT INTO login_logs (username, action) VALUES (?, ?)");
            pstmt.setString(1, username);
            pstmt.setString(2, action);
            pstmt.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Function to delete a login log from the database
    void deleteLoginLog(int logId) {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/db_name", "username", "password");
            PreparedStatement pstmt = con.prepareStatement("DELETE FROM login_logs WHERE id = ?");
            pstmt.setInt(1, logId);
            pstmt.executeUpdate();
            con.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
<head>
  <title>Login Log</title>
  <style>
    table {
      border-collapse: collapse;
      width: 100%;
    }
    th, td {
      padding: 8px;
      text-align: left;
      border-bottom: 1px solid #ddd;
    }
    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>
  <h2>Login Log</h2>

  <form method="post">
    <label for="username">Username:</label>
    <input type="text" id="username" name="username" required>

    <label for="action">Action:</label>
    <input type="text" id="action" name="action" required>

    <button type="submit" name="addBtn">Add</button>
  </form>

  <table>
    <thead>
      <tr>
        <th>Username</th>
        <th>Action</th>
        <th>Timestamp</th>
        <th>Actions</th>
      </tr>
    </thead>
    <tbody>
      <% 
          List<String> loginLogs = getLoginLogs();
          for (String log : loginLogs) {
              String[] logData = log.split(" - ");
              String username = logData[0];
              String action = logData[1];
              String timestamp = logData[2];
      %>
      <tr>
        <td><%= username %></td>
        <td><%= action %></td>
        <td><%= timestamp %></td>
        <td>
          <form method="post" style="display: inline;">
            <input type="hidden" name="logId" value="<%= logData[3] %>">
            <button type="submit" name="deleteBtn">Delete</button>
          </form>
          <form method="post" style="display: inline;">
            <input type="hidden" name="logId" value="<%= logData[3] %>">
            <input type="text" name="newAction" placeholder="New action" required>
            <button type="submit" name="modifyBtn">Modify</button>
          </form>
        </td>
      </tr>
      <% } %>
    </tbody>
  </table>

  <%-- Process the form submissions --%>
  <%
    if (request.getParameter("addBtn") != null) {
        String username = request.getParameter("username");
        String action = request.getParameter("action");
        addLoginLog(username, action);
        writeLoginLogToFile(username, action);
        response.sendRedirect(request.getRequestURI());
    }

    if (request.getParameter("deleteBtn") != null) {
        int logId = Integer.parseInt(request.getParameter("logId"));
        deleteLoginLog(logId);
        response.sendRedirect(request.getRequestURI());
    }

    if (request.getParameter("modifyBtn") != null) {
        int logId = Integer.parseInt(request.getParameter("logId"));
        String newAction = request.getParameter("newAction");
        // Perform update operation in the database using logId and newAction
        response.sendRedirect(request.getRequestURI());
    }
  %>
</body>
</html>
