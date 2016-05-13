import numpy as np
from numpy import sin, cos, deg2rad
import matplotlib.pyplot as plt
import os
from os.path import join, dirname, basename
import re
import sys

def rhat(theta, phi):
    return np.array((sin(theta) * cos(phi), sin(theta) * sin(phi), cos(theta)))

def determine_field_direction(data_path, delta=2.0):
    data_dirname = basename(dirname(data_path))
    if 'xfield' in data_dirname:
        theta = deg2rad(90.0 + delta)
        phi = deg2rad(delta)
    elif 'zfield' in data_dirname:
        theta = deg2rad(delta)
        phi = deg2rad(delta)
    elif 'yfield' in data_dirname:
        theta = deg2rad(90.0 + delta)
        phi = deg2rad(90.0 + delta)
    else:
        theta = deg2rad(delta)
        phi = deg2rad(delta)
    return theta, phi


def add_hyst_plot(ax, data_path, theta, phi, start=0.0, end=1.0, mcols=[1, 2, 3],\
                  bcols=[4, 5, 6]):
    mx, my, mz, bx, by, bz = np.loadtxt(data_path, unpack=True,
                                        usecols=mcols+bcols)
    m = np.array((mx, my, mz)).transpose()
    b = np.array((bx, by, bz)).transpose()
    x = b.dot(rhat(theta, phi))
    y = m.dot(rhat(theta, phi))
    start_ind = int(len(x) * start)
    end_ind = int(len(x) * end)
    ax.plot(x[start_ind:end_ind], y[start_ind:end_ind], 'o-',
            label=basename(dirname(data_path)))


def main():
    data_dirpath = sys.argv[1]
    data_path = join(data_dirpath, 'table.txt')

    fig, ax = plt.subplots()
    ax.set_xlabel('B (T)')
    ax.set_ylabel('$M/M_{Sat}$')
    ax.set_ylim(-1.1, 1.1)
    theta, phi = determine_field_direction(data_path)
    add_hyst_plot(ax, data_path, theta, phi)

    savename = join(data_dirpath, 'hyst.png')
    plt.savefig(savename)


if __name__ == '__main__':
    main()
