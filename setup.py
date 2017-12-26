#!/usr/bin/env python
# -*- coding: utf-8 -*-
import io
import os
from setuptools import find_packages, setup


DESCRIPTION = 'ELB python client'

here = os.path.abspath(os.path.dirname(__file__))

# Import the README and use it as the long-description.
# Note: this will only work if 'README.rst' is present in your MANIFEST.in file!
with io.open(os.path.join(here, 'README.md'), encoding='utf-8') as f:
    long_description = '\n' + f.read()

# Where the magic happens:
setup(
    name='elb.py',
    version='0.0.2',
    author='ricebook',
    description=DESCRIPTION,
    long_description=long_description,
    author_email='timfeirg@ricebook.com',
    url='https://github.com/projecteru2/elb',
    py_modules=['elb'],
    setup_requires=[
        'pytest-runner',
    ],
    tests_require=[
        'pytest',
    ],
    install_requires=[
        'requests',
        'setuptools',
    ],
    license='MIT',
    classifiers=[
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: Implementation :: CPython',
    ],
)
