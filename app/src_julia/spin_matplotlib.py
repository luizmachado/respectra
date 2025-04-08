import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Defina a escala
escala = 0.5

# Carregar os dados do arquivo arch (substitua 'arquivo_dados.txt' pelo caminho correto)
data = np.loadtxt('ConfSpin_Calc.txt')

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
fig, axs = plt.subplots(2, 2, subplot_kw={'projection': '3d'}, figsize=(10, 10))

# Plotar o gráfico 3D na primeira posição (esquerda superior)
axs[0, 0].quiver(x_start_3d, y_start_3d, z_start_3d, u_3d, v_3d, w_3d, length=1, normalize=True, color='b')
axs[0, 0].set_xlabel('x')
axs[0, 0].set_ylabel('y')
axs[0, 0].set_zlabel('z')

# Criar o layout 1x2 (uma linha, duas colunas) com multiplots e um tamanho maior
fig, axs = plt.subplots(1, 2, figsize=(16, 8))  # Alteramos o layout para 1x2 e aumentamos o tamanho da figura

# Plotar o gráfico 3D na primeira posição (esquerda)
ax1 = fig.add_subplot(1, 2, 1, projection='3d')  # Gráfico 3D
ax1.quiver(x_start_3d, y_start_3d, z_start_3d, u_3d, v_3d, w_3d, length=1, normalize=False, color='b')
ax1.set_xlabel('x')
ax1.set_ylabel('y')
ax1.set_zlabel('z')

# Plotar o gráfico 2D na segunda posição (direita)
ax2 = axs[1]  # Gráfico 2D
ax2.quiver(x_start_2d, z_start_2d, u_2d, w_2d, scale=1, scale_units='xy', angles='xy', color='b')
ax2.set_xlabel('x')
ax2.set_ylabel('z')

plt.tight_layout()
plt.savefig('spin2.png', format='png')
plt.show()

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

# Criar o layout 1x2 (uma linha, duas colunas) com multiplots e um tamanho maior
fig, axs = plt.subplots(1, 2, figsize=(16, 8))  # Layout 1x2 com uma figura maior

# Primeiro gráfico: scatter plot com tamanhos e cores variáveis
axs[0].scatter(x, y, s=sizes, c=colors, cmap='viridis', alpha=0.7)
axs[0].set_xlabel('x')
axs[0].set_ylabel('y')

# Segundo gráfico: Vetores 2D (y e z)
axs[1].quiver(y_start, z_start, u, w, scale=1, scale_units='xy', angles='xy', color='b')
axs[1].set_xlabel('y')
axs[1].set_ylabel('z')

# Ajuste o layout
plt.tight_layout()
plt.savefig('spin1.png', format='png')
plt.show()
