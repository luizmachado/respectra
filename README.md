# AI-Powered Tool for Investigating CEF Effects on Magnetic Properties of Rare-Earth Intermetallic Compounds

This project introduces a novel tool based on Artificial Intelligence to support research in condensed matter physics. It focuses on predicting the magnetic properties of rare-earth intermetallic compounds by simulating and analyzing the effects of the Crystalline Electric Field (CEF).

## 🧠 Project Overview

The correct description of magnetic properties in rare-earth compounds heavily depends on CEF effects. Traditionally, these effects are investigated through experimental techniques such as neutron scattering, X-ray absorption, or Mössbauer spectroscopy.

As an alternative approach, we developed an intelligent system capable of:

- Performing parameter fitting based on magnetic characterization measurements
- Simulating magnetic properties such as magnetization, specific heat, and susceptibility
- Responding to domain-specific scientific questions through Natural Language Processing (NLP)

## 🛠 Architecture

The architecture is composed of several components:

- **LangChain Framework**: Orchestrates LLM-based workflows.
- **LLM Integration**: Compatible with a wide range of language models, allowing flexible deployment based on local infrastructure or cloud resources.
- **Julia Backend**: Executes the core magnetic simulations and parameter fitting routines.
- **Ollama**: Hosts the language model locally.
- **Streamlit**: Serves the tool via a web-based interface.

```
Researcher → Defines context → LangChain + LLM → Executes simulation or inference → Returns result or triggers next step
```

## 🔬 Methodology

Simulations are performed based on a Hamiltonian that incorporates the CEF, applied to a selected magnetic sublattice. The system enables the simultaneous fitting of experimental data:

- Magnetization vs. Magnetic Field
- Susceptibility vs. Temperature
- Specific Heat

This is made possible by chaining LLM-driven logic with scientific computation modules in Julia.

## 🌐 Web Integration

The tool is deployed as a web application and exposes its features via an API. This makes it accessible across platforms and enables automation of research workflows.

## ✅ Results

- Successfully generated input files for simulations and parameter adjustment
- Delivered consistent and accurate predictions of magnetic properties
- Proven effective in scientific Q&A interactions
- Demonstrated robust integration of AI and physics simulation

## 📚 References

1. C. B. R. Jesus et al., Physics Procedia 75, 618–624 (2015).
2. C. Adriano et al., J. of App. Phys. 117, 17C103 (2015).
3. [LangChain Documentation](https://python.langchain.com/docs/introduction/)
4. S. G. Mercena et al., *Intermetallics*, vol. 130, 107040 (2020). [DOI](https://doi.org/10.1016/j.intermet.2020.107040)

## 👥 Authors

- **Arthur Rodrigues Resplandes** – [arthur.resplandes@ufnt.edu.br](mailto:arthur.resplandes@ufnt.edu.br)  
- **Luiz Augusto Machado da Silva** – [luiz.augusto@ufnt.edu.br](mailto:luiz.augusto@ufnt.edu.br)  
- **Samuel Gomes de Mercena** – [samuelg.mercena@ufnt.edu.br](mailto:samuelg.mercena@ufnt.edu.br)  
  - UFNT (Federal University of Northern Tocantins)  
  - UFS (Federal University of Sergipe)

---

This project demonstrates the power of interdisciplinary collaboration between physics and AI, and stands as a robust resource for cutting-edge research in magnetism and material science.