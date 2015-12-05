#!/usr/bin/env python

# Copyright 2015 Stanford University
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from __future__ import print_function
import errno, json, os, shutil, subprocess, sys

def make_markdown_cell(source):
    return {
        'cell_type': 'markdown',
        'metadata': {},
        'source': source.splitlines(True),
    }

def make_code_cell(source):
    return {
        'cell_type': 'code',
        'execution_count': None,
        'metadata': {
            'collapsed': False,
        },
        'outputs': [],
        'source': source.splitlines(True),
    }

def make_notebook(cells):
    return {
        'cells': cells,
        'metadata': {
            'kernelspec': {
                'display_name': 'Regent',
                'language': 'regent',
                'name': 'regent',
            },
            'language_info': {
                'file_extension': 'rg',
                'mimetype': 'text/x-regent',
                'name': 'regent',
                'pygments_lexer': 'lua',
            },
        },
        'nbformat': 4,
        'nbformat_minor': 0,
    }

def make_session_notebook(source_dir, notebook_path):
    instructions_path = os.path.join(source_dir, 'instructions.md')
    instructions = make_markdown_cell(open(instructions_path, 'rb').read())
    syntax_path = os.path.join(source_dir, 'syntax.rg')
    syntax = make_code_cell(open(syntax_path, 'rb').read())
    circuit_path = os.path.join(source_dir, 'circuit.rg')
    circuit = make_code_cell(open(circuit_path, 'rb').read())
    notebook = make_notebook([instructions, syntax, circuit])
    with open(notebook_path, 'wb') as f: json.dump(notebook, f, indent=1)

def make_all_sessions(exercise_dir, helpers_dir, notebook_dir):
    dirty = subprocess.check_output(['git', '-C', helpers_dir, 'clean', '-nxd'])
    if len(dirty.strip()) > 0:
        print('Please clean up {} and run again.'.format(os.path.relpath(helpers_dir)))
        print('(E.g. with git -C {} clean -fxd.)'.format(os.path.relpath(helpers_dir)))
        print(dirty)
        sys.exit(1)

    shutil.rmtree(notebook_dir, True)
    os.mkdir(notebook_dir)

    def make(_, path_dir, names):
        if 'instructions.md' in names:
            part = os.path.basename(path_dir).partition('part')
            session = os.path.basename(os.path.dirname(path_dir)).partition('session')
            assert(part[0] == '' and session[0] == '')
            notebook_name = 'Session {} Part {}.ipynb'.format(session[2], part[2])
            make_session_notebook(path_dir, os.path.join(notebook_dir, notebook_name))
    os.path.walk(exercise_dir, make, None)

    for name in os.listdir(helpers_dir):
        src_dir = os.path.join(helpers_dir, name)
        dst_dir = os.path.join(notebook_dir, name)
        if os.path.isdir(src_dir):
            shutil.copytree(src_dir, dst_dir)

if __name__ == '__main__':
    root_dir = os.path.dirname(os.path.realpath(__file__))
    exercises_dir = os.path.join(root_dir, 'regent', 'exercises')
    helpers_dir = os.path.join(root_dir, 'regent', 'helpers')
    notebook_dir = os.path.join(root_dir, 'regent', 'notebooks')
    make_all_sessions(exercises_dir, helpers_dir, notebook_dir)
