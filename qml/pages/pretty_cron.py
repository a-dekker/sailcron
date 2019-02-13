def get_pretty(line_nbr, expression):
    """Get a human readable string for the cron expression"""
    import sys
    import subprocess
    import pyotherside
    # By default the module is installed in the 2.7 branch, pyotherside uses python 3
    # We use a custom location
    sys.path.append("/usr/share/harbour-sailcron/python/")
    # https://github.com/Salamek/cron-descriptor
    from cron_descriptor import Options, CasingTypeEnum, DescriptionTypeEnum, ExpressionDescriptor

    # get proper 24/12 hour notation and strip output
    output = subprocess.check_output(
        "/usr/bin/dconf read /sailfish/i18n/lc_timeformat24h", shell=True)
    output = str(output).replace("'", "").replace(
        'b"', "").replace('\\n"', "").strip()
    is24h = bool(output == "24")
    SPECIALS = {"reboot":   '@reboot',
                "hourly":   '0 * * * *',
                "daily":    '0 0 * * *',
                "weekly":   '0 0 * * 0',
                "monthly":  '0 0 1 * *',
                "yearly":   '0 0 1 1 *',
                "annually": '0 0 1 1 *',
                "midnight": '0 0 * * *'}

    key = expression.lstrip('@').rstrip(' ').lower()
    if key in SPECIALS.keys():
        expression = SPECIALS[key]
    # set options
    options = Options()
    options.throw_exception_on_parse_error = False
    options.casing_type = CasingTypeEnum.Sentence
    options.use_24hour_time_format = is24h
    if expression == "@reboot":
        pyotherside.send('result', line_nbr, expression)
        human_format = "reboot"
    else:
        descripter = ExpressionDescriptor(expression, options)
        human_format = descripter.get_description(DescriptionTypeEnum.FULL)

        pyotherside.send('result', line_nbr, human_format)
    return human_format
