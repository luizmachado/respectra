import numpy as np
import matplotlib.pyplot as plt

# Nomes dos arquivos
archCsT = "CsT_calc.txt"
archEntrop = "Entrop_calc.txt"

# Carregar dados dos arquivos
data_CsT = np.loadtxt(archCsT)
data_Entrop = np.loadtxt(archEntrop)

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
plt.savefig('cs_entrop.png', format='png')
plt.show()

