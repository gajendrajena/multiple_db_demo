
class SecBase < ApplicationRecord
  establish_connection DB_SEC
  self.abstract_class = true
end