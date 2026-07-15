shuf -n 1 ~/dotfiles/GLaDOS_Voicelines.csv | cowsay
source ~/dotfiles/secrets.sh

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
plugins=(git zsh-autosuggestions zsh-fzf-history-search zsh-ai-commands)

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

alias b="batcat"

# alias fd="fdfind"

alias tf="terraform"

alias lln="ll -t | head"

alias d="docker"

alias glogin="eval \"$(ssh-agent -s)\" && ssh-add ~/.ssh/snabble_github_new && export GITHUB_LOGGED_IN=true"

dockercontainerwait() {
  echo "### Running Command ###"
  if [[ $1 == "-a" ]]; then
    eval ${@:2} | tee /dev/tty | grep "Creating service" | wc -l | read SERVICE_COUNT
    echo "### Waiting for $SERVICE_COUNT services ###"
    while [[ $(docker ps | wc -l) -ne $(($SERVICE_COUNT+1)) ]]; do sleep 1; done; echo done
    notify-send -t 1 "Docker Container Wait" "$SERVICE_COUNT services reached"
    echo "###  $SERVICE_COUNT services reached ###"
  else
    eval ${@:2}
    echo "### Waiting for $1 services ###"
    while [[ $(docker ps | wc -l) -ne $(($1+1)) ]]; do sleep 1; done; echo done
    notify-send -t 1 "Docker Container Wait" "$1 services reached"
    echo "###  $1 services reached ###"
  fi
}
alias dcw="dockercontainerwait"
alias dockernamef="docker ps --format 'json' | jq -r '.Names' | fzf"
alias dnf="docker ps --format 'json' | jq -r '.Names' | fzf"

restart_testing_stack() {
    # Get list of all running stacks
    STACKS=$(docker stack ls --format "{{.Name}}")

    # Remove stacks if list is not empty
    if [ -z "$STACKS" ]; then
        echo "No stacks found, skipping removal..."
    else
        echo "Removing all stacks..."
        echo "$STACKS" | xargs docker stack rm
    fi

    # Wait until all containers are removed
    echo "Waiting for all containers to be removed..."
    dockercontainerwait 0

    # Sleep to prevent docker network not being creatable
    sleep 1

    # Start new stack by running setup script
    echo "Starting new stack..."
    ./testing/deps
}
alias td="restart_testing_stack"

alias tf="terraform"

alias g="git"
create_worktree() {
  git branch | fzf | xargs --no-run-if-empty -I {} git worktree add ~/worktrees/$(basename $PWD)/{} {}
}
alias wta="create_worktree"
select_worktree() {
  pushd "$(git worktree list | cut -d" " -f 1 | fzf)"
}
alias wtl="select_worktree"
remove_worktree() {
  git worktree list | cut -d" " -f 1 | fzf | xargs --no-run-if-empty -I {} git worktree remove {}
}
alias wtr="remove_worktree"
start_gitkraken_in_current_folder() {
  gitkraken -p "$(pwd)"
}
alias gk="start_gitkraken_in_current_folder"

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

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export GOBIN=$GOPATH/bin
export GOPRIVATE='github.com/snabble/*'
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$GOROOT/bin

export PATH=$PATH:/usr/bin/flutter/flutter/bin

export PATH="$PATH:/opt/nvim-linux64/bin"
export PATH="$PATH:/home/patrick/.fzf/bin"

export EDITOR=nvim # for C-x C-e
export BROWSER=$(xdg-settings get default-web-browser | cut -d"." -f1)

export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH" # for ASDF
# source ${ASDF_DATA_DIR:-$HOME/.asdf}/plugins/golang/set-env.zsh

alias nocors="google-chrome --user-data-dir="/home/patrick/chrome-dev-disabled-security" --disable-web-security --disable-site-isolation-trials"

rand() {
  echo $((RANDOM % $1))
}

print_gh_issues() {
echo "\
#######################################\n\
######### 📤 My Pull Requests #########\n\
#######################################\n\
\n\
🟡 Waiting For Review:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.comments | if . > 0 then "💬  " else "" end)+(.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
🔴 Changes Requested:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:changes_requested author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.comments | if . > 0 then "💬  " else "" end)+(.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
🟢 Approved:\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:approved author:@me' --jq '(["Updated","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.comments | if . > 0 then "💬  " else "" end)+(.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
#######################################\n\
##### 📥 Pull Requests To Review ######\n\
#######################################\n\
\n\
📌 Waiting For My Review (explicit):\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none user-review-requested:@me' --jq '(["Updated","User","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), .user.login, (.comments | if . > 0 then "💬  " else "" end)+(.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
💡 Waiting For My Review (implicit):\n\
\n\
$(gh api -X GET search/issues -f q='state:open review:none review-requested:@me -label:"dependencies"' --jq '(["Updated","User","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), .user.login, (.comments | if . > 0 then "💬  " else "" end)+(.draft | if . == true then "✏️  " else "" end)+.title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
\n\
---------------------------------------\n\
\n\
"
# 🤖 Waiting For My Review (Dependabot):\n\
# \n\
# $(gh api -X GET search/issues -f q='state:open review:none review-requested:@me label:"dependencies"' --jq '(["Updated","Repo","Title","Url"] | (., map(length*"-"))), (.items[] | [(.updated_at | sub("\\.000Z$"; "Z") | fromdateiso8601 | strftime("%d.%m.%Y %H:%M")), (.repository_url | split("/")[-1]), .title, .pull_request.html_url]) | @tsv' | column -ts $'\t')\n\
# \n\
# ---------------------------------------\n\
# \n\
# "
}
alias prm="print_gh_issues"

create_pr() {
  local spacer
  spacer='\n\n'
  gh pr create \
    -t "$(git branch --show-current)" \
    -b "$(git --no-pager log --reverse --pretty=format:'## %s%n%b%n%n' $(git symbolic-ref refs/remotes/origin/HEAD | cut -d'/' -f4)..HEAD)

[Jira Ticket]($(get_ticket_url))" \
    $* && gh pr view --web
}
alias prc="create_pr"

alias prd="gh dash --config $HOME/dotfiles/.gh-dash-config.yml"

get_ticket_url() {
    if [ -z "$TICKET_BASE_URL" ]; then
        echo "No JIRA base URL set. Please configure the URL in the variable TICKET_BASE_URL"
        return 1
    fi

    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    local ticket_id
    ticket_id=$(echo "$branch_name" | grep -oE '^[A-Z]+-[0-9]+')

    if [ -n "$ticket_id" ]; then
        echo "${TICKET_BASE_URL}/${ticket_id}"
    else
        echo "No JIRA ticket found in branch name"
    fi
}

open_ticket() {
    if [ -z "$TICKET_BASE_URL" ]; then
        echo "No JIRA base URL set. Please configure the URL in the variable TICKET_BASE_URL"
        return 1
    fi

    local branch_name
    branch_name=$(git rev-parse --abbrev-ref HEAD)
    local ticket_id
    ticket_id=$(echo "$branch_name" | grep -oE '^[A-Z]+-[0-9]+')

    if [ -n "$ticket_id" ]; then
        xdg-open "${TICKET_BASE_URL}/${ticket_id}"
    else
        echo "No JIRA ticket found in branch name"
    fi
}
alias prt="open_ticket"

alias prw="gh pr view --web"

clone_repo() {
  # This function is called the name of the orga as the only argument.
  # It shows the list of available repos where multiple can be selected.
  # Since the fzf features used require a new version of fzf the apt version
  # is not sufficient.

  if [ -z "$1" ]; then
      echo "No organization given."
      return 1
  fi
  REPOS_AVAIL=$(gh repo list "$1" --limit 1000 --json url,name,description --jq '.[] | "\(.url) \(.name) \(.description)"')

  if [ -z "$REPOS_AVAIL" ]; then
      echo "No repositories found for organization."
      return 1
  fi

  REPO_NAMES=$(echo $REPOS_AVAIL |  awk '{print $2}')
  REPO_DESCS=$(echo "$REPOS_AVAIL" | awk '{if (NF < 3) print ""; else for (i=3; i<=NF; i++) printf $i (i<NF ? OFS : "\n")}')
  export REPO_DESCS  # otherwise fzf can't access it
  REPO_SEL=$(echo $REPO_NAMES | fzf --reverse --multi --height=~100% --preview-window down:wrap --preview 'echo "$REPO_DESCS" | sed -n "$(({n}+1))"p | sed "s/^\s*//g;s/\s*$//g"')

  if [ -z "$REPO_SEL" ]; then
      echo "No repositories selected."
      return 0
  fi

  echo "$REPO_SEL" | while read -r REPO_CURR; do
      REPO_URL=$(echo "$REPOS_AVAIL" | awk -v sel="$REPO_CURR" '$2 == sel {print $1}')

      if [ -d "$REPO_CURR" ]; then
          echo "Repository '$REPO_CURR' already cloned. Skipping."
      else
          echo "Cloning repository '$REPO_CURR' ($REPO_URL) ..."
          git clone "$REPO_URL" || echo "Error cloning $REPO_CURR - it might already be cloned."
      fi
  done

  echo "Operation completed."
}

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
appUsersAdmin_start_token() {
  REACT_APP_TOKEN=$(cat /home/patrick/appUsersAdmin.jwt) npm start
}
alias tosa=appUsersAdmin_start_token

dynamically_start_token() {
  token=$(/home/patrick/go/bin/tokens-cli --dir /home/patrick/snabble/platform-deploy/jwt/testing token --subject patrick.mueller-devserver@snabble.io devserverToken --out - $*)
  echo $token
  decode_jwt 2 $token
  REACT_APP_TOKEN=$(echo $token) npm start
}
alias tod=dynamically_start_token
dynamically_start_token_staging() {
  token=$(/home/patrick/go/bin/tokens-cli --dir /home/patrick/snabble/platform-deploy/jwt/staging token --subject patrick.mueller-devserver@snabble.io devserverToken --out - $*)
  echo $token
  decode_jwt 2 $token
  REACT_APP_TOKEN=$(echo $token) npm start
}
alias tods=dynamically_start_token_staging
dynamically_start_token_prod() {
  token=$(/home/patrick/go/bin/tokens-cli --dir /home/patrick/snabble/platform-deploy/jwt/prod token --subject patrick.mueller-devserver@snabble.io devserverToken --out - $*)
  echo $token
  decode_jwt 2 $token
  REACT_APP_TOKEN=$(echo $token) npm start
}
alias todp=dynamically_start_token_prod

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
