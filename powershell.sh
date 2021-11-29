# kill all node processes
Do { Stop-Process -Name node; } Until ($? -ne "True")

# open Windows Terminal tabs
 wt  -w _quake -p "bash"`; split-pane -p "bash" `; split-pane -p "bash"`; nt -p "bash"`; split-pane -d Varicent -p "bash"