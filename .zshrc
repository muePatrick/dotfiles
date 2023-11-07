shuf -n 1 ~/dotfiles/GLaDOS_Voicelines.csv | cowsay

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-fzf-history-search)

source $ZSH/oh-my-zsh.sh

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias lt="tmux ls"
alias t="tmux a"
alias tt="tmux a -t"
alias tn="tmux new -s"
alias ts="tmux"

alias g="git"

curl_cheat() {
  curl cheat.sh/$1
}
alias cheat=curl_cheat

find_open() {
  find -iname $1 | fzf | xargs --no-run-if-empty -i xdg-open '{}'
}
alias findopen=find_open

alias as="/home/patrick/android-studio/bin/studio.sh"
alias adbc="/home/patrick/Android/Sdk/platform-tools/adb connect"
export PATH=$PATH:/home/patrick/Android/Sdk/platform-tools

export GOROOT=/usr/lib/go-1.20
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

alias nocors="google-chrome --user-data-dir="/home/patrick/chrome-dev-disabled-security" --disable-web-security --disable-site-isolation-trials"

print_gh_issues() {
echo "\
#######################################\n\
######### 📤 My Pull Requests #########\n\
#######################################\n\
\n\
🟡 Waiting For Review:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
🔴 Changes Requested:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:changes_requested author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
🟢 Approved:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:approved author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
#######################################\n\
##### 📥 Pull Requests To Review ######\n\
#######################################\n\
\n\
📌 Waiting For My Review (explicit):\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none user-review-requested:@me' --jq '(["Updated","User","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), .user.login, (.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
💡 Waiting For My Review (implicit):\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none review-requested:@me -label:"dependencies"' --jq '(["Updated","User","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), .user.login, (.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
🤖 Waiting For My Review (Dependabot):\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none review-requested:@me label:"dependencies"' --jq '(["Updated","Repo","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.repository_url | split("/")[-1]), .title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
"
}
alias prm="print_gh_issues"
create_pr() {
  gh pr create \
    -t "$(git branch --show-current)" \
    -b "$(git --no-pager log --reverse --pretty=format:'## %s%n%b%n%n' $(git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4)..HEAD)" \
    $*
}
alias prc="create_pr"

update_token() {
  echo "$1" > /home/patrick/snabbleToken.txt
  decode_jwt 2 $(cat /home/patrick/snabbleToken.txt)
}
alias tou="update_token"

start_token() {
  REACT_APP_TOKEN=$(cat /home/patrick/devServerToken.jwt) npm start
}
alias tos=start_token
super_start_token() {
  REACT_APP_TOKEN=$(cat /home/patrick/devServerTokenPlatform.jwt) npm start
}
alias toss=super_start_token
userManagement_start_token() {
  REACT_APP_TOKEN=$(cat /home/patrick/userManagementToken$1.jwt) npm start
}
alias tosu=userManagement_start_token

print_token() {
  decode_jwt 2 $(cat /home/patrick/snabbleToken.txt)
}
alias top=print_token

alias ni="nvm use && npm ci"

decode_base64_url() {
  local len=$((${#1} % 4))
  local result="$1"
  if [ $len -eq 2 ]; then result="$1"'=='
  elif [ $len -eq 3 ]; then result="$1"'='
  fi
  echo "$result" | tr '_-' '/+' | openssl enc -d -base64
}

decode_jwt(){
  decode_base64_url $(echo -n $2 | cut -d "." -f $1) | jq 'if .exp then (.expStr = (.exp|gmtime|strftime("%Y-%m-%dT%H:%M:%S %Z"))) else . end'
}

# Decode JWT header
alias jwth="decode_jwt 1"

# Decode JWT Payload
alias jwtp="decode_jwt 2"

alias hd="wmctrl -r ':SELECT:' -e 0,800,1200,1920,1080"

source <(gh completion -s zsh)
source <(zoxide init zsh)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# added by travis gem
[ ! -s /home/patrick/.travis/travis.sh ] || source /home/patrick/.travis/travis.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
