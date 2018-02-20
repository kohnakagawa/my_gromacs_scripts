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
    set_label(r"$d$ [nm]", r"$P(d)$")

    c18_c32 = np.loadtxt(os.path.join(input_dir, "c18_c32_aver.xvg"))[:,1]
    c3_c18  = np.loadtxt(os.path.join(input_dir, "c3_c18_aver.xvg"))[:,1]

    hist_c18_c32 = np.histogram(c18_c32, bins=100, density=True)
    hist_c3_c18  = np.histogram(c3_c18 , bins=100, density=True)

    # set_ticks(
    #     (0.0, 10.0, 180.0),
    #     (0.0, 0.2, 1.0)
    # )

    plt.xlim(0.3, 1.9)
    # plt.ylim(0.0, 0.02)

    hist_c18_c32_cord = (hist_c18_c32[1][1:] + hist_c18_c32[1][:-1]) * 0.5
    hist_c3_c18_cord = (hist_c3_c18[1][1:] + hist_c3_c18[1][:-1]) * 0.5

    plt.plot(hist_c18_c32_cord, hist_c18_c32[0], '-', label="C18-C32")
    plt.plot(hist_c3_c18_cord, hist_c3_c18[0], '-', label="C3-C18")

    plt.tight_layout()

    plt.legend(loc="upper left")

    plt.savefig(os.path.join(input_dir, "distance_hist.eps"))

    # for check
    # plt.show()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Density profile of carbons")
    parser.add_argument('-i', '--input', dest='input_dir', required=True, help="input directory name")
    args = parser.parse_args()
    main(args.input_dir)
