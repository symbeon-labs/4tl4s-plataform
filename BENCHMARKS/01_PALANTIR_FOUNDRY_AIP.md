# Benchmark 01: Palantir Foundry & AIP (Artificial Intelligence Platform)

**Categoria:** Enterprise Operating System & Operational AI Governance  
**Referência de Mercado:** O padrão da indústria em fusão de dados operacionais e governança de agentes autônomos.

---

## 1. Arquitetura da "Ontologia Cinética"

Diferente de catálogos de dados passivos ou bancos de dados relacionais tradicionais, o Palantir estrutura a realidade corporativa em três pilares:

1. **Objetos (Nouns):** Representações semânticas de entidades do mundo real (ex: `Cliente`, `Pedido`, `Veículo`, `Iniciativa`, `Contrato`).
2. **Links (Relacionamentos):** Conexões tipadas e bidirecionais entre objetos (ex: `Hub Açaí` ──possui──► `Unidade Logística` ──opera──► `Frota`).
3. **Action Types (Verbs):** As únicas operações permitidas para alterar o estado do sistema (ex: `Aprovar Transferência de Pesquisa`, `Reajustar Rota`, `Promover Iniciativa`).

```
[ Usuário / Agente de IA ]
             │
             ▼
    [ Action Type ] ──► (Validação Estrita de Negócio & Políticas RLS)
             │
             ├── Se Alto Risco ──► [ Human-in-the-Loop (HITL) Checkpoint ]
             │
             ▼
     [ Estado Comitado na Ontologia & Trilha Imutável WORM ]
```

---

## 2. Governança de Agentes de IA no Palantir AIP

O Palantir AIP rejeita a ideia de que a segurança de IA reside em system prompts ("não faça coisas ruins"):
* **Agentes sem Acesso Direto a Bancos:** Um agente cognitivo nunca emite comandos SQL brutos nem escreve diretamente no banco.
* **Ferramental Limitado a Action Types:** As "tools" do agente são estritamente os Action Types mapeados e validados pelo sistema.
* **Segurança Herdada:** O agente herda as permissões estritas da identidade do usuário que o invocou (Purpose-Based Access Control).
* **HITL (Human-in-the-Loop):** Para ações com impacto financeiro, contratual, de IP ou de acesso, o agente gera apenas uma **Proposta** (*Proposal*), que exige autorização humana explícita antes da execução.

---

## 3. Aplicação Direta no 4TL4S

O 4TL4S adota a filosofia do Palantir AIP, mas implementada de forma **leve, nativa em PostgreSQL com Row Level Security (RLS) e soberana**:
1. Nossas tabelas relacionais com RLS (`initiatives`, `organizational_units`, `artifacts`, `decisions`) funcionam como a nossa camada de Objetos e Links.
2. Nossas Edge Functions e triggers de banco (`memberships_guard_invariants`, etc.) atuam como validadores de Action Types.
3. O contrato **SOA-4TL4S v0.1** garante que o agente cognitivo (SOA Kernel Runtime) interage com o 4TL4S apenas via payloads tipados e assinados, mantendo zero acoplamento de banco.