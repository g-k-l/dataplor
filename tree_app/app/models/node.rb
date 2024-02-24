class Node < ApplicationRecord

  def self.common_ancestor_data(id_1, id_2)
    return nil if id_1.nil? || id_2.nil?

    id_1_safe = ActiveRecord::Base.connection.quote(id_1)
    id_2_safe = ActiveRecord::Base.connection.quote(id_2)

    # self.table_name = '_nodes' # for testing

    sql = %Q{ 
      WITH RECURSIVE ancestors_1 AS (
          SELECT
            id,
            parent_id,
            1 AS depth
          FROM 
            #{self.table_name}
          WHERE id = #{id_1_safe}
        UNION ALL
          SELECT
            t.id,
            t.parent_id,
            a.depth + 1 AS depth
          FROM
            #{self.table_name} AS t
          JOIN
            ancestors_1 AS a
          ON t.id = a.parent_id
      ),
      ancestors_2 AS (
          SELECT
            id,
            parent_id,
            1 AS depth
          FROM 
            #{self.table_name}
          WHERE id = #{id_2_safe}
        UNION ALL
          SELECT
            t.id,
            t.parent_id,
            a.depth + 1 AS depth
          FROM
            #{self.table_name} AS t
          JOIN
            ancestors_2 AS a
          ON t.id = a.parent_id
      ),
      common_ancestors AS (
        SELECT
          id
        FROM
          (
          SELECT 
            id
          FROM 
            ancestors_1 
          UNION ALL
          SELECT
            id
          FROM
            ancestors_2
          ) t
        GROUP BY id
        HAVING COUNT(1) > 1
      )
      SELECT 
        DISTINCT
        a.id,
        depth
      FROM
        (
        SELECT * FROM ancestors_1
        UNION ALL
        SELECT * FROM ancestors_2
        ) a
      JOIN
        common_ancestors AS c
      ON
        a.id = c.id
      ORDER BY 
        depth
      ;
    }
    result = ActiveRecord::Base.connection.exec_query(sql)
  
    if result.length > 0
      root_id = result[result.length-1]["id"]
      lowest_common_ancestor = result[0]["id"]

      max_root_dist, max_lca_dist = 0, 0
      result.each do |row|
        if row["id"] == root_id && max_root_dist < row["depth"]
          max_root_dist = row["depth"]
        end
        if row["id"] == lowest_common_ancestor && max_lca_dist < row["depth"]
          max_lca_dist = row["depth"]
        end
      end

      { 
        root_id: root_id,
        lowest_common_ancestor: lowest_common_ancestor,
        depth: max_root_dist - max_lca_dist + 1
      }
    else
      {
        root_id: nil,
        lowest_common_ancestor: nil,
        depth: nil,
      }
    end
  end

  def self.descendants_of(ids)
    # returns descendents only, not including the provided ids
    # self.table_name = '_nodes'
    sql = ActiveRecord::Base.sanitize_sql_array(
      [
        %Q{ 
          WITH RECURSIVE descendants AS (
              SELECT
                 id,
                 parent_id
              FROM
                 #{self.table_name}
              WHERE
                 parent_id IN (?)
              UNION ALL
              SELECT
                 t.id,
                 t.parent_id
              FROM
                 #{self.table_name} t
              JOIN descendants d ON t.parent_id = d.id
          )
          SELECT id FROM descendants;
        },
        ids
      ]
    )
    ActiveRecord::Base.connection.exec_query(sql).rows.flatten.uniq
  end
end
