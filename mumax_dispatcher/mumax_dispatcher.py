# -*- coding: utf-8 -*-
"""Usage:
    mumax_dispatcher.py --help
    mumax_dispatcher.py TEMPLATE RUN_PARAMS OUTPUT_TEMPLATE OUTPUT_DIR [options]


Arguments:
    TEMPLATE          The mumax input file with mako template fields to be
                      filled in with the parameters in the RUN_PARAMS file.

    RUN_PARAMS        A TOML configuration file with fields corresponding to
                      the mako template fields in the mumax input file
                      template. The fields can either be a single float, or a
                      list of floats.
                      If a field has a list as a value, then multiple runs will
                      take place, one for each value in the list. If there are
                      several fields with lists as values, the looping will be
                      nested so that all possible parameters combinations are
                      run.
    OUTPUT_TEMPLATE   A mako template string that will be the name of the
                      output directory for each mumax simulation. If multiple
                      simulations occur, one of the list values should be used
                      so that the directory names are meaningful.
    OUTPUT_DIR        The directory where all of the mumax3 output dirs will
                      go.
Options:
    -h --help              Show this.
    -r --run               Run simulations. If not passed, only a dry run will
                           occur (show input files and output dirs, but don't
                           actually start running mumax3)
    -m --mumax-path=PATH   Path to mumax3.exe command. If not passed, assumes
                           that mumax3.exe is in your $PATH and can be run
                           from anywhere. [default: ]
"""
from mako.template import Template
from docopt import docopt
from os.path import join, abspath, exists
from os import fsync
from subprocess import run
import pytoml as toml
from copy import deepcopy
import re
import shlex


exists_counter = 0


def main():
    args = docopt(__doc__)
#    print(args)

    print("\nPreparing to run mumax simulations...\n")

    run_params_dict = parse_run_params(args['RUN_PARAMS'])
    run_params = build_run_params(run_params_dict, [])
    template = build_template(abspath(args['TEMPLATE']))
    output_template = Template(args['OUTPUT_TEMPLATE'])
    output_dirname = abspath(args['OUTPUT_DIR'])
    do_run = args['--run']
    mumax_path = args['--mumax-path']
    input_path = 'mumax3_input'

    for rp in run_params:
        # Set render the templates
        output_basename = output_template.render(**rp)
        output_path = uniqueify(join(output_dirname, output_basename))
        input_file_contents = template.render(**rp)
        with open(input_path, 'w') as input_file:
            input_file.write(input_file_contents)
            fsync(input_file)
        print('output_path: ', output_path, '\n')
        print('Mumax input file contents: ')
        print('-' * 79)
        print(input_file_contents)
        print('-' * 79, '\n')

        basecmd = join(mumax_path, 'mumax3.exe')
        opts = '-o {} {}'.format(output_path, input_path)
        cmd = '{} {}'.format(basecmd, opts)    

        print('Command to be run: ')
        print(cmd, '\n')

        # Run the command
        if do_run:
            print('Running mumax3...')
#            run((basecmd, '--help'))
#            print(shlex.split(cmd))
            run(cmd)
        else:
            print('Dry run. No simulations are actually started.')
        print('\n')


def build_run_params(run_params_dict, run_params, ind=''):
    run_params_dict = deepcopy(run_params_dict)
    list_keys = [k for k, v in run_params_dict.items() if isinstance(v, list)]
    # print('\n\n')
    # print(ind+'dict', run_params_dict)
    # print(ind+'list keys: ', list_keys)
    if len(list_keys) == 0:
        return [run_params_dict]
    lk = list_keys.pop()
    vs = run_params_dict[lk]
    ind += '\t'
    # print(ind+'lk: ', lk)
    for v in vs:
        run_params_dict.update({lk: v})
        # print(ind+'v: ', v)
        run_params += build_run_params(run_params_dict, [], ind)
    return run_params


def parse_run_params(run_params_fname):
    with open(run_params_fname, 'r') as f:
        contents = f.read()
        raw_config = toml.loads(contents)
    return raw_config


def build_template(template_fname):
    with open(template_fname, 'r') as template_file:
        return Template(template_file.read())


def increment(path):
    if not re.search(r'_\d$', path):
        return path + '_0'
    else:
        i = int(path[-1])
        return path[:-1] + str(i + 1)


def uniqueify(output_path):
        while exists(output_path):
            msg = 'WARNING: output path with basename {} exists'
            print(msg.format(output_path))
            output_path = increment(output_path)
            print('\tchanged to %s' % output_path)
        return output_path





if __name__ == '__main__':
    main()
