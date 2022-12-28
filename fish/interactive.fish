# Force True colors
if string match -q '*-256color' $TERM
    set --global fish_term24bit 1
end
