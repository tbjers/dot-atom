#!/usr/bin/env bash
#
# tbjers/dot-atom ellipsis package
ATOM_PACKAGES="Stylus atom-beautify atom-jade atom-wallaby bottom-dock case-conversion
               docblockr git-log language-docker language-scala language-spacebars linter
               linter-docker linter-eslint markdown-scroll-sync markdown-writer
               merge-conflicts minimap minimap-pigments octocat-syntax open-recent pigments
               sort-lines space-tab todo-show wordcount language-vue editorconfig 
               language-elixir language-gettext"

pkg.link() {
  files=(config.cson init.coffee keymap.cson snippets.cson styles.less)
  for file in ${files[@]}; do
    fs.link_file common/$file $HOME/.atom/$file
  done
}

pkg.install() {
  mkdir -p $HOME/.atom
  case $(os.platform) in
    osx)
      if utils.cmd_exists brew; then
        brew cask install --appdir="/Applications" atom
      else
        echo "Cannot automatically install Atom without Homebrew."
      fi
      ;;
    linux)
      if utils.cmd_exists dnf; then
        RPM_FILE="`curl -s https://api.github.com/repos/atom/atom/releases | jq '[.[] | select(.prerelease == false)] | [.[] | .assets[] | select(.browser_download_url | endswith(".x86_64.rpm")).browser_download_url][0]' | tr -d '\"'`"
        RPM_VERSION="`echo $RPM_FILE | grep -o '/v[0-9][^/]\+/' | cut -d '/' -f 2`"
        PACKAGE="atom-${RPM_VERSION/v/}"
        if [[ ! -z "`rpm -q $PACKAGE | head -n 1 | grep 'not installed'`" ]]; then
          sudo dnf install -y --allowerasing pygtk2 libgnome pygpgme "${RPM_FILE}"
          apm upgrade --no-confirm --no-color $ATOM_PACKAGES
        else
          echo "Atom $RPM_VERSION is already installed, skipping."
        fi
      fi
      if utils.cmd_exists pacman; then
        sudo pacman -Sy --noconfirm atom
        apm upgrade --no-confirm --no-color $ATOM_PACKAGES
      fi
      ;;
  esac
}

pkg.pull() {
  git pull \
    && apm install --no-confirm --no-color $ATOM_PACKAGES
}
