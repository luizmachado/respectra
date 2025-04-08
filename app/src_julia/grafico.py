import matplotlib.pyplot as plt
import numpy as np

def plot_vector_field(filename, escala):
    # Carrega os dados
    data = np.genfromtxt(filename)
    x, y, z, dx, dy, dz = data.T

    # Cálculos para os vetores
    x_plot = x - dx / escala / 2
    y_plot = y - dy / escala / 2
    z_plot = z - dz / escala / 2

    # Primeira figura (2x2)
    plt.figure(figsize=(10, 10))

    # Gráfico 1: Vetor field em 3D
    plt.subplot(2, 2, 1, projection='3d')
    plt.quiver(x_plot, y_plot, z_plot, dx/escala, dy/escala, dz/escala)
    plt.xlabel('x')
    plt.ylabel('y')
    plt.clabel('z')

    # Gráfico 2: Vetor field XZ
    plt.subplot(2, 2, 2)
    plt.quiver(x_plot, z_plot, dx/escala, dz/escala)
    plt.xlabel('x')
    plt.ylabel('z')

    # Gráfico 3: Scatter plot
    plt.subplot(2, 2, 3)
    plt.scatter(x, y, c=z)  # Assumindo que z é usado para cor
    plt.xlabel('x')
    plt.ylabel('y')

    # Gráfico 4: Vetor field YZ
    plt.subplot(2, 2, 4)
    plt.quiver(y_plot, z_plot, dy/escala, dz/escala)
    plt.xlabel('y')
    plt.ylabel('z')

    plt.tight_layout()
    plt.savefig('vector_field.png')
    plt.show()

def plot_scatter_line(filename1, filename2):
    # Carrega os dados
    data1 = np.genfromtxt(filename1)
    data2 = np.genfromtxt(filename2)

    # Segunda figura (2x2)

    # Gráfico 1: Dispersão
    plt.subplot(2, 2, 1)
    print(len(data1))
    plt.scatter(data1[:, 0], data1[:, 1], label='CsT')
    plt.xlabel('Temp[K]')
    plt.ylabel('C/T[mJ/K^2/mol]')
    plt.legend()

    # Gráfico 2: Linha
    plt.subplot(2, 2, 2)
    plt.plot(data2[:, 0], data2[:, 1], label='Entropia')
    plt.xlabel('Temperatura (K)')
    plt.ylabel('Entropia (mJ/K/mol)')
    plt.legend()

    # ... (outros gráficos da segunda página)

    plt.tight_layout()
    plt.savefig('scatter_line.png')
    plt.show()

def plot_magnetization(filename1, filename2, filename3, filename4):
    # Carrega os dados
    data1 = np.genfromtxt(filename1)
    data2 = np.genfromtxt(filename2)
    data3 = np.genfromtxt(filename3)
    data4 = np.genfromtxt(filename4)

    # Terceira figura (2x2)

    # Gráfico 1: MsHvsT
    plt.subplot(2, 2, 1)
    plt.plot(data1[:, 0], data1[:, 1], label='MT1')
    plt.plot(data2[:, 0], data2[:, 1], label='MT2')
    plt.xlabel('Temp[K]')
    plt.ylabel('Chi[emu/mol.Oe]')
    plt.legend()

    # ... (outros gráficos da terceira página)
        # Gráfico 2: 1/ChivsT
    plt.subplot(2, 2, 2)
    plt.plot(data1[:, 0], 1/data1[:, 1], label='MT1')
    plt.plot(data2[:, 0], 1/data2[:, 1], label='MT2')
    plt.xlabel('Temperatura (K)')
    plt.ylabel('1/Susceptibilidade (Oe/emu.mol)')
    plt.legend()

    # Gráfico 3: MvsH
    plt.subplot(2, 2, 3)
    plt.plot(data3[:, 0], data3[:, 1], label='MH1')
    plt.plot(data4[:, 0], data4[:, 1], label='MH2')
    plt.xlabel('Campo (T)')
    plt.ylabel('Magnetização (emu/mol)')
    plt.legend()

    plt.tight_layout()
    plt.savefig('magnetization.png')
    plt.show()

plot_vector_field("./ConfSpin_Calc.txt", 0.5)
plot_scatter_line("./CsT_calc.txt", "./Entrop_calc.txt")
plot_magnetization("./MT1_calc.txt", "./MT2_calc.txt", "./MH1_calc.txt",
                   "./MH2_calc.txt")
