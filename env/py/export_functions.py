for name in dir(Coopy):
    if name[0] != '_':
        vars()[name] = getattr(Coopy, name)
