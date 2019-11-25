#!/usr/bin/env python
# -*-coding: utf-8-*-

import dataFormat
import sys

f = open('./test.csv', 'r')
csv_str = f.read()
f.close()

sd = dataFormat.Csv(csv_str, sys.argv)

for js in sys.argv[1:]:
    print('')
    print('============{:^26}============'.format(js))
    print('')
    try:
        for n, i in enumerate(sd.output_dict_with_index[js]):
            if i in ['部門', '科別', '負責人', '部別', '備註']:
                print('{:8}    : {}'.format(i, sd.output_dict_with_index[js][i]))
            elif i.strip() == '' or i.replace('  ', '').replace(' ', '').strip() == '' or i == '   ' or n == 4:
                continue
            else:
                print('{:10}: {}'.format(i, sd.output_dict_with_index[js][i]))
    except KeyError:
        print('No forestage information!')
    print('')
    print('=' * 50)
    print('')
