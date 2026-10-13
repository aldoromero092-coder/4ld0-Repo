import React, { useState } from 'react';
import './App.css';

const App = () => {
  const [faculty, setFaculty] = useState('Ingeniería');
  const isCaazapa = true;

  const themeColors: Record<string, string> = {
    'Ingeniería': '#0047AB',
    'Economía': '#228B22',
  };

  const currentColor = themeColors[faculty] || '#333';

  return (
    <div style={{ '--primary-color': currentColor } as React.CSSProperties} className="app-container">
      {isCaazapa && <div className="caazapa-tag">Sede Caazapá</div>}
      
      <header className="header">
        <h1>SIPA UNVES</h1>
        <p>Facultad: {faculty}</p>
      </header>

      <main className="dashboard">
        <section className="card">
          <h2>Estado de Cuenta</h2>
          <p>Deuda actual: 0 Gs</p>
        </section>
        
        <section className="card">
          <h2>Pagos</h2>
          <button style={{ backgroundColor: 'var(--primary-color)' }}>Pagar ahora</button>
        </section>

        <section className="card">
          <h2>Trámites</h2>
          <button>Ver trámites</button>
        </section>

        <section className="card">
          <h2>Tickets</h2>
          <button>Soporte</button>
        </section>
      </main>
    </div>
  );
};

export default App;
