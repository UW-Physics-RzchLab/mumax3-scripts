import numpy as np
from numpy import sin, cos, deg2rad
import matplotlib.pyplot as plt
import os
from os.path import join, dirname, basename
import re





# Data parameters
topdir = 'G:\\box\jjirwin\\Box Sync\\mumax3_output\\julian_irwin\\save\\'
#study_dirname = join(topdir, 'grain_size_and_overlaps_160427')
study_dirname = join(topdir, 'impose_Ku_test_160601\\3')
sim_dirnames = os.listdir(study_dirname)
p = '.*'
sim_dirnames = [x for x in sim_dirnames if re.match(p, x)]
table_basename = 'table.txt'
#fnames = [(join(study_dirname, 'xfield_'+x, table_basename),
#           join(study_dirname, 'yfield_'+x, table_basename))
#           for x in sim_dirnames]
#fnames = [x for sub in fnames for x in sub]
fnames = [join(study_dirname, x, table_basename) for x in sim_dirnames]
# mcols = [1, 2, 3]
mcols = [7, 8, 9]
bcols = [4, 5, 6]
cols = mcols + bcols

savename = join(topdir, study_dirname, 'plots', 'all_hyst.png')

# Plot parameters
xlabel = 'B (T)'
ylabel = '$M/M_{Sat}$'
ylim = 1.1
xlim = 1.0


def rhat(theta, phi):
    return np.array((sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)))

def add_hyst_plot(ax, fname, start=0.0, end=1.0):
    table_dirname = basename(dirname(fname))
    m = re.search('b_phi=([\d\.]+)', table_dirname)
    if 'xfield' in table_dirname:
        theta = deg2rad(92.0)
        phi = deg2rad(2.0)
    elif 'zfield' in table_dirname:
        theta = deg2rad(2.0)
        phi = deg2rad(2.0)
    elif 'yfield' in table_dirname:
        theta = deg2rad(92.0)
        phi = deg2rad(92.0)
    elif m:
        theta = deg2rad(92.0)
        phi = deg2rad(float(m.groups()[0]) + 2.0)
        print(phi)
    else:
        theta = deg2rad(2.0)
        phi = deg2rad(2.0)
    mx, my, mz, bx, by, bz = np.loadtxt(fname, unpack=True, usecols=cols)
    m = np.array((mx, my, mz)).transpose()
    b = np.array((bx, by, bz)).transpose()
    x = b.dot(rhat(theta, phi))
    y = m.dot(rhat(theta, phi))
    start_ind = int(len(x) * start)
    end_ind = int(len(x) * end)
    ax.plot(x[start_ind:end_ind], y[start_ind:end_ind], 'o-',
            label=table_dirname)


fig, ax = plt.subplots()
ax.set_ylim(-ylim, ylim)
ax.set_xlim(-xlim, xlim)
ax.set_xlabel(xlabel)
ax.set_ylabel(ylabel)
for fname in fnames:
    add_hyst_plot(ax, fname, start=0.2)
ax.legend(loc='best', fontsize=10)
plt.tight_layout()
# plt.savefig(savename)
plt.show()
