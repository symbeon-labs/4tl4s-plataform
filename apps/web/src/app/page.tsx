import { Activity, ArrowUpRight, Boxes, CheckCircle2, CircleDashed, Command, FileCheck2, Layers3, ShieldCheck, Workflow } from "lucide-react";

const metrics = [
  { label: "Projetos ativos", value: "03", note: "Ambiente demonstrativo", icon: Boxes },
  { label: "Evidências registradas", value: "128", note: "Dados sintéticos", icon: FileCheck2 },
  { label: "Verificações pendentes", value: "07", note: "Aguardando revisão", icon: CircleDashed },
  { label: "Integridade operacional", value: "98,4%", note: "Indicador ilustrativo", icon: ShieldCheck },
];
const projects = [
  { name: "Mundo do Sabor", scope: "Operações · piloto controlado", status: "Preparação", progress: 28, code: "MS-001" },
  { name: "3L0 Vision", scope: "Inteligência documental", status: "Em estruturação", progress: 64, code: "3L0-002" },
  { name: "ICIE", scope: "Custos e inventário industrial", status: "Fundação", progress: 42, code: "ICIE-003" },
];

export default function Home() {
  return <main className="shell">
    <aside className="sidebar">
      <div className="brand"><div className="brand-mark">4</div><div><strong>4TL4S</strong><span>OPERATING SYSTEM</span></div></div>
      <div className="workspace-label">WORKSPACE</div>
      <nav><a className="active"><Command size={17}/> Visão geral</a><a><Layers3 size={17}/> Projetos</a><a><FileCheck2 size={17}/> Evidências</a><a><Workflow size={17}/> Processos</a><a><ShieldCheck size={17}/> Governança</a></nav>
      <div className="sidebar-bottom"><div className="status-dot"/> <span>Ambiente de demonstração</span><small>v0.1.0 · FOUNDATION</small></div>
    </aside>
    <section className="content">
      <header className="topbar"><div className="crumb">Workspace <span>/</span> Visão geral</div><div className="top-right"><span className="env-pill">PREVIEW</span><div className="avatar">SX</div></div></header>
      <div className="page-wrap">
        <div className="eyebrow"><span/> CONTROL PLANE / OVERVIEW</div>
        <div className="headline-row"><div><h1>Visão geral</h1><p className="subtitle">Coordenação, rastreabilidade e governança em um só lugar.</p></div><button className="button" disabled>+ Novo projeto <span>Em breve</span></button></div>
        <div className="notice"><Activity size={18}/><div><strong>Fundação em construção</strong><p>Esta interface é uma prévia funcional com dados sintéticos. Autenticação, isolamento por organização e integrações ainda não estão habilitados.</p></div></div>
        <div className="metric-grid">{metrics.map(({label,value,note,icon:Icon})=><article className="metric" key={label}><div className="metric-top"><span>{label}</span><Icon size={17}/></div><strong>{value}</strong><small>{note}</small></article>)}</div>
        <div className="section-head"><div><div className="section-kicker">PORTFOLIO</div><h2>Projetos em acompanhamento</h2></div><button className="text-button" disabled>Ver todos <ArrowUpRight size={15}/></button></div>
        <div className="project-list">{projects.map(p=><article className="project" key={p.code}><div className="project-icon"><Layers3 size={19}/></div><div className="project-main"><div className="project-title">{p.name}<span>{p.code}</span></div><p>{p.scope}</p><div className="progress"><i style={{width:`${p.progress}%`}}/></div></div><div className="project-meta"><span className="tag">{p.status}</span><small>{p.progress}%</small></div><ArrowUpRight className="project-arrow" size={17}/></article>)}</div>
        <footer><span>4TL4S PLATFORM</span><span>Governança por desenho. Evidência antes de estado.</span><span>© 2026 SYMBEON</span></footer>
      </div>
    </section>
  </main>;
}
