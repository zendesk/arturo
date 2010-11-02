if ActiveSupport::Dependencies.respond_to?(:autoload_once_paths)
  # 2.3.9+
  ActiveSupport::Dependencies.autoload_once_paths << lib_path
elsif ActiveSupport::Dependencies.respond_to?(:load_once_paths)
  # 2.3.8-
  ActiveSupport::Dependencies.load_once_paths << lib_path
end
