import matplotlib.pyplot as plt
import numpy as np

def plot_vectors(filename, scale=0.5):
    """
    Plots vectors from a data file using Matplotlib.

    Args:
        filename (str): Path to the input data file.
        scale (float, optional): Scaling factor for vector lengths. Defaults to 0.5.
    """

    # Load data from the file
    data = np.genfromtxt(filename)
    x, y, z, dx, dy, dz = data.T

    # Cálculos para os vetores
    x_plot = x - dx / scale / 2
    y_plot = y - dy / scale / 2
    z_plot = z - dz / scale / 2
    u = dx/scale
    v = dy/scale
    w = dz/scale
    fig, ax = plt.subplots(subplot_kw={"projection": "3d"})
    ax.quiver(x_plot, y_plot, z_plot, u, v, w, arrow_length_ratio=.1 )

    ax.set(xticklabels=[],
           yticklabels=[],
           zticklabels=[])

    plt.savefig("vector_field", format='png', bbox_inches='tight')
    plt.show()

# Example usage
filename = "ConfSpin_Calc.txt"
plot_vectors(filename)
