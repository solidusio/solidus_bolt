class RemoveBearerTokenOnSolidusBoltBoltConfiguration < ActiveRecord::Migration[6.1]
  def change
    remove_column :solidus_bolt_bolt_configurations, :bearer_token, :string
  end
end
