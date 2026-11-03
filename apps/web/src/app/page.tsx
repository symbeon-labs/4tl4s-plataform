"use client";

import { useState } from "react";
import { Eye, EyeOff, LockKeyhole, Mail, ArrowRight } from "lucide-react";

function AtlasMark() {
  return <svg viewBox="0 0 120 120" aria-hidden="true" className="atlas-mark">
    <path d="M17 39V17h22M81 17h22v22M17 81v22h22M103 81v22H81" fill="none" stroke="currentColor" strokeWidth="1.4"/>
    <circle cx="60" cy="42" r="25" fill="none" stroke="currentColor" strokeWidth="1.4"/>
    <path d="M35 42h50M60 17c-10 9-15 17-15 25s5 16 15 25M60 17c10 9 15 17 15 25s-5 16-15 25M60 67v8m-9-1 9-7 9 7m-18 0-9 10m27-10 9 10M42 84l18-9 18 9M48 84l-4 13m28-13 4 13M44 97h32" fill="none" stroke="currentColor" strokeWidth="1.35" strokeLinecap="round" strokeLinejoin="round"/>
    <path d="M52 58c2-5 5-7 8-7s6 2 8 7" fill="none" stroke="currentColor" strokeWidth="1.2"/>
  </svg>;
}

export default function Home() {
  const [visible, setVisible] = useState(false);
  const [notice, setNotice] = useState("");
  function handleSubmit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setNotice("A interface está pronta. A autenticação segura será conectada na próxima etapa.");
  }

  return <main className="login-shell">
    <section className="login-panel">
      <div className="login-content">
        <div className="brand-lockup">
          <AtlasMark />
          <div className="wordmark">4TL4S</div>
          <div className="platform"><i /> PLATFORM</div>
        </div>
        <p className="login-description">Coordenação, governança<br/>e execução de iniciativas.</p>
        <form className="login-form" onSubmit={handleSubmit}>
          <label className="field">
            <Mail size={17} aria-hidden="true"/>
            <input type="email" name="email" placeholder="E-mail" autoComplete="username" required aria-label="E-mail"/>
          </label>
          <label className="field">
            <LockKeyhole size={17} aria-hidden="true"/>
            <input type={visible ? "text" : "password"} name="password" placeholder="Senha" autoComplete="current-password" required aria-label="Senha"/>
            <button className="visibility" type="button" onClick={() => setVisible(!visible)} aria-label={visible ? "Ocultar senha" : "Mostrar senha"}>{visible ? <EyeOff size={17}/> : <Eye size={17}/>}</button>
          </label>
          <button className="submit-button" type="submit">Entrar <ArrowRight size={16}/></button>
          <button className="forgot" type="button" onClick={() => setNotice("A recuperação de senha será habilitada junto à autenticação.")}>Esqueceu sua senha?</button>
          {notice && <p className="form-notice" role="status">{notice}</p>}
        </form>
      </div>
      <div className="login-footer"><span>4TL4S PLATFORM</span><span>ACESSO CONTROLADO</span></div>
    </section>
    <aside className="editorial-panel" aria-label="Imagem editorial de Atlas">
      <div className="editorial-grid"/>
      <div className="editorial-orbit orbit-one"/>
      <div className="editorial-orbit orbit-two"/>
      <svg className="atlas-figure" viewBox="0 0 680 900" role="img" aria-label="Atlas, figura escultórica sustentando um globo">
        <defs>
          <linearGradient id="stone" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stopColor="#d7d7dc"/><stop offset=".42" stopColor="#777982"/><stop offset="1" stopColor="#292b32"/></linearGradient>
          <radialGradient id="globe"><stop offset="0" stopColor="#272932"/><stop offset=".78" stopColor="#101116"/><stop offset="1" stopColor="#08090c"/></radialGradient>
          <filter id="grain"><feTurbulence type="fractalNoise" baseFrequency=".72" numOctaves="3" stitchTiles="stitch"/><feColorMatrix values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 .12 0"/></filter>
        </defs>
        <circle cx="395" cy="190" r="275" fill="url(#globe)" stroke="#a9aab2" strokeOpacity=".55" strokeWidth="1.4"/>
        <ellipse cx="395" cy="190" rx="125" ry="275" fill="none" stroke="#a9aab2" strokeOpacity=".32"/>
        <ellipse cx="395" cy="190" rx="220" ry="275" fill="none" stroke="#a9aab2" strokeOpacity=".24"/>
        <path d="M122 190h546M146 92h498M146 288h498" fill="none" stroke="#a9aab2" strokeOpacity=".25"/>
        <path d="M210 452c-37-54-54-111-52-171 1-33 9-67 24-102 10-23 21-43 36-60 7-8 16-12 26-9 12 4 15 18 9 31l-26 62c-8 20-8 41 2 60l38 72c16 29 36 48 65 61l58 25-25 112-100-27c-23-6-42-24-55-54Z" fill="url(#stone)" stroke="#c8c8ce" strokeOpacity=".3"/>
        <path d="M343 394c-14-53-12-95 7-126 11-18 28-31 49-39 13-5 27 2 29 15 2 11-5 21-17 26-16 7-24 18-25 34-2 26 13 49 44 69l79 49-42 91-87-45c-18-9-30-33-37-74Z" fill="url(#stone)"/>
        <path d="M402 431c-24-20-43-46-52-76-9-31-5-59 11-84 11-17 26-29 45-36 11-4 23 2 25 14 2 10-4 19-14 24-15 8-22 19-21 34 1 17 12 34 32 49l52 38-37 79Z" fill="url(#stone)"/>
        <path d="M420 444c-8-36-1-69 22-96 18-22 42-35 72-39 22-3 40 7 49 26 7 15 4 29-8 42-11 12-25 17-43 17-17 0-29 7-36 20-8 16-7 36 3 61l43 111-113 32-24-91c-7-27-4-54 9-83Z" fill="url(#stone)"/>
        <path d="M489 384c-12-22-15-43-8-62 6-17 18-31 35-42 10-7 22-5 28 4 6 10 2 21-8 28-12 8-17 18-16 31 1 11 7 23 18 35" fill="none" stroke="#d2d2d8" strokeWidth="13" strokeLinecap="round"/>
        <path d="M386 474c-37 14-63 40-76 79-12 36-13 81-3 134l22 124h106l-4-155c-1-34 8-62 28-84l47-52-43-73Z" fill="url(#stone)"/>
        <path d="M433 488c-1 47 17 81 54 103 26 15 57 22 92 21l101-4v-94l-95-8c-21-2-39-11-53-27l-42-49Z" fill="url(#stone)"/>
        <path d="M322 807h126l20 55H292Z" fill="#44464e"/>
        <path d="M526 610c29 29 54 72 74 129l26 68h-94l-40-94c-11-26-28-47-51-63" fill="url(#stone)"/>
        <path d="M366 392c-9-22-7-42 7-59 11-14 27-22 48-23 18-1 33 6 45 20 10 12 15 27 14 45-1 19-8 34-22 46-14 12-30 17-49 13-19-4-33-18-43-42Z" fill="url(#stone)"/>
        <path d="M369 360c8-31 28-48 59-50 25-2 44 9 57 32-16-8-29-10-41-6-12 4-21 13-27 27-13-10-29-11-48-3Z" fill="#c1c1c8"/>
        <path d="M399 383l14 4m25-5 14-5m-44 28c11 7 23 8 36 1" stroke="#202127" strokeWidth="4" strokeLinecap="round" fill="none"/>
        <path d="M353 458c-20 37-28 76-22 117m137-94c22 20 35 48 39 82" fill="none" stroke="#e0e0e4" strokeOpacity=".35" strokeWidth="2"/>
        <rect width="680" height="900" filter="url(#grain)" opacity=".28"/>
      </svg>
      <div className="editorial-caption"><span>FIG. 01</span><span>ATLAS / THE WEIGHT OF SYSTEMS</span></div>
    </aside>
  </main>;
}
