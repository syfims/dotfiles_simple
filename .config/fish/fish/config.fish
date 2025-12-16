set -g fish_greeting ""
set -gx EDITOR nvim
fish_add_path ~/.local/bin

# Aliases
abbr -a l 'ls -F'
abbr -a ll 'ls -lF'
abbr -a la 'ls -laF'
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a g 'git'
abbr -a gc 'git commit -m'
abbr -a gp 'git push'
abbr -a gs 'git status'
abbr -a hm 'history merge'
abbr -a c 'clear'
abbr -a n 'nvim'
abbr -a cat 'bat'

# Colors (Catppuccin Mocha)
set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_param f2cdcd
set -g fish_color_keyword f38ba8
set -g fish_color_quote a6e3a1
set -g fish_color_redirection f5c2e7
set -g fish_color_end f5c2e7
set -g fish_color_comment 6c7086
set -g fish_color_error f38ba8
set -g fish_color_gray 6c7086
set -g fish_color_selection --background=313244
set -g fish_color_search_match --background=313244
set -g fish_color_operator f5c2e7
set -g fish_color_escape f5c2e7
set -g fish_color_autosuggestion 6c7086

set -g fish_color_cwd 94e2d5
set -g fish_color_user 94e2d5
set -g fish_color_host 89b4fa

# Prompt
function fish_prompt
    echo -n " "
    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color normal
    echo -n " "
    set_color f5c2e7 
    echo -n "❯ "
    set_color normal
end

function fish_right_prompt
    set -l last_status $status
    if test $last_status -ne 0
        set_color f38ba8
        echo -n "✖ $last_status "
        set_color normal
    end
    
    set -l git_branch (git branch --show-current 2>/dev/null)
    if test -n "$git_branch"
        set_color 6c7086
        echo -n "($git_branch) "
        set_color normal
    end
end

# gits (Backup utility)
function gits
    set -l msg $argv[1]
    if test -z "$msg"
        set msg "Auto-update: $(date '+%Y-%m-%d %H:%M:%S')"
    end

    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "❌ Not a git repository. Initializing..."
        git init
        git checkout -b main
    end

    # Check for remote
    if not git remote -v >/dev/null 2>&1
        echo "⚠️  No remote repository configured."
        read -P "🔗 Enter remote URL (e.g., git@github.com:user/repo.git): " remote_url
        if test -n "$remote_url"
            git remote add origin "$remote_url"
            echo "✅ Remote 'origin' added."
        else
            echo "❌ No URL provided. Aborting push (files will be committed locally)."
        end
    end

    echo "📦 Adding files..."
    git add .

    if git diff-index --quiet HEAD --
        echo "✅ No changes to commit."
    else
        echo "💾 Committing: '$msg'"
        git commit -m "$msg"
    end
    
    echo "🚀 Pushing..."
    if not git push
        echo "⚠️  Push failed. Setup upstream: git push -u origin main"
        git push -u origin main
    end
end
