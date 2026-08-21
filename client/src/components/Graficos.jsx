import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  PieChart,
  Pie,
  Cell,
  ResponsiveContainer,
} from 'recharts';

const apiUrl = import.meta.env.VITE_API_URL || 'http://localhost:8080';

const COLORS = {
  importante: '#10b981',
  normal: '#3b82f6',
};

const Graficos = () => {
  const [chartData, setChartData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [totalTarefas, setTotalTarefas] = useState(0);

  useEffect(() => {
    fetchTarefas();
  }, []);

  const fetchTarefas = async () => {
    setLoading(true);
    setError(null);

    try {
      const res = await fetch(`${apiUrl}/api/tarefas`);
      if (!res.ok) {
        throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      }

      const responseData = await res.json();
      const tarefas = responseData.data ? responseData.data : responseData;

      const importantes = tarefas.filter((t) => t.importante === true).length;
      const normais = tarefas.filter((t) => t.importante === false).length;

      setTotalTarefas(tarefas.length);
      setChartData([
        { name: 'Importante', valor: importantes },
        { name: 'Normal', valor: normais },
      ]);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const pieColors = [COLORS.importante, COLORS.normal];

  return (
    <div className="tasks-container" style={{ padding: '1.5rem' }}>
      <div style={{ marginBottom: '1rem' }}>
        <Link to="/" className="back-button">
          ← Voltar
        </Link>
      </div>

      <div style={{ marginBottom: '1.5rem', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h2 style={{ margin: 0, color: 'var(--text-primary)' }}>📊 Gráficos</h2>
        <button
          className="btn"
          onClick={fetchTarefas}
          disabled={loading}
          title="Atualizar dados"
        >
          🔄 {loading ? 'Carregando...' : 'Atualizar'}
        </button>
      </div>

      {loading && (
        <div className="empty-state">
          <p>Carregando dados...</p>
        </div>
      )}

      {error && (
        <div className="task" style={{ marginBottom: '0.75rem', borderLeft: '4px solid #ef4444' }}>
          <div>
            <strong>⚠️ Erro ao carregar dados:</strong>{' '}
            <span style={{ color: '#ef4444' }}>{error}</span>
          </div>
        </div>
      )}

      {!loading && !error && totalTarefas === 0 && (
        <div className="empty-state">
          <h3>Sem dados para exibir 📝</h3>
          <p>Adicione tarefas para ver os gráficos de prioridade.</p>
        </div>
      )}

      {!loading && !error && totalTarefas > 0 && (
        <>
          <div style={{ marginBottom: '1rem', textAlign: 'center' }}>
            <span style={{ fontSize: '0.875rem', color: 'var(--text-secondary)' }}>
              Total de tarefas: <strong>{totalTarefas}</strong>
            </span>
          </div>

          {/* Gráfico de Barras */}
          <div style={{
            marginBottom: '2rem',
            background: 'var(--bg-secondary)',
            borderRadius: '8px',
            padding: '1rem',
            border: '1px solid var(--border-color)',
          }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '1rem', color: 'var(--text-primary)', textAlign: 'center' }}>
              Tarefas por Prioridade (Barras)
            </h3>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={chartData} margin={{ top: 5, right: 20, left: 0, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="var(--border-color)" />
                <XAxis dataKey="name" tick={{ fill: 'var(--text-secondary)', fontSize: 12 }} />
                <YAxis allowDecimals={false} tick={{ fill: 'var(--text-secondary)', fontSize: 12 }} />
                <Tooltip
                  contentStyle={{
                    background: 'var(--bg-card)',
                    border: '1px solid var(--border-color)',
                    borderRadius: '6px',
                    color: 'var(--text-primary)',
                  }}
                />
                <Legend />
                <Bar dataKey="valor" name="Quantidade" radius={[4, 4, 0, 0]}>
                  {chartData.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={pieColors[index]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Gráfico de Pizza */}
          <div style={{
            background: 'var(--bg-secondary)',
            borderRadius: '8px',
            padding: '1rem',
            border: '1px solid var(--border-color)',
          }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '1rem', color: 'var(--text-primary)', textAlign: 'center' }}>
              Distribuição por Prioridade (Pizza)
            </h3>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={chartData}
                  cx="50%"
                  cy="50%"
                  outerRadius={80}
                  dataKey="valor"
                  nameKey="name"
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  labelLine={true}
                >
                  {chartData.map((entry, index) => (
                    <Cell key={`pie-cell-${index}`} fill={pieColors[index]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{
                    background: 'var(--bg-card)',
                    border: '1px solid var(--border-color)',
                    borderRadius: '6px',
                    color: 'var(--text-primary)',
                  }}
                />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </>
      )}
    </div>
  );
};

export default Graficos;
