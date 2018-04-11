# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( dashboards.css pages.css easy-autocomplete.min.css ion.rangeSlider.skinFlat.css
																									ion.rangeSlider.css animate/animate.css daterangepicker.css slick/slick.css slick/slick-theme.css)
Rails.application.config.assets.precompile += %w( dashboards.js pages.js jquery.easy-autocomplete.min.js daterangepicker.js moment.js slick/slick.min.js)
Rails.application.config.assets.precompile += %w(sprite-skin-flat.png)