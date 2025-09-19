def flutter_root
  File.expand_path('..', File.dirname(__FILE__))
end

def flutter_ios_engine_dir
  File.join(flutter_root, 'engine')
end

def flutter_ios_app_framework_dir
  File.join(flutter_root, 'App.framework')
end

def flutter_install_all_ios_pods(_project_dir)
  # Placeholder implementation; run flutter tooling to generate pods.
end

def flutter_additional_ios_build_settings(_target)
end
