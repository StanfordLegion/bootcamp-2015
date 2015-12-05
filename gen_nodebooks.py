#!/usr/bin/env python

from __future__ import print_function
import errno, json, os

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

def make_all_sessions(source_dir, notebook_dir):
    try:
        os.mkdir(notebook_dir)
    except OSError as e:
        if e.errno != errno.EEXIST or not os.path.isdir(notebook_dir):
            raise

    def walk(_, path_dir, names):
        if 'instructions.md' in names:
            part = os.path.basename(path_dir).partition('part')
            session = os.path.basename(os.path.dirname(path_dir)).partition('session')
            assert(part[0] == '' and session[0] == '')
            notebook_name = 'Session {} Part {}.ipynb'.format(session[2], part[2])
            make_session_notebook(path_dir, os.path.join(notebook_dir, notebook_name))
    os.path.walk(source_dir, walk, None)

if __name__ == '__main__':
    root_dir = os.path.dirname(os.path.realpath(__file__))
    exercises_dir = os.path.join(root_dir, 'regent', 'exercises')
    notebook_dir = os.path.join(root_dir, 'regent', 'notebooks')
    make_all_sessions(exercises_dir, notebook_dir)
