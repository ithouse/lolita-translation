require 'rails/generators'   
module LolitaMenu
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Copy assets."

      def copy_assets
        generate("lolita_menu:assets")
      end

    end
  end
end