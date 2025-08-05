ignore_list = ['cs', 'ds', 'mkdir', 'ff', 'clear', 'vim', 'ls', 'cd', 'note']
git_cmds = dict()
bazel_cmds = dict()
sim_cmds = dict()
grep_cmds = dict()
other_cmds = dict()

def add_cmd_type(cmd, cmd_type, cmd_dict):
    words = cmd.split()
    if words[0] == cmd_type:
        cmd_dict[cmd] = cmd_dict.get(cmd, 0) + 1

bash_history = open("/home/kcaldwell/.bash_history")
Lines = bash_history.readlines()
for line in Lines:
    words = line.split()
    if len(words) > 0: 
        if words[0] not in ignore_list:
            if words[0] == 'git':
                git_cmds[line] = git_cmds.get(line, 0) + 1
            elif words[0] == 'bazel':
                bazel_cmds[line] = bazel_cmds.get(line, 0) + 1
            elif words[0] == 'grep':
                grep_cmds[line] = grep_cmds.get(line, 0) + 1
            elif words[0] == 'sim/argus_sim/run_sdl.sh':
                sim_cmds[line] = sim_cmds.get(line, 0) + 1
            elif words[0] == 'sim/launch.sh':
                sim_cmds[line] = sim_cmds.get(line, 0) + 1
            else:
                other_cmds[line] = other_cmds.get(line, 0) + 1
bash_history.close()

sorted_history_file = open("/home/kcaldwell/Documents/Zoox/Command History.md", 'w')
sorted_history_file.write("Update by running:\n```bash\npython3 Documents/dotfiles/cli_summary.py\n```\n\n")
sorted_history_file.write("```bash\n# git commands\n")
for w in sorted(git_cmds, key=git_cmds.get, reverse=True):
    sorted_history_file.write(w)
sorted_history_file.write("\n```\n")
sorted_history_file.write("```bash\n# bazel commands\n")
for w in sorted(bazel_cmds, key=bazel_cmds.get, reverse=True):
    sorted_history_file.write(w)
sorted_history_file.write("\n```\n")
sorted_history_file.write("```bash\n# grep commands\n")
for w in sorted(grep_cmds, key=grep_cmds.get, reverse=True):
    sorted_history_file.write(w)
sorted_history_file.write("\n```\n")
sorted_history_file.write("```bash\n# sim commands\n")
for w in sorted(sim_cmds, key=sim_cmds.get, reverse=True):
    sorted_history_file.write(w)
sorted_history_file.write("\n```\n")
sorted_history_file.write("```bash\n# other commands\n")
for w in sorted(other_cmds, key=other_cmds.get, reverse=True):
    sorted_history_file.write(w)
sorted_history_file.write("\n```\n")
