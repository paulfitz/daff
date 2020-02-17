#!/usr/bin/env python

import os
from setuptools import setup
from distutils.command.build_py import build_py
from subprocess import call
import json
import os.path


class my_build_py(build_py):
    def run(self):
        if os.path.isfile("Makefile"):
            if call(["make", "setup_py"]) != 0:
                exit(1)
        build_py.run(self)


def read(fname):
    with open(os.path.join(os.path.dirname(__file__), fname)) as f:
        return f.read()


package = json.loads(read("package.json"))


setup(
    name=package['name'],
    version=package['version'],
    author=package['author']['name'],
    author_email=package['author']['email'],
    description=(package['description']),
    license=package['license'],
    keywords="data diff patch",
    url=package['url'],
    packages=['daff'],
    scripts=['daff.py'],
    entry_points={
        "console_scripts": [
            "daff=daff:main"
        ]
    },
    long_description=read('README.md'),
    long_description_content_type='text/markdown',
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Topic :: Utilities",
        "License :: OSI Approved :: MIT License"
    ],
    cmdclass={'build_py': my_build_py}
)
