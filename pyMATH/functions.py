from math import fabs, sin


def sinc(x):
    """
    Compute Sinc Function.
    The implementation of this method was greatly inspired by the
    one in Open Dynamics Engine v. 0.039

    This method returns sin(x)/x. this has a singularity at 0 so special
    handling is needed for small arguments.

    :param x:    The input argument
    :return:     The value of sin(x)/x
    """
    '''
    if |x| < 1e-4 then use a taylor series expansion. this two term expansion
    is actually accurate to one LS bit within this range if double precision
    is being used - so don't worry!
    '''
    tiny = 1.0e-4
    factor = 0.166666666666666666667
    if fabs(x) < tiny:
        return 1.0 - x* x * factor
    return sin(x) / x


def clamp(value, lower, upper):
    if value < lower:
        return lower
    if value > upper:
        return upper
    return value
