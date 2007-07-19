package ru.org.linux.site;

import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Properties;

import ru.org.linux.util.BadImageException;
import ru.org.linux.util.HTMLFormatter;
import ru.org.linux.util.ImageInfo;
import ru.org.linux.util.ProfileHashtable;

public class Poll {
  public static final int MAX_POLL_SIZE = 15;
  public static final int ORDER_ID = 1;
  public static final int ORDER_VOTES = 2;

  private final int id;
  private final String title;
  private final int topic;

  public static int getPollIdByTopic(Connection db, int msgid) throws SQLException {
    PreparedStatement pst = db.prepareStatement("SELECT votenames.id FROM votenames,topics WHERE topics.id=? AND votenames.topic=topics.id");
    pst.clearParameters();
    pst.setInt(1, msgid);
    ResultSet rs = pst.executeQuery();
    return rs.next()?rs.getInt("id"):0;
  }

  public void setTopicId(Connection db, int msgid) throws SQLException {
    PreparedStatement addPst = db.prepareStatement("UPDATE votenames SET topic=? WHERE id=?");
    addPst.clearParameters();
    addPst.setInt(1, msgid);
    addPst.setInt(2, id);
    addPst.executeUpdate();
  }

  public static int getCurrentPollId(Connection db) throws SQLException {
    Statement st = db.createStatement();

    ResultSet rs = st.executeQuery("SELECT votenames.id FROM votenames,topics WHERE topics.id=votenames.topic AND topics.moderate = 't' AND topics.deleted = 'f' AND topics.commitdate = (select max(commitdate) from topics where groupid=19387 AND moderate AND NOT deleted)");

    return rs.next()?rs.getInt("id"):0;
  }

  public static Poll getCurrentPoll(Connection db) throws SQLException {
    try {
      return new Poll(db, getCurrentPollId(db));
    } catch (PollNotFoundException ex) {
      throw new RuntimeException(ex);
    }
  }

  public Poll(Connection db, int id) throws SQLException, PollNotFoundException {
    this.id = id;

    Statement st = db.createStatement();

    ResultSet rs = st.executeQuery("SELECT title, topic FROM votenames WHERE id="+id);

    if (!rs.next()) {
      throw new PollNotFoundException(id);
    }

    title = rs.getString("title");
    topic = rs.getInt("topic");
  }

  public int getId() {
    return id;
  }

  public String getTitle() {
    return title;
  }

  private static int getNextPollId(Connection db) throws SQLException {
    Statement st = db.createStatement();
    ResultSet rs = st.executeQuery("select nextval('vote_id') as voteid");
    rs.next();
    return rs.getInt("voteid");
  }

  public static int createPoll(Connection db, String title, List pollList) throws SQLException {
    int voteid = getNextPollId(db);

    PreparedStatement pst = db.prepareStatement("INSERT INTO votenames (id, title) values (?,?)");

    pst.setInt(1, voteid);
    pst.setString(2, title);

    pst.executeUpdate();

    try {
      Poll poll = new Poll(db, voteid);

      for (Iterator i = pollList.iterator(); i.hasNext(); ) {
        String variant = (String) i.next();

        if (variant.trim().length()==0) {
          continue;
        }

        poll.addNewVariant(db, variant);
      }
      //Add new message
      
    } catch (PollNotFoundException ex) {
      throw new RuntimeException(ex);
    }

    return voteid;
  }

  public List getPollVariants(Connection db, int order) throws SQLException {
    List variants = new ArrayList();
    Statement st = db.createStatement();
    ResultSet rs;

    switch (order) {
      case ORDER_ID:
        rs = st.executeQuery("SELECT * FROM votes WHERE vote="+id+" ORDER BY id");
        break;
      case ORDER_VOTES:
        rs = st.executeQuery("SELECT * FROM votes WHERE vote="+id+" ORDER BY votes DESC, id");
        break;
      default:
        throw new RuntimeException("Oops!? order="+order);
    }

    while (rs.next()) {
      int varId = rs.getInt("id");
      String label = rs.getString("label");
      int votes = rs.getInt("votes");

      variants.add(new PollVariant(varId, label, votes));
    }

    return variants;
  }

  public int getTopicId() {
    return topic;
  }

  public int getMaxVote(Connection db) throws SQLException {
    Statement st = db.createStatement();
    ResultSet rs=st.executeQuery("SELECT max(votes) FROM votes WHERE vote="+id);
    rs.next();
    int max=rs.getInt("max");
    if (max == 0) {
      max = 1;
    }
    rs.close();
    st.close();

    return max;
  }

  public void addNewVariant(Connection db, String label) throws SQLException {
    PreparedStatement addPst = db.prepareStatement("INSERT INTO votes (id, vote, label) values (nextval('votes_id'), ?, ?)");

    addPst.clearParameters();

    addPst.setInt(1, id);
    addPst.setString(2, label);

    addPst.executeUpdate();
  }

  public String renderPoll(Connection db, Properties config, ProfileHashtable profile) throws SQLException, BadImageException, IOException {
    return renderPoll(db, config, profile, 0);
  }
  
  public String renderPoll(Connection db, Properties config, ProfileHashtable profile, int highlight) throws SQLException, BadImageException, IOException {
    StringBuffer out = new StringBuffer();
    int max = getMaxVote(db);
    List vars = getPollVariants(db, ORDER_VOTES);
    out.append("<table>");    
    ImageInfo info = new ImageInfo(config.getProperty("HTMLPathPrefix") + profile.getString("style") + "/img/votes.gif");
    int total = 0;
    for (Iterator iter = vars.iterator(); iter.hasNext();) {
	PollVariant var = (PollVariant) iter.next();
	out.append("<tr><td>");
	int id = var.getId();
	int votes = var.getVotes();
        if (id == highlight) {                                                                                                                                   
          out.append("<b>");                                                                                                                                      
	} 	
	out.append(HTMLFormatter.htmlSpecialChars(var.getLabel()));
        if (id == highlight) {                                                                                                                                   
          out.append("</b>");                                                                                                                                      
	}
      out.append("</td><td>").append(votes).append("</td><td>");
      total += votes;
	for (int i = 0; i < 20 * votes / max; i++) {
          out.append("<img src=\"/").append(profile.getString("style")).append("/img/votes.gif\" alt=\"*\" ").append(info.getCode()).append('>');
	}
	out.append("</td></tr>");
    }
    out.append("<tr><td colspan=2>����� �������: ").append(total).append("</td></tr>");
    out.append("</table>");
    return out.toString();
  }
  
  public String renderPoll(Connection db, String fullUrl) throws SQLException {
    StringBuffer out = new StringBuffer();
    int max = getMaxVote(db);
    List vars = getPollVariants(db, ORDER_VOTES);
    out.append("<table>");
    int total = 0;
    for (Iterator iter = vars.iterator(); iter.hasNext();) {
	PollVariant var = (PollVariant) iter.next();
	out.append("<tr><td>");
	int votes = var.getVotes();
	out.append(HTMLFormatter.htmlSpecialChars(var.getLabel()));
	out.append("</td><td>").append(votes).append("</td><td>");
	total += votes;
	for (int i = 0; i < 20 * votes / max; i++) {
          out.append("<img src=\"").append(fullUrl).append("white/img/votes.gif\" alt=\"*\">");
	}
	out.append("</td></tr>");
    }
    out.append("<tr><td colspan=2>����� �������: ").append(total).append("</td></tr>");
    out.append("</table>");
    return out.toString();
  }
  
}
