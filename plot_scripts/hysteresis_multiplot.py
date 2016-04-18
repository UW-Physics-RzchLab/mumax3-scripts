import numpy as np
from numpy import sin, cos, deg2rad
import matplotlib.pyplot as plt
from os.path import join, dirname, basename





# Data parameters
topdir = 'G:\\mumax3_output\\julian_irwin\\save\\'
study_dirname = join(topdir, 'monotonic_steps_cyl_hyst_vary_miscut_160415')
sim_dirnames = ('zfield_Ly=4nm_miscut=0',
                'xfield_Ly=4nm_miscut=0')
table_basename = 'table.txt'
fnames = [join(study_dirname, x, table_basename) for x in sim_dirnames]
mcols = [1, 2, 3]
bcols = [4, 5, 6]
cols = mcols + bcols

savename = join(topdir, study_dirname, 'plots', '4nm_miscut=5.7_x+z.png')

# Plot parameters
xlabel = 'B (T)'
ylabel = '$M/M_{Sat}$'
ylim = 1.1
xlim = None


def rhat(theta, phi):
    return np.array((sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)))


def add_hyst_plot(ax, fname):
    table_dirname = basename(dirname(fname))
    if 'xfield' in table_dirname:
        theta = deg2rad(92.0)
        phi = deg2rad(2.0)
    elif 'zfield' in table_dirname:
        theta = deg2rad(2.0)
        phi = deg2rad(2.0)
    elif 'yfield' in table_dirname:
        theta = deg2rad(92.0)
        phi = deg2rad(92.0)
    mx, my, mz, bx, by, bz = np.loadtxt(fname, unpack=True, usecols=cols)
    m = np.array((mx, my, mz)).transpose()
    b = np.array((bx, by, bz)).transpose()
    x = b.dot(rhat(theta, phi))
    y = m.dot(rhat(theta, phi))
    ax.plot(x, y, 'o-', label=table_dirname)


fig, ax = plt.subplots()
ax.set_xlabel(xlabel)
ax.set_ylabel(ylabel)
for fname in fnames:
    add_hyst_plot(ax, fname)
ax.legend(loc='best', fontsize=10)
plt.tight_layout()
plt.savefig(savename)
