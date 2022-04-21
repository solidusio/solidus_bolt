# frozen_string_literal: true

Spree::Backend::Config.configure do |config|
  config.locale = 'en'

  config.menu_items << config.class::MenuItem.new(
    [:bolt],
    'bolt',
    condition: -> { can?(:admin, :bolt) },
    url: :admin_bolt_path,
    position: 6,
    match_path: %r{/admin/bolt/}
  )
end
