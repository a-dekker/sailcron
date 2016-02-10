def get_pretty(expression):
    import sys
    # By default the module is installed in the 2.7 branch, pyotherside uses python 3
    # We use a custom location
    sys.path.append("/usr/share/harbour-sailcron/python/")
    # https://github.com/Salamek/cron-descriptor
    from cron_descriptor import Options, CasingTypeEnum, DescriptionTypeEnum, ExpressionDescriptor
    import subprocess

    # get proper 24/12 hour notation and strip output
    output = subprocess.check_output("/usr/bin/dconf read /sailfish/i18n/lc_timeformat24h", shell=True)
    output = str(output).replace("'","").replace('b"',"").replace('\\n"',"").strip()
    if output == "24":
        is24h = True
    else:
        is24h = False

    # set options
    options = Options()
    options.throw_exception_on_parse_error = False
    options.casing_type = CasingTypeEnum.Sentence
    options.use_24hour_time_format = is24h
    descripter = ExpressionDescriptor(expression, options)
    human_format = descripter.get_description(DescriptionTypeEnum.FULL)

    return human_format
