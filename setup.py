from setuptools import setup


setup(
    name='elb.py',
    version='0.0.2',
    author='timfeirg',
    url='https://github.com/projecteru2/elb',
    zip_safe=True,
    author_email='timfeirg@ricebook.com',
    description='ELB 3 python client',
    py_modules=['elb'],
    install_requires=[
        'requests',
        'setuptools',
    ],
)
