function theme_solarized_dark_load
    if not set -q __theme_solarized_dark_gen
        set -U __theme_solarized_dark_gen 0
    end
    set -l generation 6
    if contains -- -f $argv; or test $__theme_solarized_dark_gen -lt $generation
        # fish colors
        set --universal fish_color_command 859900
        set --universal fish_color_quote 2aa198
        set --universal fish_color_redirection 6c71c4
        set --universal fish_color_end cb4b16
        set --universal fish_color_error dc322f
        set --universal fish_color_param 93a1a1
        set --universal fish_color_comment --italics 586e75
        set --universal fish_color_match normal
        set --universal fish_color_selection 586e75 --reverse
        set --universal fish_color_search_match --background=black
        set --universal fish_color_operator b58900
        set --universal fish_color_escape cb4b16
        set --universal fish_color_autosuggestion 586e75
        set --universal fish_color_cancel --reverse
        set --universal fish_color_valid_path --underline
        # pager colors
        set --universal fish_pager_color_progress --reverse
        set --universal fish_pager_color_prefix 2aa198 --underline
        set --universal fish_pager_color_completion normal
        set --universal fish_pager_color_description 268bd2
        set --universal fish_pager_color_selected_background --background=black
        set --universal fish_pager_color_selected_prefix 2aa198 --underline
        set --universal fish_pager_color_selected_completion 93a1a1
        set --universal fish_pager_color_selected_description 268bd2
        # fish_prompt colors
        set --universal fish_color_cwd 859900
        set --universal fish_color_cwd_root dc322f
        if not contains -- $USER root
            set --universal fish_color_user $fish_color_cwd
        else
            set --universal fish_color_user $fish_color_cwd_root
        end
        set --universal fish_color_host 859900
        set --universal fish_color_host_remote 859900
        set --universal fish_color_status dc322f

        # remember last loaded generation in order to skip it if already defined
        set --universal __theme_solarized_dark_gen $generation
    end
end
