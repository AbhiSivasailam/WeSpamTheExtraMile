class RedshiftManager
  def self.connection
    @conn ||= PG.connect(
      dbname: 'honeybookdb',
      port: 5439,
      user: 'ted',
      password: 'Honeybook972',
      host: 'hb-rs-cluster.cjmqa5biceca.us-west-2.redshift.amazonaws.com'
    )
    @conn
  end

  def self.query(query)
    results = connection.exec(query).entries
  end

  def self.format_results(data,format)
    case format
    when :json
      return data
    when :csv
      json = JSON.parse(data)
      return json.collect {|node| "#{node.collect{|k,v| v}.join(',')}\n"}.join
    end
  end
end