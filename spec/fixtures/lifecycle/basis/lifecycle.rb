class MyLifecycle < Basis::Installer::Lifecycle
  def install?(path)
    "nocopy.txt" != path.basename.to_s
  end
end
