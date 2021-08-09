function theme_one_dark_load
    if not set -q __theme_one_dark_gen
        set -U __theme_one_dark_gen 0
    end
    set -l generation 2
    if contains -- -f $argv; or test $__theme_one_dark_gen -lt $generation
        # Theme colors (from https://github.com/ful1e5/onedark.nvim/blob/main/lua/onedark/colors.lua)
        set --local bg 282c34
        set --local bg2 21252b
        set --local bg_visual 393f4a
        set --local border 646e82
        set --local bg_highlight 2c313a
        set --local fg abb2bf
        set --local fg_light adbac7
        set --local fg_dark 798294
        set --local fg_gutter 5c6370
        set --local dark5 abb2bf
        set --local blue 61afef
        set --local cyan 56b6c2
        set --local purple c678dd
        set --local orange d19a66
        set --local yellow e0af68
        set --local yellow2 e2c08d
        set --local bg_yellow ebd09c
        set --local green 98c379
        set --local red e86671
        set --local red1 f65866
        # fish colors
        set --universal fish_color_command $blue
        set --universal fish_color_keyword $purple
        set --universal fish_color_quote $green
        set --universal fish_color_redirection $cyan
        set --universal fish_color_end normal
        set --universal fish_color_error $red1
        set --universal fish_color_param normal
        set --universal fish_color_comment --italics $fg_gutter
        set --universal fish_color_operator $yellow
        set --universal fish_color_escape $red
        set --universal fish_color_autosuggestion $fg_gutter
        set --universal fish_color_cancel --reverse
        set --universal fish_color_valid_path --underline
        set --universal fish_color_search_match --background=$bg_visual
        # pager colors
        set --universal fish_pager_color_progress --reverse
        set --universal fish_pager_color_prefix $orange --underline
        set --universal fish_pager_color_completion normal
        set --universal fish_pager_color_description $cyan
        set --universal fish_pager_color_selected_background --background=$bg_visual
        set --universal fish_pager_color_selected_prefix --underline $orange
        set --universal fish_pager_color_selected_completion normal
        set --universal fish_pager_color_selected_description $cyan
        # fish_prompt colors
        set --universal fish_color_cwd $green
        set --universal fish_color_cwd_root $red
        if not contains -- $USER root
            set --universal fish_color_user $fish_color_cwd
        else
            set --universal fish_color_user $fish_color_cwd_root
        end
        set --universal fish_color_host $green
        set --universal fish_color_host_remote $green
        set --universal fish_color_status $red

        # remember last loaded generation in order to skip it if already defined
        set --universal __theme_one_dark_gen $generation
    end
end
