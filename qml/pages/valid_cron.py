def validate_cron(expression):
    """Check validity of a cron expression"""
    import sys

    # By default the module is installed in the 2.7 branch, pyotherside uses python 3
    # We use a custom location
    sys.path.append("/usr/share/harbour-sailcron/python/python-crontab")
    # https://pypi.python.org/pypi/python-crontab
    from crontab import CronSlices

    # bool = CronSlices.is_valid('0/2 * * * *')

    isValid = CronSlices.is_valid(expression)

    return isValid
