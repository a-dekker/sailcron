def get_alias(line_nbr, alias):
    """ Search for base64 encoded alias """
    import pyotherside
    import base64
    from pathlib import Path

    sep = "~separator~"
    homedir = str(Path.home())
    config_dir = f"{homedir}/.config/harbour-sailcron"
    alias_file = f"{config_dir}/cron_command_alias.txt"
    alias_txt = ""

    with open(alias_file, "r") as file_pointer:
        for line in lines_that_start_with(alias, file_pointer):
            array = line.split(sep)
            alias_txt = base64.b64decode(array[1])
            break

    pyotherside.send("alias", line_nbr, alias_txt)
    return line_nbr, alias_txt


def lines_that_start_with(string, file_pointer):
    return [line for line in file_pointer if line.startswith(string)]
