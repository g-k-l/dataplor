namespace :nodes do
  desc "load nodes CSV file"
  task load_csv: :environment do
    copy_sql = %Q{ 
      COPY nodes (id, parent_id)
      FROM STDIN WITH (FORMAT csv, HEADER true);
    } 

    file_path = File.join(File.dirname(__FILE__), "nodes.csv")
    conn = ActiveRecord::Base.connection_pool.checkout.raw_connection
    conn.copy_data(copy_sql) do 
      File.open(file_path).each do |line|
        conn.put_copy_data(line)
      end
    end
  end
end
