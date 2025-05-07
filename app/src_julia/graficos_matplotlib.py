import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def spin_matplotlib():
    # Defina a escala
    escala = 0.5
    
    # Carregar os dados do arquivo arch (substitua 'arquivo_dados.txt' pelo caminho correto)
    data = np.loadtxt('./src_julia/ConfSpin_Calc.txt')
    
    # Defina as colunas para o gráfico 3D (primeiro gráfico)
    x_start_3d = data[:, 0] - data[:, 3]/escala/2
    y_start_3d = data[:, 1] - data[:, 4]/escala/2
    z_start_3d = data[:, 2] - data[:, 5]/escala/2
    
    u_3d = data[:, 3] / escala  # Componente X do vetor
    v_3d = data[:, 4] / escala  # Componente Y do vetor
    w_3d = data[:, 5] / escala  # Componente Z do vetor
    
    # Defina as colunas para o gráfico 2D (segundo gráfico)
    x_start_2d = data[:, 0] - data[:, 3] / escala / 2  # Início do vetor no eixo x
    z_start_2d = data[:, 2] - data[:, 5] / escala / 2  # Início do vetor no eixo z
    
    u_2d = data[:, 3] / escala  # Componente x do vetor
    w_2d = data[:, 5] / escala  # Componente z do vetor
    
    # Criar o layout 2x2 com multiplots
    fig = plt.figure(figsize=(10, 10))

    
    # Plotar o gráfico 3D na primeira posição (esquerda superior)
    ax1 = fig.add_subplot(2, 2, 1, projection='3d')
    ax1.quiver(x_start_3d, y_start_3d, z_start_3d, u_3d, v_3d, w_3d, length=1, normalize=True, color='b')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('z')
    
    # Plotar o gráfico 2D na segunda posição (direita)
    ax2 = fig.add_subplot(2, 2, 2)
    ax2.quiver(x_start_2d, z_start_2d, u_2d, w_2d, scale=1, scale_units='xy', angles='xy', color='b')
    ax2.set_xlabel('x')
    ax2.set_ylabel('z')
    
    # Primeiro gráfico: Pontos (scatter) com cores e tamanhos variáveis
    x = data[:, 0]  # Coluna 1 para o eixo X
    y = data[:, 1]  # Coluna 2 para o eixo Y
    sizes = data[:, 5] * 10  # Usar a coluna 6 para o tamanho (escalado por 10 para maior visibilidade)
    colors = data[:, 2]  # Usar a coluna 3 para as cores
    
    # Segundo gráfico: Vetores 2D (eixos Y e Z)
    y_start = data[:, 1] - data[:, 4] / escala / 2  # Início do vetor no eixo y
    z_start = data[:, 2] - data[:, 5] / escala / 2  # Início do vetor no eixo z
    
    u = data[:, 4] / escala  # Componente y do vetor
    w = data[:, 5] / escala  # Componente z do vetor
    
    # Primeiro gráfico: scatter plot com tamanhos e cores variáveis
    ax3 = fig.add_subplot(2, 2, 3)
    ax3.scatter(x, y, s=sizes, c=colors, cmap='viridis', alpha=0.7)
    ax3.set_xlabel('x')
    ax3.set_ylabel('y')
    
    # Segundo gráfico: Vetores 2D (y e z)
    ax4 = fig.add_subplot(2, 2, 4)
    ax4.quiver(y_start, z_start, u, w, scale=1, scale_units='xy', angles='xy', color='b')
    ax4.set_xlabel('y')
    ax4.set_ylabel('z')
    
    # Ajuste o layout
    plt.tight_layout()
    plt.savefig('./static/graph.png', format='png')
    return

def mag_matplotlib():
    # Carregar os dados dos arquivos
    data_MH1 = np.loadtxt('./src_julia/MH1_calc.txt')
    data_MH2 = np.loadtxt('./src_julia/MH2_calc.txt')
    data_MT1 = np.loadtxt('./src_julia/MT1_calc.txt')
    data_MT2 = np.loadtxt('./src_julia/MT2_calc.txt')
    # Extrair colunas (assumindo que a primeira coluna é a temperatura e a segunda é Chi)
    temp_MT1 = data_MT1[:, 0]
    chi_MT1 = data_MT1[:, 1]
    
    temp_MT2 = data_MT2[:, 0]
    chi_MT2 = data_MT2[:, 1]

    
    # Separar os dados das colunas
    field_MH1, mag_MH1 = data_MH1[:, 0], data_MH1[:, 1]
    field_MH2, mag_MH2 = data_MH2[:, 0], data_MH2[:, 1]

    # Configurar o gráfico
    fig, axs = plt.subplots(3, 1, figsize=(8, 15))

    # Configurar o gráfico
    axs[0].set_title("MvsH")
    axs[0].set_xlabel("Field [T]")
    axs[0].set_ylabel("Mag [emu/mol]")
    
    # Plotar os dados
    axs[0].plot(field_MH1, mag_MH1, label="MH1", color='blue')
    axs[0].plot(field_MH2, mag_MH2, label="MH2", color='red')
    axs[0].legend()


   # Gráfico M/H vs Temp (MsHvsT)
    axs[1].plot(temp_MT1, chi_MT1, '-', color='blue', label='MT1')
    axs[1].plot(temp_MT2, chi_MT2, '-', color='red', label='MT2')
    axs[1].set_title("MsHvsT")
    axs[1].set_xlabel("Temp [K]")
    axs[1].set_ylabel("Chi [emu/mol.Oe]")
    axs[1].legend()
    axs[1].grid(True)

    # Gráfico 1/Chi vs Temp
    axs[2].plot(temp_MT1, 1 / chi_MT1, '-', color='blue', label='MT1')
    axs[2].plot(temp_MT2, 1 / chi_MT2, '-', color='red', label='MT2')
    axs[2].set_title("1/ChivsT")
    axs[2].set_xlabel("Temp [K]")
    axs[2].set_ylabel("1/Chi [mol.Oe/emu]")
    axs[2].legend()
    axs[2].grid(True)

 
    
    # Exibir a legenda
    plt.tight_layout()
    plt.savefig('./static/graph.png', format='png')
    return

def cs_matplotlib():
    # Carregar dados dos arquivos
    print('top')
    data_CsT = np.loadtxt('./src_julia/CsT_calc.txt')
    data_Entrop = np.loadtxt('./src_julia/Entrop_calc.txt')
    
    # Extrair colunas (assumindo que a primeira coluna é a temperatura)
    temp_CsT = data_CsT[:, 0]
    C_T = data_CsT[:, 1]
    
    temp_Entrop = data_Entrop[:, 0]
    Entrop = data_Entrop[:, 1]
    
    # Configurar o gráfico
    fig, axs = plt.subplots(2, 1, figsize=(8, 10))
    
    # Gráfico C/T vs Temp
    axs[0].plot(temp_CsT, C_T, 'o-', color='blue')
    axs[0].set_title("CsvsT")
    axs[0].set_xlabel("Temp [K]")
    axs[0].set_ylabel("C/T [mJ/K²/mol]")
    axs[0].grid(True)
    
    # Gráfico Entrop vs Temp
    axs[1].plot(temp_Entrop, Entrop, 'o-', color='green')
    axs[1].set_title("Entrop vs T")
    axs[1].set_xlabel("Temp [K]")
    axs[1].set_ylabel("Entrop [mJ/K/mol]")
    axs[1].grid(True)
    
    # Ajustar layout
    plt.tight_layout()
    plt.savefig('./static/graph.png', format='png')

