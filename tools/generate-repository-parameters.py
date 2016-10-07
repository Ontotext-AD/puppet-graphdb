#!/usr/bin/env python3
# vim: set sw=4 sts=4 et foldmethod=indent :
# This script generates a puppet file(.pp) with the parameters stubbed for you
# and a template(.erb file) with placeholders
# Example usage:
#
#     ./generate-repository-parameters.py --puppet-file se_repository.ttl --puppet-template owilm.se.ttl.erb templates/owlim-se.ttl
#
# Note that the script requires python3


import sys
import re
import itertools
import argparse

parser = argparse.ArgumentParser(description='Generate python templates from sesame template')
parser.add_argument('template_location', metavar='template', type=str, help='A sesame template from which to do the generation')
parser.add_argument('--puppet-template', type=str, required=True, help="The location to the puppet template that we are going to generate")
parser.add_argument('--puppet-file', type=str, required=True, help="The location to the puppet file we are going to generate")

args = parser.parse_args()

template_content = open(args.template_location).read()


parameter_values = re.findall(r'{%([^%]+)%}', template_content)
parameter_names = re.findall(r'^#?\s+owlim:([^ ]+)', template_content, re.MULTILINE)
parameter_names.insert(0, 'repository_label')
parameter_names.insert(0, 'repository_id')

parameter_names = [x.replace('-', '_') for x in parameter_names]

puppet_template = open(args.puppet_template, 'w')
puppet_file = open(args.puppet_file, 'w')

def print_param(param, output):
    if param[1] is None:
        print("No parameter value for '%s'" % param[0])
        return
    value_placeholder = param[1].split('|')
    if len(value_placeholder) == 1:
        # Default value is empty string
        value_placeholder.append('')
    print("# " + value_placeholder[0], file=output)
    print("$%s = '%s'," % (param[0], value_placeholder[1]), file=output)

#This is hardcoded in the worker template. Check if it is hardcoded and remove
#it from the values
if 'repository_type' in parameter_names and not 'Repository type|file-repository' in parameter_values:
    parameter_names.remove('repository_type')

if len(parameter_names) != len(parameter_values):
    print("Parameter name and parameter values are with different length! Please fix the logic in the script")
    for param in itertools.zip_longest(parameter_names, parameter_values):
        print_param(param, sys.stdout)

    sys.exit(1)

for param in zip(parameter_names, parameter_values):
    print_param(param, puppet_file)



for param in zip(parameter_names, parameter_values):
    template_content = template_content.replace('{%' + param[1] + '%}', '<%= @' + param[0] + ' %>')

print(template_content, file=puppet_template)
