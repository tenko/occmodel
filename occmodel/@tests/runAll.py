# -*- coding: utf-8 -*-
#
# This file is part of occmodel - See LICENSE.txt
#
import sys
from unittest import main

if __name__ == '__main__':
    sys.dont_write_bytecode = True
    sys.argv.append('discover')
    sys.argv.append('--verbose')
    main(exit=False)