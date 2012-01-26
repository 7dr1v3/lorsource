/*
 * Copyright 1998-2010 Linux.org.ru
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

package ru.org.linux.spring.dao;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import ru.org.linux.site.DeleteInfo;
import ru.org.linux.site.DeleteInfoStat;
import ru.org.linux.user.User;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Получение информации кем и почему удален топик
 */
@Repository
public class DeleteInfoDao {
  private JdbcTemplate jdbcTemplate;
  private static final String QUERY_DELETE_INFO = "SELECT nick,reason,users.id as userid, deldate, bonus FROM del_info,users WHERE msgid=? AND users.id=del_info.delby";
  private static final String INSERT_DELETE_INFO = "INSERT INTO del_info (msgid, delby, reason, deldate, bonus) values(?,?,?, CURRENT_TIMESTAMP, ?)";

  @Autowired
  public void setJdbcTemplate(DataSource dataSource) {
    jdbcTemplate = new JdbcTemplate(dataSource);
  }

  /**
   * Кто, когда и почему удалил сообщение
   * @param id id проверяемого сообщения
   * @return информация о удаленном сообщении
   */
  public DeleteInfo getDeleteInfo(int id) {
    List<DeleteInfo> list = jdbcTemplate.query(QUERY_DELETE_INFO, new RowMapper<DeleteInfo>() {
      @Override
      public DeleteInfo mapRow(ResultSet resultSet, int i) throws SQLException {
        Integer bonus = resultSet.getInt("bonus");
        if (resultSet.wasNull()) {
          bonus = null;
        }

        return new DeleteInfo(
                resultSet.getString("nick"),
                resultSet.getInt("userid"),
                resultSet.getString("reason"),
                resultSet.getTimestamp("deldate"),
                bonus
        );
      }
    }, id);

    if (list.isEmpty()) {
      return null;
    } else {
      return list.get(0);
    }
  }

  public void insert(int msgid, User deleter, String reason, int scoreBonus) {
    jdbcTemplate.update(INSERT_DELETE_INFO, msgid, deleter.getId(), reason, scoreBonus);
  }

  public List<DeleteInfoStat> getRecentStats() {
    return jdbcTemplate.query(
            "select * from( select reason, count(*), sum(bonus) from del_info where deldate>CURRENT_TIMESTAMP-'1 day'::interval and bonus is not null group by reason) as s where sum!=0 order by reason",
            new RowMapper<DeleteInfoStat>() {
              @Override
              public DeleteInfoStat mapRow(ResultSet rs, int rowNum) throws SQLException {
                return new DeleteInfoStat(rs.getString("reason"), rs.getInt("count"), rs.getInt("sum"));
              }
            }
    );
  }
}
