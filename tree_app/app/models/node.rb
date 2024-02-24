class Node < ApplicationRecord

  def self.least_common_ancestor(id_1, id_2)
    return nil if id_1.nil? || id_2.nil?

    id_1_safe = ActiveRecord::Base.connection.quote(id_1)
    id_2_safe = ActiveRecord::Base.connection.quote(id_2)

    sql = %Q{ 
      WITH RECURSIVE ancestors AS (
          SELECT
            id,
            parent_id,
            0 AS depth
          FROM 
            #{self.table_name}
          WHERE id = #{id_1_safe} OR id = #{id_2_safe}
        UNION ALL
          SELECT
            t.id,
            t.parent_id,
            a.depth + 1 AS depth
          FROM
            #{self.table_name} AS t
          JOIN
            ancestors AS a
          ON t.id = a.parent_id
      ),
      common_ancestors AS (
        SELECT
          id
        FROM
          ancestors 
        GROUP BY id
        HAVING COUNT(1) > 1
      )
      SELECT 
        a.id
      FROM
        ancestors AS a
      JOIN
        common_ancestors AS c
      ON
        a.id = c.id
      ORDER BY 
        depth
      ;
    }
    result = ActiveRecord::Base.connection.exec_query(sql)
  end
end
