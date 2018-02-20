#!/usr/bin/env python
import numpy as np
import matplotlib.pyplot as plt
import argparse
import os

def set_font():
    plt.rcParams["font.size"] = 16
    plt.rcParams["font.family"] = 'serif'


def set_label(x_name, y_name):
    plt.xlabel(x_name, fontsize=26)
    plt.ylabel(y_name, fontsize=26)


def set_ticks(x_range, y_range):
    plt.xticks(np.arange(*x_range))
    plt.yticks(np.arange(*y_range))


def main(input_dir):
    set_font()
    set_label(r"$\theta$ [degrees]", r"$P(\theta)$")

    ang_mol = np.loadtxt(os.path.join(input_dir, "ang_mol_aver.xvg"))[:,1]
    ang_z   = np.loadtxt(os.path.join(input_dir, "ang_z_aver.xvg"))[:,1]

    hist_mol = np.histogram(ang_mol, bins=100, density=True)
    hist_z   = np.histogram(ang_z,   bins=100, density=True)

    # set_ticks(
    #     (0.0, 10.0, 180.0),
    #     (0.0, 0.2, 1.0)
    # )

    plt.xlim(0.0, 180.0)
    plt.ylim(0.0, 0.01)

    hist_mol_cord = (hist_mol[1][1:] + hist_mol[1][:-1]) * 0.5
    hist_z_cord = (hist_z[1][1:] + hist_z[1][:-1]) * 0.5

    plt.plot(hist_mol_cord, hist_mol[0], '-', label="C3-C18-C32")
    plt.plot(hist_z_cord, hist_z[0], '-', label="Z-C18-C32")

    plt.tight_layout()

    plt.legend(loc="upper left")

    plt.savefig(os.path.join(input_dir, "angle_hist.eps"))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Density profile of carbons")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    args = parser.parse_args()
    main(args.input_dir)
