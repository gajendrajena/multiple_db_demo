DB_SEC = YAML::load(ERB.new(File.read(Rails.root.join("config","database_sec.yml"))).result)[Rails.env]
