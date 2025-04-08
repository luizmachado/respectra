import numpy as np
import matplotlib.pyplot as plt

# Nomes dos arquivos
archMT1 = "MT1_calc.txt"
archMT2 = "MT2_calc.txt"

# Carregar dados dos arquivos
data_MT1 = np.loadtxt(archMT1)
data_MT2 = np.loadtxt(archMT2)

# Extrair colunas (assumindo que a primeira coluna é a temperatura e a segunda é Chi)
temp_MT1 = data_MT1[:, 0]
chi_MT1 = data_MT1[:, 1]

temp_MT2 = data_MT2[:, 0]
chi_MT2 = data_MT2[:, 1]

# Configurar o gráfico
fig, axs = plt.subplots(2, 1, figsize=(8, 10))

# Gráfico M/H vs Temp (MsHvsT)
axs[0].plot(temp_MT1, chi_MT1, '-', color='blue', label='MT1')
axs[0].plot(temp_MT2, chi_MT2, '-', color='red', label='MT2')
axs[0].set_title("MsHvsT")
axs[0].set_xlabel("Temp [K]")
axs[0].set_ylabel("Chi [emu/mol.Oe]")
axs[0].legend()
axs[0].grid(True)

# Gráfico 1/Chi vs Temp
axs[1].plot(temp_MT1, 1 / chi_MT1, '-', color='blue', label='MT1')
axs[1].plot(temp_MT2, 1 / chi_MT2, '-', color='red', label='MT2')
axs[1].set_title("1/ChivsT")
axs[1].set_xlabel("Temp [K]")
axs[1].set_ylabel("1/Chi [mol.Oe/emu]")
axs[1].legend()
axs[1].grid(True)

# Ajustar layout
plt.tight_layout()
plt.savefig('mag.png', format='png')
plt.show()

