portage_overlay "texlive" do
  repository "https://github.com/zentoo/texlive-overlay"
end

portage_package_use "app-text/texlive-core" do
  use "xetex"
end

package "dev-texlive/texlive-xetex"
