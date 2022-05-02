class SwapUrlForEnvBooleanInBoltConfiguration < ActiveRecord::Migration[6.1]
  def change
    add_column :solidus_bolt_bolt_configurations, :environment, :integer
    remove_column :solidus_bolt_bolt_configurations, :environment_url, :string
  end
end
