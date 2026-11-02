# Benchmark 02: Benchling — P&D, Evidências & Rastreabilidade de Ciclo de Vida

**Categoria:** Scientific & Industrial R&D Lifecycle Management  
**Referência de Mercado:** Padrão global em biotecnologia e ciências avançadas para gestão do ciclo de vida de pesquisa experimental até o produto.

---

## 1. O Problema da Transferência de Pesquisa para Produto

Nas organizações convencionais, a pesquisa vive em cadernos soltos, scripts não versionados ou planilhas locais. Quando a engenharia precisa transformar isso em produto:
* Perde-se a proveniência dos dados (quem testou, com quais parâmetros, sob qual evidência).
* Suposições experimentais são confundidas com requisitos determinísticos de produto.
* Violações de propriedade intelectual ocorrem silenciosamente.

---

## 2. Padrões Adotados pelo Benchling

1. **Princípios FAIR:** Dados de pesquisa devem ser *Findable* (Localizáveis), *Accessible* (Acessíveis), *Interoperable* (Interoperáveis) e *Reusable* (Reutilizáveis).
2. **Separação Caderno (Notebook) vs. Registro (Registry):**
   * O *Notebook* aceita exploração flexível e hipóteses abertas.
   * O *Registry* exige esquemas rígidos, validações de integridade e imutabilidade de entidades.
3. **Trilha de Auditoria 21 CFR Part 11 / WORM:**
   * Qualquer alteração em dados de ensaios ou formulações gera log imutável com carimbo de tempo, justificativa e assinatura digital.

---

## 3. Aplicação Direta no 4TL4S

A tese fundamental do 4TL4S e a **ADR-0003** (*Research-to-Development Transfer*) incorporam exatamente esta lição do Benchling:
* A pesquisa científica/teórica é conduzida no domínio de **Applied Research** (com hipóteses, notas e evidências).
* O avanço para **Product Development** não é automático: exige um processo formal de *Transfer Review* com registro de proveniência de IP, limitações e critérios de aceitação.
* A tabela `evidence` do 4TL4S implementa o rigor de evidências antes de afirmações.